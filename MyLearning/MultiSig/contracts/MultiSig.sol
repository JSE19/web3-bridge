//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract MultiSig{
    uint8 transIdCount;
    uint8 minNoOfSignersNeeded;
    
    struct Transaction{
        uint8 id;
        address payable to;
        address initiator;
        uint256 amount;
        bool executed;
        bool isCanceled;
        uint8 noOfConfirmation;
    }

    Transaction[] public transactions;
    address[] public signers;

    mapping(address=>bool) public isOwner;
    mapping(uint8=>mapping(address=>bool)) public isConfirmed;
    mapping(address=>uint256) public balances;

    event TransactionSubmited(uint8 id, address indexed to, uint256 amount);
    event TransactionConfirmedAndSigned(uint8 id, address indexed _confirmer);
    event TransactionExecuted(uint8 id, address indexed _recipient, uint256 _amount);

    
    error NotASignatory(uint8 id);
    error InvalidTransactionId(uint8 id);
    error AlreadyConfirmedByYou(uint8 id);
    error NotAnOwner();
    error AmountShouldNotBeZero();
    error AddressZeroNotAValidAddress();
    error AlreadyAnOwner();
    error TransactionAlreadyExecuted();
    error MinOfOneSignerNeeded();
    error InsufficientBalance();
    error RequiredMinimumSignersMustNotBeGreaterThanTotalSignatoriesNeeded();
    error MoreSignersNeedToConfirmThisTransactionFirst();
    error TransactionFailed();

    constructor(address[] memory _signers, uint8 _minNoOfSignersNeeded){
        require(_signers.length >0,MinOfOneSignerNeeded());
        
        require(_minNoOfSignersNeeded > 0 && _minNoOfSignersNeeded < _signers.length, RequiredMinimumSignersMustNotBeGreaterThanTotalSignatoriesNeeded());
        
        
        for(uint8 i=1; i<_signers.length; i++){
            address signer = _signers[i];
            require(signer != address(0), AddressZeroNotAValidAddress());
            require(!isOwner[signer], AlreadyAnOwner());
            
            isOwner[signer] = true;
            signers.push(signer);
        }
        signers.push(msg.sender);
        isOwner[msg.sender] = true;
        minNoOfSignersNeeded = _minNoOfSignersNeeded;
    }

    modifier onlyOwner{
        require(isOwner[msg.sender], NotAnOwner());
        _;
        
    }

    function createTransaction(address _to, uint256 _amount) public  onlyOwner() returns (bool){
        require(_to != address(0), AddressZeroNotAValidAddress());
        require(_amount > 0, AmountShouldNotBeZero());
        require(msg.value = _amount)
        Transaction memory newTrans = Transaction(transIdCount, _to, msg.sender, _amount, false, false, 0);
        transactions.push(newTrans);

        emit TransactionSubmited(transIdCount, _to, _amount);

        transIdCount = transIdCount + 1;

        return true;

    }

    function cancelTransaction(uint8 _id) external returns(bool success){
        require(_id>0 && _id < transactions.length, InvalidTransactionId());
        Transaction storage trans = transactions[_id];
    }

    function confirmTransaction(uint8 _id) external onlyOwner returns(bool success){
        require(_id > 0 && _id < transactions.length, InvalidTransactionId(_id) );

        Transaction storage trans = transactions[_id];
        require(!isConfirmed[_id][msg.sender], AlreadyConfirmedByYou(_id));
        require(!trans.executed, TransactionAlreadyExecuted());

        isConfirmed[_id][msg.sender] =true;
        trans.noOfConfirmation = trans.noOfConfirmation + 1;

        emit TransactionConfirmedAndSigned(_id, msg.sender);

        return success;
    }

    function executeTransaction(uint8 _id) external onlyOwner {
        require(_id < transactions.length, InvalidTransactionId(_id));

        Transaction storage trans = transactions[_id];

        require(!trans.executed, TransactionAlreadyExecuted());

        require(trans.noOfConfirmation >= minNoOfSignersNeeded, MoreSignersNeedToConfirmThisTransactionFirst());

        require(address(this).balance >= trans.amount, InsufficientBalance());

        trans.executed = true;

        (bool success, ) = trans.to.call{value: trans.amount}("");

        require(success, TransactionFailed());
        emit TransactionExecuted(_id, trans.to, trans.amount);

    }

    function getAllExecutedTransactions() public view returns (Transaction[] memory) {
        
        uint8 count;
        for(uint8 i; i<transactions.length; i++){
            if(transactions[i].executed == true){
                count++;
            }
        }

        Transaction[] memory executionCompleted = new Transaction[](count);

        uint8 index = 0;
        for(uint8 i; i<transactions.length; i++){
            if(transactions[i].executed == true){
                executionCompleted[index] = transactions[i];
                index++;
            }
        }

        return executionCompleted;
    }

    function getIncompleteConfirmedTransactions() public view returns(Transaction[] memory){
        uint8 count;
        for(uint8 i; i<transactions.length; i++){
            if(transactions[i].noOfConfirmation < minNoOfSignersNeeded){
                count++;
            }
        }

        Transaction[] memory pendingComplete = new Transaction[](count);

        uint8 index = 0;
        for(uint8 i; i<transactions.length; i++){
            if(transactions[i].noOfConfirmation < minNoOfSignersNeeded){
                pendingComplete[index] = transactions[i];
                index++;
            }
        }

        return pendingComplete;
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }


    receive() external payable{}
}