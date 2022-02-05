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
    function freeCoin(address sender) external;
}

interface iEnergyCoin{
    function balanceOf(address adr) external view returns(uint);
    function transferTo(address from, address to, uint tokens) external payable;
    function freeCoin(address sender) external;
}

interface iCasino{
    function adequateRoulette(uint _bet, uint _amount, uint8 _tokenUsed) external returns(string memory);
    function russianRoulette(uint _bet, uint _seed, uint8 _tokenUsed) external returns(string memory);
    function unevenRussianRoulette(uint _bet, uint _seed, uint8 _tokenUsed) external returns(string memory);
    function blackjack(uint _bet, uint _seed, uint8 _tokenUsed) external returns(string memory);
}

contract Exchange{
    address owner;
    // 1 - DodgeCoin, 2 - BeatCoin, 3 - EnergyCoin

    address[] offers;

    iDodgeCoin DodgeCoin;
    iBeatCoin BeatCoin;
    iEnergyCoin EnergyCoin;
    iCasino Casino;

    constructor(){
        EnergyCoin = iEnergyCoin(0x599DB3Ffbba36FfaAB3f86e92e1fCA0465b2CDeA);
        DodgeCoin = iDodgeCoin(0x07Cb88b1d6E06a5fd54Ae8d4A71713BF822f4389);
        BeatCoin = iBeatCoin(0x8451961927D8E8867032Fe0Bb1F6AC33956Ce450); // НЕ ЗАБУДЬ ПОМЕНЯТЬ АДРЕСА ПРИ ДЕПЛОЕ!
        Casino = iCasino(someAddress);
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function getTokensInfo() public pure returns(string memory){
        string memory info = "Current coin identeficators:   1 - DodgeCoin   2 - BeatCoin   3 - EnergyCoin";
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

    function transferByCoin(address from, address to, uint tokens, uint8 token) internal{
        require(( 0 < token) && (token < 4), "No such coin");
        if (token == 1){
            DodgeCoin.transferTo(from, to, tokens);
        }
        else if (token == 2){
            BeatCoin.transferTo(from, to, tokens);
        }
        else if (token == 3){
            EnergyCoin.transferTo(from, to, tokens);
        }
    }

    function freeBeatCoin() public{
        BeatCoin.freeCoin(msg.sender);
    }

    function freeEnergyCoin() public{
        EnergyCoin.freeCoin(msg.sender);
    }

    function acceptOffer(address adr) public{
        uint8[4] memory info = OfferInterface(adr).getInfo();
        require(OfferInterface(adr).getAvailability(), "Offer is no longer available");
        require(getBalanceByToken(OfferInterface(adr).getOwner(), info[1]) >= info[3], "Offer owner is out of tokens");
        require(getBalanceByToken(msg.sender, info[0]) >= info[2], "You are out of tokens");
        transferByCoin(msg.sender, OfferInterface(adr).getOwner(), info[2], info[0]);
        transferByCoin(OfferInterface(adr).getOwner(), msg.sender, info[3], info[1]);
        OfferInterface(adr).closeOffer();
        for (uint i = 0; i < offers.length; i++){
            if (offers[i] == adr){
                offers[i] = offers[offers.length-1];
                offers.pop();
            }
        }
    }

    function setOfferInfo(uint8 IncomingAmount, uint8 OutcomingAmount, address adr) public {
        OfferInterface(adr).setAmountIn(msg.sender, IncomingAmount);
        OfferInterface(adr).setAmountOut(msg.sender, OutcomingAmount);
    }

    function DC_BalanceOf(address adr) internal view returns(uint256){
        return DodgeCoin.balanceOf(adr);
    }

    function BC_BalanceOf(address adr) internal view returns(uint256){
        return BeatCoin.balanceOf(adr);
    }

    function EC_BalanceOf(address adr) internal view returns(uint256){
        return EnergyCoin.balanceOf(adr);
    }

    function getBalanceByToken(address adr, uint8 token)internal view returns(uint256){
        require(( 0 < token) && (token < 4), "No such coin");
        if (token == 1){
            return DC_BalanceOf(adr);
        }
        else if (token == 2){
            return BC_BalanceOf(adr);
        }
        else if (token == 3){
            return EC_BalanceOf(adr);
        }
    }
    
    function createOffer(uint8 _tokenIn, uint8 _tokenOut,uint8 _amountIn, uint8 _amountOut)public returns(address){ 
        require(( 0 < _tokenIn) && (_tokenIn < 4));
        require(( 0 < _tokenOut) && (_tokenOut < 4));
        require(getBalanceByToken(msg.sender, _tokenOut) >= _amountOut);

        Offer offer = new Offer(msg.sender, _tokenIn, _tokenOut, _amountIn,  _amountOut);
        offers.push(address(offer));
        return address(offer);
    }

    function getMyBalance(uint8 token)public view returns(uint256){
        return getBalanceByToken(msg.sender, token);
    }

    function playRoulette(uint _bet, uint _amount, uint8 _tokenUsed) public
    {
        uint8 outcome = Casino.adequateRoulette(_bet, _amount, _tokenUsed);
        if (outcome == 0)
        {
            transferByCoin(casinoAddress, msg.sender, ((_bet / _amount) * (36 - _amount)) / 3, _tokenUsed);
        }
        else if (outcome == 1)
        {
            transferByCoin(msg.sender, casinoAddress, _bet, _tokenUsed);
        }
    }

    function playRussianRoulette(uint _bet, uint _seed, uint8 _tokenUsed) public
    {
        uint8 outcome = Casino.russianRoulette(_bet, _seed, _tokenUsed);
        if (outcome == 0)
        {
            transferByCoin(msg.sender, casinoAddress, tokenBalance(msg.sender, _tokenUsed), _tokenUsed);
        }
        else if (outcome == 1)
        {
            transferByCoin(casinoAddress, msg.sender, _bet * 2, _tokenUsed);
        }
    }

    function playUnevenRussianRoulette(uint _bet, uint _seed, uint8 _tokenUsed) public
    {
        uint8 outcome = Casino.unevenRussianRoulette(_bet, _seed, _tokenUsed);
        if (outcome == 0)
        {
            transferByCoin(casinoAddress, msg.sender, _bet * 15, _tokenUsed);
        }
        else if (outcome == 1)
        {
            transferByCoin(msg.sender, casinoAddress, tokenBalance(msg.sender, _tokenUsed), _tokenUsed);
        }
    }

    function playBlackjack(uint _bet, uint _seed, uint8 _tokenUsed) public returns(string memory)
    {
        uint8 outcome = Casino.blackjack(_bet, _seed, _tokenUsed);
        if (outcome == 0)
        {
            return "No one won anything";
        }
        else if (outcome == 1)
        {
            transferByCoin(msg.sender, casinoAddress, _bet, _tokenUsed);
        }
        else if (outcome == 2)
        {
            transferByCoin(casinoAddress, msg.sender, _bet * 2, _tokenUsed);
        }
        else if (outcome == 3)
        {
            transferByCoin(casinoAddress, msg.sender, _bet, _tokenUsed);
        }
        else if (outcome == 4)
        {
            transferByCoin(msg.sender, casinoAddress, _bet, _tokenUsed);
        }
        else if (outcome == 5)
        {
            transferByCoin(casinoAddress, msg.sender, _bet, _tokenUsed);
        }
    }
}