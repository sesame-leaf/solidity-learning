// deposit(MyToken) / withdraw(MyToken)

// MyToken : token balance management
// - the balance of TinyBank address
// TinyBank : deposit / withdraw vault
// - users token management
// - user --> deposit --> TinyBank --> transfer(user --> TinyBank)
// - deposit이 MyToken의 transfer를 wrapping 하는 느낌인듯?

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMyToken {
    function transfer(uint256 amount, address to) external;
    
    function TransferFrom(address from, address to, uint256 amount) external;
}

contract TinyBank {
    event Staked(address from, uint256 amount);
    event Withdraw(uint256 amount, address to);

    IMyToken public stakingToken;
    mapping(address => uint256) public staked;
    uint256 public totalStaked; // TinyBank의 자산

    constructor(IMyToken _stakingToken) {
        // 반드시 TinyBank contract는 staking 할 Token을 먼저 배포한 후 
        // 그 주소를 constructor의 인수로 주어야 함.
        stakingToken = _stakingToken;
    }

    function stake(uint256 _amount) external {
        require(_amount >= 0, "cannot stake 0 amount");
        // transfer는 내부적으로 msg.sender의 balance를 확인함.
        // msg.sender는 TinyBank의 주소임.
        // (transfer는 이 함수 안에서 호출하고, 이 함수는 TinyBank가 호출하는거임)
        // 하지만 이 함수는 stake를 호출한 user의 balance를 확인해야 함.
        // 즉, transfer를 사용하면 안됨.
        stakingToken.TransferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;

        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(staked[msg.sender] >= _amount, "insufficient staked token");
        stakingToken.transfer(_amount, msg.sender);
        staked[msg.sender] -= _amount;
        totalStaked -= _amount;

        emit Withdraw(_amount, msg.sender);
    }
}
