//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;
interface IERC20{
    function transfer(address _to, uint256 _value) external returns(bool success);
    function balanceOf(address _owner) external view returns(uint256 balance);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}
contract Portal{

    IERC20 public paymentToken;
    struct Stud{
        uint8 id;
        string name;
        uint16 level;
    }
    Stud[] public students;
    uint8 studentId;
    mapping(uint16=>uint256) public levels;

    struct Staff{
        uint8 id;
        string name;
        address acct;
    }

    Staff[] public staff;
    uint8 staffId;
    uint256 private SALARY = 200e18;
    
    
    address owner;
    
    constructor(address _tokenAddress){
        levels[100] = 3000e18;
        levels[200] = 5000e18;
        levels[300] = 7000e18;
        levels[400] = 9000e18;
        owner = msg.sender;
        paymentToken = IERC20(_tokenAddress);

    }

    function createStaff(string memory _name, address _acct ) external{
        staffId = staffId + 1;

        require(_acct != address(0) , "Account Must Not be 0");
        Staff memory newStaff = Staff(staffId, _name,_acct);

        staff.push(newStaff);
    }

    function getAllStaff() external view returns(Staff[] memory){
        return staff;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not Owner");
        _;
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

    function CreateStudent(string memory _name, uint16 _level) external{
        require(_level == 100 || _level == 200 || _level == 300 || _level == 400, "Invalid level: must be 100, 200, 300, or 400");

        uint256 fees = levels[_level];
        require(fees>0, "No fees set");

        bool success = paymentToken.transferFrom(msg.sender, address(this), fees);
        require(success, "Fee payment failed");

        studentId = studentId + 1;
        Stud memory student = Stud({
            id: studentId,
            name: _name,
            level: _level
        });

        students.push(student);

    }
    function getAllStudents() external view returns (Stud[] memory) {
        return students;
    }
    
}