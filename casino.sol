// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

contract Casino
{
    function random(uint _hash1, uint _hash2, uint _max) internal view returns(uint)
    {
        uint hash1 = uint(keccak256(abi.encode(_hash1)));
        uint hash2 = uint(keccak256(abi.encode(_hash2)));
        uint hashBlock = uint(blockhash(block.number));

        uint result = uint(uint(keccak256(abi.encode(hashBlock % 1000 + hash1 % 1000 + hash2 % 1000))) % (_max + 1));
        return result;
    }

    function adequateRoulette(uint _bet, uint _amount, uint8 _tokenUsed) public returns(uint8)
    {
        require(_amount >= 0 && _amount <= 36);

        uint result = random(_bet, _amount, 36);

        if (result <= _amount + 1)
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }

    function russianRoulette(uint _bet, uint _seed, uint8 _tokenUsed) public returns(uint8)
    {
        uint8 outcome = uint8(random(_bet, _seed, 5));
        if (outcome == 0)
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }

    function unevenRussianRoulette(uint _bet, uint _seed, uint8 _tokenUsed) public returns(uint8)
    {
        uint8 outcome = uint8(random(_bet, _seed, 5));
        if (outcome == 0)
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }

    function blackjack(uint _bet, uint _seed, uint8 _tokenUsed) public returns(uint8)  // player is using the same strat as the dealer does - pull out cards if you're <= 16
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
            return 0;
        }
        else if (player_score > 21)
        {
            return 1;
        }
        else if (dealer_score > 21)
        {
            return 2;
        }
        else if (player_score > dealer_score)
        {
            return 3;
        }
        else if (dealer_score > player_score)
        {
            return 4;
        }
        else
        {
            return 5;
        }
    }
}