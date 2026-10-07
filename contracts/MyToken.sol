// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MyToken {
    // 분산원장은 storage가 비싸기 때문에 event로 recipt를 받아서 따로 관리한다.
    event Transfer(address indexed from, address indexed to, uint256 value);

    string public name;
    string public symbol;
    uint8 public decimals; // 소수점 아래 몇 자리까지 지원 할건지

    uint256 public totalSupply;
    // 데이터 조회는 transaction을 만들 필요 없이 그냥 조회할 수 있음.
    // 데이터 체크가 중요한 application이면 서로 다른 여러개의 노드에 데이터를 조회해서 모두 같은지 검증 가능
    mapping(address => uint256) public balanceOf;

    constructor(string memory _name, string memory _symbol, uint8 _decimal, uint256 _amount) {
        name = _name;
        symbol = _symbol;
        decimals = _decimal;
        _mint(_amount * 10 ** uint256(decimals), msg.sender); // msg.sender: 이 contract를 배포하는 사람한테 1 MT 토큰을 발행
    }

    function _mint(uint256 amount, address owner) internal {
        totalSupply += amount;
        balanceOf[owner] += amount;

        emit Transfer(address(0), owner, amount);
    }

    function transfer(uint256 amount, address to) external {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }
}
