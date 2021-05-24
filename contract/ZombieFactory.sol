// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.14;

import "../lib/SafeMath.sol";
import "../lib/Ownable.sol";

contract ZombieFactory is Ownable {

    using SafeMath for uint256;

    //基因位数
    uint dnaDigits = 16;
    //基因16位单位
    uint dnaModulus = 10 ** dnaDigits;
    //冷却时间
    uint public cooldownTime = 1 days;
    //僵尸价格
    uint public zombiePrice = 0.01 ether;
    //僵尸数量
    uint public zombieCount = 0;

    struct Zombie {
        //名字
        string name;
        //基因
        uint dna;
        //胜利次数
        uint16 winCount;
        //失败次数
        uint16 lossCount;
        //等级
        uint32 level;
        //冷却时间
        uint32 cooldownTime;
    }

    Zombie[] public zombies;

    //僵尸id => 拥有者
    mapping (uint => address) public zombieToOwner;
    //拥有者 => 僵尸数量
    mapping (address => uint) public ownerZombieCount;
    //僵尸id => 喂食次数
    mapping (uint => uint) public zombieFeedTimes;
}