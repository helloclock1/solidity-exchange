// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;
import "./offer.sol";

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

    address[] offers;

    iDodgeCoin DodgeCoin;
    iBeatCoin BeatCoin;
    
    constructor(){
        current_coin = 1;
        DodgeCoin = iDodgeCoin(0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3);
        BeatCoin = iBeatCoin(0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99);
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

    function DC_BalanceOf()internal view returns(uint256){
        return DodgeCoin.balanceOf(msg.sender);
    } 

    function DC_BalanceOf(address adr) internal view returns(uint256){
        return DodgeCoin.balanceOf(adr);
    }

    function BC_BalanceOf()internal view returns(uint256){
        return BeatCoin.balanceOf(msg.sender);
    } 

    function BC_BalanceOf(address adr) internal view returns(uint256){
        return BeatCoin.balanceOf(adr);
    }

    function getBalanceByToken(address adr, uint8 token)internal returns(uint256){
        if (token == 1){
            return DC_BalanceOf(adr);
        }
        else if (token == 2){
            return BC_BalanceOf(adr);
        }
    }

    function createOffer(uint8 _tokenIn, uint8 _tokenOut,uint8 _amountIn, uint8 _amountOut)public returns(address){ 
        require(( 0 < _tokenIn) && (_tokenIn < 3));
        require(( 0 < _tokenOut) && (_tokenOut < 3));
        require(getBalanceByToken(msg.sender, _tokenOut) >= _amountOut);

        Offer offer = new Offer(msg.sender, _tokenIn, _tokenOut, _amountIn,  _amountOut);
        offers.push(address(offer));
        return address(offer);
    }


    // пока заморожено, легче смотреть баланс через MetaMask
    // function getMyBalance()public returns(uint256){
    //     uint256 balance = getBalanceByToken(msg.sender, current_coin);
    //     return balance;
    // }

}
