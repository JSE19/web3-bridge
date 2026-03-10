// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/EvictionVault.sol";

/// @notice Minimal malicious contract used to attempt reentrancy attacks
contract ReentrantAttacker {
    EvictionVault public vault;
    uint256 public attackCount;

    constructor(address payable _vault) {
        vault = EvictionVault(_vault);
    }

    // Called when ETH is sent to this contract — attempts to re-enter withdraw
    receive() external payable {
        if (attackCount < 3 && address(vault).balance > 0) {
            attackCount++;
            vault.withdraw(1 ether);
        }
    }

    function attack() external {
        vault.withdraw(1 ether);
    }
}

contract EvictionVaultTest is Test {
    EvictionVault vault;

    // Named actors
    address owner1 = makeAddr("owner1");
    address owner2 = makeAddr("owner2");
    address owner3 = makeAddr("owner3");
    address depositor = makeAddr("depositor");
    address stranger = makeAddr("stranger");

    // Merkle tree for 2-leaf airdrop:
    //   leaf0 = keccak256(keccak256(abi.encodePacked(claimant1, 1 ether)))
    //   leaf1 = keccak256(keccak256(abi.encodePacked(claimant2, 0.5 ether)))
    //   root  = keccak256(abi.encodePacked(leaf0, leaf1))  [sorted]
    address claimant1 = makeAddr("claimant1");
    address claimant2 = makeAddr("claimant2");

    bytes32 leaf0;
    bytes32 leaf1;
    bytes32 merkleRoot;

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        // Deploy with 10 ETH seed, threshold = 2
        vault = new EvictionVault{value: 10 ether}(owners, 2);

        // Fund actors
        vm.deal(depositor, 5 ether);
        vm.deal(owner1, 5 ether);

        // Build the 2-leaf Merkle tree used in claim tests
        leaf0 = keccak256(bytes.concat(keccak256(abi.encodePacked(claimant1, uint256(1 ether)))));
        leaf1 = keccak256(bytes.concat(keccak256(abi.encodePacked(claimant2, uint256(0.5 ether)))));

        // Sort leaves so the tree is deterministic
        if (leaf0 <= leaf1) {
            merkleRoot = keccak256(abi.encodePacked(leaf0, leaf1));
        } else {
            merkleRoot = keccak256(abi.encodePacked(leaf1, leaf0));
        }
    }

    // -------------------------------------------------------------------------
    // TEST 1 — Deployment & constructor validation
    // -------------------------------------------------------------------------
    /// @notice Verifies that the vault deploys with correct owners, threshold,
    ///         and initial ETH balance. Also confirms invalid deployments revert.
    function test_DeploymentAndConstructorValidation() public {
        // Correct state after setUp
        assertEq(address(vault).balance, 10 ether);
        assertEq(vault.threshold(), 2);
        assertTrue(vault.isOwner(owner1));
        assertTrue(vault.isOwner(owner2));
        assertTrue(vault.isOwner(owner3));
        assertFalse(vault.isOwner(stranger));
        assertEq(vault.totalVaultValue(), 10 ether);

        // Threshold of 0 should revert
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = owner2;

        vm.expectRevert(abi.encodeWithSelector(VaultManager.InvalidThreshold.selector));
        new EvictionVault(owners, 0);

        // Threshold exceeding owner count should revert
        vm.expectRevert(abi.encodeWithSelector(VaultManager.InvalidThreshold.selector));
        new EvictionVault(owners, 3);

        // Empty owners array should revert
        address[] memory empty = new address[](0);
        vm.expectRevert(abi.encodeWithSelector(VaultManager.NoOwners.selector));
        new EvictionVault(empty, 1);
    }

    // -------------------------------------------------------------------------
    // TEST 2 — Deposit and balance tracking
    // -------------------------------------------------------------------------
    /// @notice Any address can deposit ETH via deposit() or plain transfer,
    ///         and balances are tracked correctly.
    function test_DepositUpdatesBalancesAndTotalVaultValue() public {
        uint256 balanceBefore = vault.totalVaultValue();

        // deposit() call
        vm.prank(depositor);
        vault.deposit{value: 2 ether}();
        assertEq(vault.balances(depositor), 2 ether);
        assertEq(vault.totalVaultValue(), balanceBefore + 2 ether);

        // Plain ETH transfer via receive()
        vm.prank(owner1);
        (bool ok,) = address(vault).call{value: 1 ether}("");
        assertTrue(ok);
        assertEq(vault.balances(owner1), 1 ether);
        assertEq(vault.totalVaultValue(), balanceBefore + 3 ether);
    }

    // -------------------------------------------------------------------------
    // TEST 3 — Withdraw: any depositor can withdraw their own balance
    // -------------------------------------------------------------------------
    /// @notice Depositors (not just owners) can withdraw up to their balance.
    ///         Non-depositors and over-withdrawals revert correctly.
    function test_WithdrawByDepositorAndAccessControl() public {
        // Depositor funds the vault
        vm.prank(depositor);
        vault.deposit{value: 3 ether}();

        uint256 depositorBalanceBefore = depositor.balance;

        // Depositor withdraws 1 ETH
        vm.prank(depositor);
        vault.withdraw(1 ether);

        assertEq(vault.balances(depositor), 2 ether);
        assertEq(depositor.balance, depositorBalanceBefore + 1 ether);

        // Stranger has no balance — should revert with InsufficientBalance
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(VaultManager.InsufficientBalance.selector));
        vault.withdraw(1 ether);

        // Over-withdrawal should also revert
        vm.prank(depositor);
        vm.expectRevert(abi.encodeWithSelector(VaultManager.InsufficientBalance.selector));
        vault.withdraw(999 ether);
    }

    // -------------------------------------------------------------------------
    // TEST 4 — Multisig transaction: submit → confirm → timelock → execute
    // -------------------------------------------------------------------------
    /// @notice Full happy-path of a multisig transaction. Verifies each stage
    ///         of the lifecycle and that early execution reverts.
    function test_MultisigTransactionLifecycle() public {
        uint256 recipientBefore = stranger.balance;

        // Owner1 submits a 1 ETH transfer to stranger
        vm.prank(owner1);
        vault.submitTransaction(stranger, 1 ether, "");

        uint256 txId = vault.txCount() - 1;

        // Cannot execute yet — only 1 of 2 required confirmations
        vm.expectRevert("Insufficient confirmations");
        vault.executeTransaction(txId);

        // Owner2 confirms → threshold reached → executionTime is set
        vm.prank(owner2);
        vault.confirmTransaction(txId);

        // Cannot execute immediately — timelock hasn't elapsed
        vm.expectRevert("Timelock not elapsed");
        vault.executeTransaction(txId);

        // Warp past the 1-hour timelock
        vm.warp(block.timestamp + 1 hours + 1);

        // Now anyone can execute
        vault.executeTransaction(txId);

        assertEq(stranger.balance, recipientBefore + 1 ether);

        // Cannot execute twice
        vm.expectRevert(abi.encodeWithSelector(TransactionManager.Executed.selector));
        vault.executeTransaction(txId);
    }

    // -------------------------------------------------------------------------
    // TEST 5 — Merkle claim: valid proof succeeds, double claim reverts
    // -------------------------------------------------------------------------
    /// @notice Claimant with a valid proof can claim once. A second attempt
    ///         and a tampered proof both revert.
    function test_MerkleClaimHappyPathAndDoubleClaimPrevention() public {
        // Owner sets the merkle root
        vm.prank(owner1);
        vault.setMerkleRoot(merkleRoot);

        // Build proof for claimant1 (sibling is leaf1)
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = leaf1;

        // Adjust proof order to match sorted tree
        if (leaf0 > leaf1) {
            proof[0] = leaf1; // leaf1 is left sibling
        }

        uint256 balanceBefore = claimant1.balance;

        vm.prank(claimant1);
        vault.claim(proof, 1 ether);

        assertEq(claimant1.balance, balanceBefore + 1 ether);
        assertTrue(vault.claimed(claimant1));

        // Second claim attempt should revert
        vm.prank(claimant1);
        vm.expectRevert(abi.encodeWithSelector(ClaimManager.Claimed.selector));
        vault.claim(proof, 1 ether);

        // Wrong amount in proof should revert for a different address
        bytes32[] memory badProof = new bytes32[](1);
        badProof[0] = leaf0;

        vm.prank(claimant2);
        vm.expectRevert(abi.encodeWithSelector(ClaimManager.InvalidProof.selector));
        vault.claim(badProof, 99 ether); // wrong amount
    }

    // -------------------------------------------------------------------------
    // TEST 6 — Pause: paused vault blocks withdrawals, claims, and submissions
    // -------------------------------------------------------------------------
    /// @notice When paused, all state-changing user operations revert.
    ///         Unpause restores normal operation.
    function test_PauseBlocksOperationsAndUnpauseRestores() public {
        // Fund depositor
        vm.prank(depositor);
        vault.deposit{value: 2 ether}();

        // Owner pauses the vault
        vm.prank(owner1);
        vault.pause();
        assertTrue(vault.paused());

        // Withdraw blocked
        vm.prank(depositor);
        vm.expectRevert(abi.encodeWithSelector(VaultManager.Paused.selector));
        vault.withdraw(1 ether);

        // submitTransaction blocked
        vm.prank(owner1);
        vm.expectRevert(abi.encodeWithSelector(VaultManager.Paused.selector));
        vault.submitTransaction(stranger, 1 ether, "");

        // claim blocked
        bytes32[] memory proof = new bytes32[](1);
        vm.prank(claimant1);
        vm.expectRevert(abi.encodeWithSelector(VaultManager.Paused.selector));
        vault.claim(proof, 1 ether);

        // Unpause and confirm withdraw works again
        vm.prank(owner2);
        vault.unpause();
        assertFalse(vault.paused());

        vm.prank(depositor);
        vault.withdraw(1 ether); // should not revert
        assertEq(vault.balances(depositor), 1 ether);
    }

    // -------------------------------------------------------------------------
    // TEST 7 — Emergency withdraw clears vault balance
    // -------------------------------------------------------------------------
    /// @notice emergencyWithdrawAll sends entire contract balance to the calling
    ///         owner and zeroes totalVaultValue. Non-owners cannot call it.
    function test_EmergencyWithdrawAllByOwnerOnly() public {
        // Depositor adds funds
        vm.prank(depositor);
        vault.deposit{value: 2 ether}();

        uint256 vaultBalance = address(vault).balance; // 12 ETH total
        uint256 owner1Before = owner1.balance;

        // Non-owner cannot call
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(VaultManager.NotOwner.selector));
        vault.emergencyWithdrawAll();

        // Owner drains the vault
        vm.prank(owner1);
        vault.emergencyWithdrawAll();

        assertEq(address(vault).balance, 0);
        assertEq(vault.totalVaultValue(), 0);
        assertEq(owner1.balance, owner1Before + vaultBalance);
    }

    // -------------------------------------------------------------------------
    // TEST 8 — Reentrancy attack on withdraw is blocked
    // -------------------------------------------------------------------------
    /// @notice A malicious contract that tries to re-enter withdraw() during
    ///         the ETH transfer cannot drain more than its deposited balance.
    function test_ReentrancyAttackOnWithdrawIsBlocked() public {
        // Deploy attacker and give it 1 ETH deposited in the vault
        ReentrantAttacker attacker = new ReentrantAttacker(payable(address(vault)));
        vm.deal(address(attacker), 1 ether);

        // The attacker deposits 1 ETH so it has a valid balance
        vm.prank(address(attacker));
        vault.deposit{value: 1 ether}();
        assertEq(vault.balances(address(attacker)), 1 ether);

        uint256 vaultBefore = address(vault).balance;

        // Attack: attacker's receive() will try to re-enter withdraw()
        // The nonReentrant modifier should block this and revert the whole tx
        vm.prank(address(attacker));
        vm.expectRevert(abi.encodeWithSelector(VaultManager.Reentrant.selector));
        attacker.attack();

        // Vault balance should be completely unchanged
        assertEq(address(vault).balance, vaultBefore);
        assertEq(vault.balances(address(attacker)), 1 ether);
    }
}
