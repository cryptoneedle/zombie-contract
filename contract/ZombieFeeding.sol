// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.14;

import "./ZombieHelper.sol";

/**
    僵尸喂食
*/
contract ZombieFeeding is ZombieHelper {

    //喂食僵尸
    //todo 付费喂食 重置冷却时间
    function feeding(uint _zombieId) public onlyOwnerOf(_zombieId) {
        //创建我的僵尸构造体
        Zombie storage myZombie = zombies[_zombieId]; //storage 相当于指针
        //验证冷却时间
        require(_isReady(myZombie));
        //僵尸喂食次数+1
        zombieFeedTimes[_zombieId] = zombieFeedTimes[_zombieId].add(1);
        //触发冷却
        _triggerColldown(myZombie);
        //如果喂食次数是10的倍数
        if (zombieFeedTimes[_zombieId] % 10 == 0) {
            //新dna为原僵尸的dna，末尾1位数为8
            uint newDna = myZombie.dna - myZombie.dna % 10 + 8;
            //创建新僵尸名为僵尸的儿子
            _createZombie("zombies' son", newDna);
        }
    }
}