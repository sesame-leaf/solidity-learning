// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract ManagedAccess {
    address public owner;
    address[] public managers;
    mapping(address => bool) public confirmed;

    constructor(address _owner, address _manager) {
        owner = _owner;
        managers.push(_manager);
    }

    function isManager(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < managers.length; i++) {
            if (managers[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    function allConfirmed() public view returns (bool) {
        for (uint256 i = 0; i < managers.length; i++) {
            if (!confirmed[managers[i]]) {
                return false;
            }
        }
        return true;
    }

    function confirm() external {
        require(isManager(msg.sender), "You are not a manager");
        confirmed[msg.sender] = true;
    }

    function setManager(address _manager) external onlyAllConfirmed {
        managers.push(_manager);
    }

    modifier onlyAllConfirmed() {
        require(isManager(msg.sender), "You are not a manager");
        require(allConfirmed(), "Not all confirmed yet");
        // 실행 후 다음 작업을 위해 모든 confirm을 초기화
        for (uint256 i = 0; i < managers.length; i++) {
            confirmed[managers[i]] = false;
        }
        _;
    }

    modifier onlyManager() {
        require(
            isManager(msg.sender),
            "You are not authorized to manage this contract"
        );
        _;
    }
}
