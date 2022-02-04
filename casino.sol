// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

contract Casino
{
    uint balance = 1000;

    function random(uint _hash1, uint _hash2, uint _max) internal view returns(uint)
    {
        uint hash1 = uint(keccak256(abi.encode(_hash1)));
        uint hash2 = uint(keccak256(abi.encode(_hash2)));
        uint hashBlock = uint(blockhash(block.number));

        uint result = uint8(uint(keccak256(abi.encode(hashBlock % 1000 + hash1 % 1000 + hash2 % 1000))) % (_max + 1));
        return result;
    }

    function adequateRoulette(uint _bet, uint _amount) public 
    {
        require(_amount >= 0 && _amount <= 36);

        uint result = random(_bet, _amount, 36);

        if (result <= _amount + 1)
        {
            balance += ((_bet / _amount) * (36 - _amount)) / 3;
        }
        else
        {
            balance -= _bet;
        }
    }

    function russianRoulette(uint _bet, uint _seed) public returns(string memory)
    {
        uint8 outcome = uint8(random(_bet, _seed, 5));
        if (outcome == 0)
        {
            balance = 1;
            return "Poor soul, luckily bullet did not injure you much but you juts lost all your money besides 1 chip :(";
        }
        else
        {
            balance += _bet * 2;
            return "Lucky you, congrats on 2x win :)";
        }
    }

    function unevenRussianRoulette(uint _bet, uint _seed) public returns(string memory)
    {
        uint8 outcome = uint8(random(_bet, _seed, 5));
        if (outcome == 0)
        {
            balance += _bet * 15;
            return "What, how? Get your 15x win and never come back";
        }
        else
        {
            balance = 1;
            return "Just as expected, goodbye";
        }
    }

    function blackjack(uint _bet, uint _seed) public returns(string memory)  // player is using the same strat as the dealer does - pull out cards if you're <= 16
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
            balance -= _bet;
            return "You busted";
        }
        else if (dealer_score > 21)
        {
            balance += 2 * _bet;
            return "Dealer busted, 2x win";
        }
        else if (player_score > dealer_score)
        {
            balance += _bet;
            return "You won";
        }
        else if (dealer_score > player_score)
        {
            balance -= _bet;
            return "Dealer won";
        }
        else
        {
            balance += _bet;
            return "You both got the same score, get your 1x win";
        }
    }

    function viewBalance() public view returns(uint)
    {
        return balance;
    }
}