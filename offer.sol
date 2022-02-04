// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

contract Offer{
    address owner;
    uint8 tokenIn; // токен, НА который владелец обменивает
    uint8 tokenOut; // токен, КОТОРЫЙ владелец обменивает
    uint8 amountIn; // сколько владелец хочет других токенов за свои
    uint8 amountOut; // сколько владелец готов отдать за токены
    bool isAvailable;
    
    constructor(address _owner, uint8 _tokenIn, uint8 _tokenOut,uint8 _amountIn, uint8 _amountOut){
        owner = _owner;
        tokenIn = _tokenIn;
        tokenOut = _tokenOut;
        amountIn = _amountIn;
        amountOut = _amountOut;
        isAvailable = true;
    }


    modifier onlyAvailable(){
        require(isAvailable == true, "Outdated offer");
        _;
    }

    function setAmountIn(address sender, uint8 _amountIn)public onlyAvailable{
        require(sender == owner);
        amountIn = _amountIn;
    }

    function setAmountOut(address sender, uint8 _amountOut)public onlyAvailable{
        require(sender == owner);
        amountOut = _amountOut;
    }

    function getInfo() public view  returns(uint8[4] memory){
        return [tokenIn, tokenOut, amountIn, amountOut];
    }

    function getOwner() public view  returns(address){
        return owner;
    }

    function closeOffer() public {
        isAvailable = false;
    }

    function getAvailability() public view returns(bool){
        return isAvailable;
    }

}

    interface OfferInterface{
    
    function setAmountIn(address sender, uint8 _amountIn) external;

    function setAmountOut(address sender, uint8 _amountOut) external;

    function getAvailability() external view returns(bool);

    function getInfo() external view returns(uint8[4] memory);

    function getOwner() external view returns(address);

    function closeOffer() external;

}
