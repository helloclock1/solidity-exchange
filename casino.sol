// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

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

contract Casino
{
    iBeatCoin bc;
    iDodgeCoin dc;
    iEnergyCoin ec;

    constructor(address _address)
    {
        bc = iBeatCoin(_address);
        dc = iDodgeCoin(_address);
        ec = iEnergyCoin(_address);
    }

    function random(uint _hash1, uint _hash2, uint _max) internal view returns(uint)
    {
        uint hash1 = uint(keccak256(abi.encode(_hash1)));
        uint hash2 = uint(keccak256(abi.encode(_hash2)));
        uint hashBlock = uint(blockhash(block.number));

        uint result = uint8(uint(keccak256(abi.encode(hashBlock % 1000 + hash1 % 1000 + hash2 % 1000))) % (_max + 1));
        return result;
    }

    function transact(address _from, address _to, uint _tokens, uint8 _token) internal payable
    {
        if (_token == 0)
        {
            bc.transferTo(_from, _to, _tokens);
        }
        else if (_token == 1)
        {
            dc.transferTo(_from, _to, _tokens);
        }
        else if (_token == 2)
        {
            ec.transferTo(_from, _to, _tokens);
        }
    }

    function tokenBalance(address _addr, uint8 _token) internal returns(uint)
    {
        if (_token == 0)
        {
            return bc.balanceOf(_addr);
        }
        else if (_token == 1)
        {
            return dc.balanceOf(_addr);
        }
        else if (_token == 2)
        {
            return ec.balanceOf(_addr);
        }
    }

    function adequateRoulette(uint _bet, uint _amount, uint8 _tokenUsed) public 
    {
        require(_amount >= 0 && _amount <= 36);

        uint result = random(_bet, _amount, 36);

        if (result <= _amount + 1)
        {
            // balance += ((_bet / _amount) * (36 - _amount)) / 3;
            transact(casinoAddress, msg.sender, ((_bet / _amount) * (36 - _amount)) / 3, _tokenUsed);
        }
        else
        {
            // balance -= _bet;
            transact(msg.sender, casinoAddress, _bet, _tokenUsed);
        }
    }

    function russianRoulette(uint _bet, uint _seed, uint8 _tokenUsed) public returns(string memory)
    {
        uint8 outcome = uint8(random(_bet, _seed, 5));
        if (outcome == 0)
        {
            // balance = 1;
            transfer(msg.sender, casinoAddress, tokenBalance(msg.sender, _tokenUsed), _tokenUsed);
            return "Say goodbye to your money, you won't need it anymore";
        }
        else
        {
            // balance += _bet * 2;
            transfer(casinoAddress, msg.sender, _bet * 2, _tokenUsed);
            return "Lucky you, congrats on 2x win :)";
        }
    }

    function unevenRussianRoulette(uint _bet, uint _seed, uint8 _tokenUsed) public returns(string memory)
    {
        uint8 outcome = uint8(random(_bet, _seed, 5));
        if (outcome == 0)
        {
            // balance += _bet * 15;
            transfer(casinoAddress, msg.sender, _bet * 15, _tokenUsed);
            return "What, how? Get your 15x win and never come back";
        }
        else
        {
            // balance = 1;
            transfer(msg.sender, casinoAddress, tokenBalance(msg.sender, _tokenUsed), _tokenUsed);
            return "Just as expected, goodbye";
        }
    }

    function blackjack(uint _bet, uint _seed, uint8 _tokenUsed) public returns(string memory)  // player is using the same strat as the dealer does - pull out cards if you're <= 16
    {
        uint8 player_score = 0;
        uint8 dealer_score = 0;
        bool player_done = false;
        bool dealer_done = false;
        while (player_done == false || dealer_done == false)
        {
            if (player_done == false)
                player_score += uint8(random(_bet, _seed, 11));
            if (dealer_done == false)
                dealer_score += uint8(random(_bet, _seed + 1, 11));
            if (player_score > 16)
                player_done = true;
            if (dealer_score > 16)
                dealer_done = true;
        }
        if (player_score > 21 && dealer_score > 21)
        {
            return "You both busted somehow, idiots";
        }
        else if (player_score > 21)
        {
            // balance -= _bet;
            transact(msg.sender, casinoAddress, _bet, _tokenUsed);
            return "You busted";
        }
        else if (dealer_score > 21)
        {
            // balance += 2 * _bet;
            transact(casinoAddress, msg.sender, _bet * 2, _tokenUsed);
            return "Dealer busted, 2x win";
        }
        else if (player_score > dealer_score)
        {
            // balance += _bet;
            transact(casinoAddress, msg.sender, _bet, _tokenUsed);
            return "You won";
        }
        else if (dealer_score > player_score)
        {
            // balance -= _bet;
            transact(msg.sender, casinoAddress, _bet, _tokenUsed);
            return "Dealer won";
        }
        else
        {
            // balance += _bet;
            transact(casinoAddress, msg.sender, _bet, _tokenUsed);
            return "You both got the same score, get your 1x win";
        }
    }

    function viewBalance() public view returns(uint)
    {
        return balance;
    }
}