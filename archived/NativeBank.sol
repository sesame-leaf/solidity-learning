// SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;

contract NativeBank {
    mapping(address => uint256) public balanceOf;
    bool lock;

    // 이 modifier를 가지는 함수는 동시에 실행중인 상태가 될 수 없음
    // TODO: noreentrancy modifier를 가지는 abstract contract 만들기
    modifier noreentrancy {
        require(!lock, "is now working on");
        lock = true;
        _;
        lock = false;
    }

    function withdraw() external noreentrancy {
        uint256 balance = balanceOf[msg.sender];
        require(balance > 0, "insufficient balance");

        (bool success,) = msg.sender.call{value:balance}("");
        require(success, "failed to send native token");

        balanceOf[msg.sender] = 0;
    }

    receive() payable external {
        balanceOf[msg.sender] += msg.value;
    }
}