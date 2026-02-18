// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ERC_20 {
    string tokenName = "RAJ-Token";
    string tokenSymbol = "RAJ";
    uint8 tokenDecimal = 18;
    uint256 tokenTotalSupply;
 
    //Mapping
    mapping(address => uint256) balances;
    mapping(address=>mapping(address=>uint256)) private myAllowance;

    // Events
    event Transfer(address indexed sender, address indexed receiver, uint256 amount);
    event Approval(address owner, address spender, uint256 value);

    // constructor(string memory _name, string memory _symbol, uint8 _decimal, uint256 _supply){
    //     tokenName = _name;
    //     tokenSymbol = _symbol;
    //     tokenDecimal = _decimal;
    //     tokenTotalSupply = _supply;
    // }



    function name() public view returns(string memory) {
        return tokenName;
    }

    function symbol() public view returns(string memory){
        return tokenSymbol;
    }

    function decimals() public view returns(uint8){
        return tokenDecimal;
    }

    function totalSupply() public view returns(uint256){
        return tokenTotalSupply;
    }

    function balanceOf(address _owner) public view returns(uint256 balance){
        require(_owner != address(0), "Owner shouldn't be Address 0");
        return balances[_owner]; 
    }

    function transfer(address _to, uint256 _value) public returns(bool success){
        require(_to != address(0), "Address should not be address 0");
        require(balances[msg.sender] >= _value, "Value must not be greater than your balance");

        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;

        emit Transfer(msg.sender, _to, _value);

        return true;

    }

    function transferFrom(address _from,address _to, uint256 _value) public returns(bool){
        
        require(_from != address(0) && _to != address(0) ,"Address Shouldn't be Address 0");
        require(_value <= balances[_from], "Insufficient balance");
        require(_value <= myAllowance[_from][msg.sender], "Value must not be more than Allowance");

        myAllowance[_from][msg.sender] = myAllowance[_from][msg.sender] - _value;
        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;

        emit Transfer(_from, _to, _value);

        return true;


    }

    function approve(address _spender, uint256 _value) public returns(bool){
        require(_spender!= address(0), "Spender should not be address 0");

        myAllowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender,_value);

        return true;

    }

    function allowance(address _owner, address _spender) public view returns(uint256){
        return myAllowance[_owner][_spender];
    }

    function mint(uint _amount) public {
        balances[msg.sender] = balances[msg.sender] + _amount;
        tokenTotalSupply = tokenTotalSupply + _amount;

    }


}
