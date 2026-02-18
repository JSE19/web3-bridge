// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract StudentReg {
    struct Student {
        string name;
        uint age;
        bool present;
    }

    Student[] public students;

    event StudentAdded(string name, uint age);
    event AttendanceUpdated(uint index, bool isPresent);

    function addStudent(string memory _name, uint _age) public {
        students.push(Student(_name, _age, false));
        emit StudentAdded(_name, _age);
    }

    function markAttendance(uint _index) public {
       
        require(_index < students.length, "Student does not exist.");

        students[_index].present = !students[_index].present;
        emit AttendanceUpdated(_index, students[_index].present);
    }

    function getStudentCount() public view returns (uint) {
        return students.length;
    }
}
