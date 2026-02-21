// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Todo {
    struct Task {
        uint8 id;
        string title;
        bool isComplete;
        uint timeCompleted;
    }

    Task[] public tasks;
    uint8 public todoId;

    function createTask(string memory _title) external {
        todoId = todoId + 1;
        Task memory newTask = Task(todoId, _title, false, 0);
        //Or
        // Task memory newTask = Task({
        //     id: todoId,
        //     title: _title,
        //     isComplete: false,
        //     timeCompleted: 0
        // });
        tasks.push(newTask);
    }

    function markComplete(uint8 _id) external {
        for (uint8 i = 0; i < tasks.length; i++) {
            if (tasks[i].id == _id) {
                tasks[i].isComplete = true;
                tasks[i].timeCompleted = block.timestamp;
            }
        }
    }

    function getAllTasks() external view returns (Task[] memory) {
        return tasks;
    }

    function updateTask(uint8 _id, string memory _title) external{
        for(uint8 i=0; i<tasks.length; i++){
            if(tasks[i].id == _id){
                tasks[i].title = _title;
            }
        }
    }

    function deleteTask(uint8 _id) external {
        for (uint8 i = 0; i < tasks.length; i++) {
            if (tasks[i].id == _id) {
                tasks[i] = tasks[tasks.length - 1];
                tasks.pop();
            }
        }
    }
}
