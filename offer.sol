// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

contract Offer{
    address owner;
    uint8 tokenIn; // токен, НА который владелец обменивает
    uint8 tokenOut; // токен, КОТОРЫЙ владелец обменивает
    uint8 amountIn; // сколько владелец хочет других токенов за свои
    uint8 amountOut; // сколько владелец готов отдать за токены
    

    constructor(address _owner, uint8 _tokenIn, uint8 _tokenOut,uint8 _amountIn, uint8 _amountOut){
        owner = _owner;
        tokenIn = _tokenIn;
        tokenOut = _tokenOut;
        amountIn = _amountIn;
        amountOut = _amountOut;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function setAmountIn(uint8 _amountIn)public onlyOwner{
        amountIn = _amountIn;
    }

    function setAmountOut(uint8 _amountOut)public onlyOwner{
        amountOut = _amountOut;
    }
}
