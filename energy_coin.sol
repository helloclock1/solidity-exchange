// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

contract EnergyCoin{
    string constant name = "EnergyCoin";
    string constant symbol = "EC";
    uint8 constant decimals = 10;
    uint totalSupply;
    address owner;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function balanceOf(address adr) public view returns(uint){
        return balances[adr];
    }

    function mint(address adr, uint value) public onlyOwner{
        totalSupply += value;
        balances[adr] += value;
    }

    function transferTo(address from, address to, uint tokens) public{
        require(balances[from] >= tokens);
        balances[from] -= tokens;
        balances[to] += tokens;
    }

    function freeCoin(address sender) public{
        totalSupply += 1;
        balances[sender] += 1;
    }

}
