// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MyToken {
    // 분산원장은 storage가 비싸기 때문에 event로 recipt를 받아서 따로 관리한다.
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed spender, uint256 amount);

    address public owner;
    address public manager;
    string public name;
    string public symbol;
    uint8 public decimals; // 소수점 아래 몇 자리까지 지원 할건지

    uint256 public totalSupply;
    // 데이터 조회는 transaction을 만들 필요 없이 그냥 조회할 수 있음.
    // 데이터 체크가 중요한 application이면 서로 다른 여러개의 노드에 데이터를 조회해서 모두 같은지 검증 가능
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimal,
        uint256 _amount
    ) {
        owner = msg.sender;
        manager = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimal;
        _mint(_amount * 10 ** uint256(decimals), msg.sender); // msg.sender: 이 contract를 배포하는 사람한테 1 MT 토큰을 발행
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized");
        _;
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "You are not authorized to manage this token"
        );
        _;
    }

    function approve(address spender, uint256 amount) external {
        // 먼가 OAuth 인증 같은 느낌임
        allowance[msg.sender][spender] = amount;

        emit Approval(spender, amount);
    }

    // 이러면 owner가 이 함수를 호출하지 못하는데, 그냥 mgr를 배열로 만들고 owner가 자기 자신을 배열에 추가하면 안되는건가?
    function mint(uint256 amount, address to) external onlyManager {
        _mint(amount, to);
    }

    function setManager(address _manager) external onlyOwner {
        manager = _manager;
    }

    function _mint(uint256 amount, address to) internal {
        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    function TransferFrom(address from, address to, uint256 amount) external {
        // 이 함수는 제 3자가 호출함.
        // from: 토큰 소유자
        // to: 토큰을 받는자
        // spender: from의 토큰을 실제로 쓰는 사람(제 3자)
        address spender = msg.sender;
        require(allowance[from][spender] >= amount, "insufficient allowance");
        allowance[from][spender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        
        emit Transfer(from, to, amount);
    }

    function transfer(uint256 amount, address to) external {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }
}

/*
approve
    - allow spender address to send my token
transferFrom
    - spender: owner -> target address

* token owner --> bank contract
* token owenr --> router contract --> bank contract
* token owner --> router contract --> bank contract(multi contract)
*/