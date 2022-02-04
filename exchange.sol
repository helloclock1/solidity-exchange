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
    // 1 - DodgeCoin, 2 - BeatCoin

    address[] offers;

    iDodgeCoin DodgeCoin;
    iBeatCoin BeatCoin;
    
    constructor(){
        DodgeCoin = iDodgeCoin(0xd9145CCE52D386f254917e481eB44e9943F39138);
        BeatCoin = iBeatCoin(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function getTokensInfo() public pure returns(string memory){
        string memory info = "Current coin identeficators:   1 - DodgeCoin   2 - BeatCoin";
        return info;
    }
    
    function offerInfo(address adr) public view returns(uint8[4] memory){
        // возвращает данные оффера, где [id входящего токена, id исходящего токена, количество входящих токенов, количество исходящих токенов]
        // может не лучший вариант, но в пол 3 ночи лучшего способа на ум не пришло
        // позже нужно будет улучшить
        return OfferInterface(adr).getInfo();
    }

    function getAllOffers() public view returns(address[] memory){
        return offers;
    }

    function setOfferInfo(uint8 IncomingAmount, uint8 OutcomingAmount, address adr) public {
        OfferInterface(adr).setAmountIn(IncomingAmount);
        OfferInterface(adr).setAmountOut(OutcomingAmount);
    }

    function DC_Transfer(address adr, uint tokens) internal{
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

    function getBalanceByToken(address adr, uint8 token)internal view returns(uint256){
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
