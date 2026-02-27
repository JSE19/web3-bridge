//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.3;

contract MultiSig{
    uint8 transIdCount;
    uint8 minNoOfSignersNeeded;
    
    struct Transaction{
        uint8 id;
        address to;
        uint256 amount;
        bool executed;
        uint8 noOfSigners;
    }

    Transaction[] public transactions;
    address[] public signers;

    mapping(address=>bool) public isOwner;
    mapping(uint8=>mapping(address=>bool)) public isConfirmed;
    mapping(address=>uint256) public balances;

    event TransactionSubmited(uint8 id, address indexed to, uint256 amount);
    event TransactionConfirmedAndSigned(uint8 id, address indexed _confirmer);
    event TransactionExecuted(uint8 id);

    
    error NotASignatory(uint8 id);
    error InvalidTransactionId(uint8 id);
    error AlreadyConfirmedByYou(uint8 id);
    error NotAnOwner();
    error AmountShouldNotBeZero();
    error AddressZeroNotAValidAddress();
    error AlreadyAnOwner();
    error TransactionAlreadyExecuted()
    error MinOfOneSignerNeeded();
    error InsufficientBalance();
    error RequiredMinimumSignersMustNotBeGreaterThanTotalSignatoriesNeeded();

    constructor(address[] memory _signers, uint8 _minNoOfSignersNeeded){
        if(_signers.length <= 0) {
            revert MinOfOneSignerNeeded()
        }
        if(_minNoOfSignersNeeded <=0 && _minNoOfSignersNeeded > _signers.length){
            revert RequiredMinimumSignersMustNotBeGreaterThanTotalSignatoriesNeeded();
        }

        for(uint8 i; i<_signers.length; i++){
            address signer = _signers[i];
            if(signer == address(0)){
                revert AddressZeroDetected();
            }
            if(isOwner[signer] == true){
                revert AlreadyAnOwner();
            }
            isOwner[signer] = true;
            signers.push(signer);
        }
        minNoOfSignersNeeded = _minNoOfSignersNeeded;
    }

    modifier onlyOwner{
        if(!isOwner[msg.sender]){
            revert NotAnOwner();
        }
    }

    function createTransaction(address _to, uint256 _amount) public external onlyOwner() returns (bool){
        if(_to == address(0)){
            revert AddressZeroNotAValidAddress();
        }
        if(_amount < 0){
            revert AmountShouldNotBeZero();
        }
        if(balances[msg.sender] < _amount){
            revert InsufficientBalance();
        }

        Transaction memory newTrans = Transaction(transIdCount, _to, _amount, false, 0);
        transactions.push(newTrans);

        transIdCount = transIdCount + 1;

        return true

    }

    function confirmTransaction(uint8 _id) public external onlyOwner returns(bool){
        require(_id > 0 && _id <= transactions.length, InvalidTransactionId(_id) );

        Transaction storage trans = transactions[_id];
        require(!isConfirmed[_id][msg.sender], AlreadyConfirmedByYou(_id));
        require(!trans.executed, TransactionAlreadyExecuted());

        isConfirmed[_id][msg.sender] =true;
        trans[_id].noOfConfirmation = trans[_id].noOfConfirmation + 1;

        if()
    }
}