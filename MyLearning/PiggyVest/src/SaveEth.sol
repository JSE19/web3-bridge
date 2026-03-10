//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract SaveEth {
    uint256 public totalSaves;
    uint256 public penalty = 5;
    uint256 public profit = 3;

    address public owner;
    struct Save {
        uint256 amount;
        uint256 lockPeriod;
        uint256 timeLocked;
        string purpose;
        bool isWithdrawn;
    }

    mapping(address => Save[]) public mySaves;
    //mapping(address=>uint256) public balances;

    error Address0NotAllowed();
    error GreaterThan0();
    error InsufficientBalance();
    error Failed();
    error LockPeriodMustBeFutureDate();
    error WithdrawnAlready();

    event Deposited(address indexed, uint256 amount);
    event Withdrawn(address indexed, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function deposit(
        uint256 _lockPeriod,
        string memory _purpose
    ) public payable {
        require(msg.value > 0, GreaterThan0());
        require(_lockPeriod > 1, LockPeriodMustBeFutureDate());
        //balances[msg.sender] += msg.value;
        uint256 lockSecs = _lockPeriod * 1 days;
        totalSaves += msg.value;
        Save memory newSave = Save(
            msg.value,
            lockSecs,
            block.timestamp,
            _purpose,
            false
        );
        mySaves[msg.sender].push(newSave);

        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 _saveIndex) public returns (bool) {
        Save storage save = mySaves[msg.sender][_saveIndex];

        require(!save.isWithdrawn, WithdrawnAlready());
        bool ready = block.timestamp >= save.timeLocked + save.lockPeriod;

        if (ready) {
            save.isWithdrawn = true;
            totalSaves -= save.amount;

            uint256 interest = (save.amount * profit) / 100;
            uint pay = save.amount + interest;

            (bool success, ) = payable(msg.sender).call{value: pay}("");

            require(success, Failed());

            emit Withdrawn(msg.sender, pay);
        } else {
            save.isWithdrawn = true;
            totalSaves -= save.amount;

            uint256 deduct = (save.amount * penalty) / 100;
            uint pay = save.amount - deduct;

            (bool ownerSuccess, ) = payable(owner).call{value: deduct}("");
            require(ownerSuccess, Failed());

            (bool userSuccess, ) = payable(msg.sender).call{value: pay}("");
            require(userSuccess, Failed());

            emit Withdrawn(msg.sender, pay);
        }
    }

    function getTotalSaves() public view returns (uint256){
        return totalSaves;
    }

    function getUserSaves() public view returns(Save[] memory){
        return mySaves[msg.sender];
    }

    receive() external payable {}

    fallback() external payable {}
}
