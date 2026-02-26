// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract MultiSig{
    uint8 minSignersNeeded;
    uint8 transId;
    address[] public owners;
    struct Transaction{
        uint8 id;
        address receipt;
        uint256 amount;
        bool executed;
        uint8 noOfConfirmation;
    }
    mapping(address=>bool) public isOwner;
    mapping (uint8 => mapping(address=>bool)) public isConfirmed;
    Transaction[] public transactions;

    modifier onlyOwner{
        require(isOwner[msg.sender], "Not the Owner");
        _;
    }


    constructor(address[] memory _owners, uint8 _minSignersNeeded){

        require(_owners.length > 0, "At least one owner required");
        require(_minSignersNeeded > 0 && _minSignersNeeded <= _owners.length, "Invalid number of required confirmations");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        minSignersNeeded = _minSignersNeeded;
        // owners =_owners;
        // minSignersNeeded = _minSignersNeeded;
    }

    function submitTransaction(address _to, uint256 _amount) external onlyOwner{
        require(_to != address(0), "Address Should Not Be Address 0");
        require(_amount >0, "Amount should not be 0");
        transId = transId + 1;
        Transaction memory newTrans = Transaction(transId, _to, _amount,false, 0);

        transactions.push(newTrans);
    }
    function confirmTransaction(uint8 _id) external onlyOwner {
        require(_id > 0 && _id <= transactions.length, "Transaction Doesnt Exist");
        for (uint8 i; i < transactions.length; i++) {
            if(transactions[i].id == _id){
                require(!isConfirmed[transactions[i].id][msg.sender], "Transaction Already Confirmed By User");
                require(!transactions[i].executed, "Transaction already Executed");
                isConfirmed[transactions[i].id][msg.sender]=true;
                transactions[i].noOfConfirmation =  transactions[i].noOfConfirmation + 1;
                break;
            }
        }
    }

    function executeTransaction(uint8 _id) external{

        for (uint8 i; i < transactions.length; i++) {
            if(transactions[i].id == _id){
                require(transactions[i].id <= transactions.length, "Transaction Doesnt Exist");
                require(!transactions[i].executed, "Transaction already Executed");
                require(transactions[i].noOfConfirmation >= minSignersNeeded, "Signatories are below Standard");
    
                transactions[i].executed =  true;
                break;
            }
        }
        
    }

    function getAllTransactions() public view returns (Transaction[] memory) {
        return transactions;
    }
}

