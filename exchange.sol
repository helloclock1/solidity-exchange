// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

interface iDodgeCoin{
    function balanceOf(address adr) external view returns(uint);
    function transferTo(address from, address to, uint tokens) external payable;  
}

interface iBeatCoin{
    function balanceOf(address adr) external view returns(uint);
    function transferTo(address from, address to, uint tokens) external payable;  
}

contract Exchange{
    address owner;
    uint8 current_coin;
    // 1 - DodgeCoin, 2 - BeatCoin

    struct offer{
        address owner;
        uint8 tokenIn;
        uint8 tokenOut;
        uint8 amountOut;
        int ratio; // получается соотношение курса входящего токена к исходящему. так например если выставить 5 токенов с рейтом 3,  
        // они обменяются на 5 * 3 монет, т.е. 15
    }

    iDodgeCoin DodgeCoin;
    iBeatCoin BeatCoin;
    
    constructor(){
        current_coin = 1;
        DodgeCoin = iDodgeCoin(0xf428f3281b45E1CA109Cac1072b476706D170CCc);
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function get_current_coin() public view returns(string memory){
        if (current_coin == 1){
            return "DodgeCoin";
        }
        else if (current_coin == 2){
            return "BeatCoin";
        }
        else{
            return "Error occured";
        }
    }

    function select_DodgeCoin() public{
        current_coin = 1;
    }

    function select_BeatCoin() public{
        current_coin = 2;
    }

    function DC_Transfer(address adr, uint tokens) public{
        DodgeCoin.transferTo(msg.sender, adr, tokens);
    }

    function DC_BalanceOf()public view returns(uint256){
        return DodgeCoin.balanceOf(msg.sender);
    } 

    function DC_BalanceOf(address adr) public view returns(uint256){
        return DodgeCoin.balanceOf(adr);
    }

}
