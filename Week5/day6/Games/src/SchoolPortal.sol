// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {IERC20} from "./IERC20.sol";

contract SchoolPortal{

    IERC20 public paymentToken;
    struct Stud{
        uint8 id;
        string name;
        uint16 level;
        string email;
        uint256 createdAt;
    }
    Stud[] public students;
    uint8 studentId;
    mapping(uint16=>uint256) public levels;
    mapping(string=>bool) public isStud;

    struct Staff{
        uint8 id;
        string name;
        address acct;
        bool isSuspended;
        uint256 createdAt;
    }
    

    Staff[] public staff;
    uint8 staffId;
    uint256 private SALARY = 200e18;
    mapping(address=>bool) public isStaff;


    address owner;
    uint private ETHEREQUIVRAJ = 20000;
    
    constructor(address _tokenAddress){
        levels[100] = 3000e18;
        levels[200] = 5000e18;
        levels[300] = 7000e18;
        levels[400] = 9000e18;
        owner = msg.sender;
        paymentToken = IERC20(_tokenAddress);

    }


    modifier onlyOwner(){
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function convertEtherToRaj() external payable {
        uint convert = msg.value * ETHEREQUIVRAJ;
        require(paymentToken.balanceOf(address(this)) >= convert) ;
        paymentToken.transfer(msg.sender, convert);
    }

    // function convertRajToEther(uint _amount) external payable {
    //     uint convert = _amount * (1/ETHEREQUIVRAJ);
    //     require(balances[msg.sender] >= _amount, "Insufficient Balance");
    //     paymentToken.transfer(msg.sender, convert);
        
    // }


    //STAFF
    function createStaff(string memory _name, address _acct) external onlyOwner(){
        require(!isStaff[_acct], "Staff Exists");
        staffId = staffId + 1;

        require(_acct != address(0) , "Account Must Not be 0");
        Staff memory newStaff = Staff(staffId, _name,_acct, false, block.timestamp);

        staff.push(newStaff);

        isStaff[_acct]=true;
    }

    function getAllStaff() external view returns(Staff[] memory){
        return staff;
    }

    function getStaffById(uint8 _id) external view returns (Staff memory) {
        for(uint8 i; i<staff.length; i++){
            if(staff[i].id == _id){
                return staff[i];
            }
        }
    }


    function payStaff(uint8 _id) external onlyOwner() {
        for(uint8 i=0;i<staff.length; i++){
            if(staff[i].id == _id){
                //staffBalance[staff[i].acct] = balanceOf(staff[i].acct)
                require(paymentToken.balanceOf(address(this)) >= SALARY, "Insufficient Funds");
                paymentToken.transfer(staff[i].acct, SALARY);
                break;

            }
        }

    }

    function updateStaff(uint8 _id, string memory _name, address _acct) external returns (bytes32){
        bytes32 isFound;
        for(uint8 i; i<staff.length; i++){
            if(staff[i].id == _id){
                isFound = "Staff Found";
                if(bytes(_name).length >0){
                    staff[i].name = _name;
                }
                if(_acct != address(0)){
                    require(!isStaff[_acct], "Address Exists For Another Staff");
                    staff[i].acct = _acct;
                    isStaff[_acct] = true;
                }
                break;
            }
        }

        return isFound; 
    }

    function suspendStaff(uint8 _id) external{
        for(uint8 i; i<staff.length; i++){
            if(staff[i].id == _id){
                require(!staff[i].isSuspended, "Staff Already Suspended");
                staff[i].isSuspended= true;                
            }
        }
    }

    function revertStaffSuspension(uint8 _id) external{
        for(uint8 i; i<staff.length; i++){
            if(staff[i].id == _id){
                require(staff[i].isSuspended, "Staff Not Suspended Before");
                staff[i].isSuspended= false;                
            }
        }
    }





    //STUDENT
    function CreateStudent(string memory _name, uint16 _level, string memory _email) external{
        require(!isStud[_email],"Student Already Exists");
        require(_level == 100 || _level == 200 || _level == 300 || _level == 400, "Invalid level: must be 100, 200, 300, or 400");

        uint256 fees = levels[_level];
        require(fees>0, "No fees set");

        //bool success = paymentToken.transferFrom(msg.sender, address(this), fees);
        bool success = paymentToken.transferFrom(msg.sender,address(this), fees);
        require(success, "Fee payment failed");

        studentId = studentId + 1;
        Stud memory student = Stud(studentId, _name,_level,_email,block.timestamp);

        students.push(student);
        isStud[_email] = true;

    }
    function getAllStudents() external view returns (Stud[] memory) {
        return students;
    }

    function studentById(uint8 _id) external view returns (Stud memory) {
        for(uint8 i; i<students.length;i++){
            if(students[i].id == _id){
                return students[i];
            }
        }
    }

    function updateStudent(uint8 _id, string memory _name, string memory _email) external returns(bytes32)  {
        bytes32 isFound;
        for(uint8 i; i<students.length; i++){
            if(students[i].id == _id){
                isFound = "Stud Found";
                if(bytes(_name).length >0){
                    students[i].name = _name;
                }

                if(bytes(_email).length > 0){
                    students[i].email = _email;
                }
            }
            
        }
        return isFound;
    }

    function deleteStudent(uint8 _id) external {
        for(uint8 i; i<students.length; i++){
            if(students[i].id == _id){
                students[i] = students[students.length-1];
                students.pop();
            }
        }
    }
    receive() external payable {}
    fallback() external {}
    
}