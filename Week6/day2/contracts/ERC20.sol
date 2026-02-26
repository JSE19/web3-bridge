// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract ERC20 {
    string tokenName;
    string tokenSymbol;
    uint8 tokenDecimal;
    // uint256 constant total_supply = 2_000_000_000_000_000_000_000;
    uint256 tokenTotalSupply;
    // mapping(Key => Value ) balances;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    // function getAddress() external view returns (address) {
    //     return address(this);
    // }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimal,
        uint256 _totalSupply
    ) {
        tokenName = _name;
        tokenSymbol = _symbol;
        tokenDecimal = _decimal;
        tokenTotalSupply = _totalSupply;
    }

    function name() external view returns (string memory) {
        return tokenName;
    }

    function symbol() external view returns (string memory) {
        return tokenSymbol;
    }

    function decimals() external view returns (uint8) {
        return tokenDecimal;
    }

    function totalSupply() external view returns (uint256) {
        return tokenTotalSupply;
    }

    function mint(address to, uint256 amount) external {
        balances[to] += amount;
        tokenTotalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function getAddress() external view returns (address) {
        return address(this);
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    // function mint(address _owner, uint256 _amount) external {
    //     require(_owner != address(0), "Can't transfer to address zero");
    //     tokenTotalSupply = tokenTotalSupply + _amount;
    //     balances[_owner] = balances[_owner] + _amount;
    // }

    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success) {
        require(_to != address(0), "Can't transfer to address zero");

        require(_value > 0, "Can't send zero value");

        require(balances[msg.sender] >= _value, "Insufficient funds");

        balances[msg.sender] = balances[msg.sender] - _value;

        balances[_to] = balances[_to] + _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success) {
        require(_to != address(0), "Can't transfer to address zero");

        require(_value > 0, "Can't send zero value");

        require(
            balances[_from] >= _value,
            "allowance is greater than your balance"
        );

        require(
            _value <= allowances[_from][msg.sender],
            "Insufficient allowance"
        );

        balances[_from] = balances[_from] - _value;

        balances[_to] = balances[_to] + _value;

        allowances[_from][msg.sender] = allowances[_from][msg.sender] - _value;

        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success) {
        require(_spender != address(0), "Can't transfer to address zero");

        require(_value > 0, "Can't send zero value");

        require(
            balances[msg.sender] >= _value,
            "allowance is greater than your balance"
        );

        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }
}
