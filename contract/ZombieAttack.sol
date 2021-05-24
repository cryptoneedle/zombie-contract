// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.14;

import "./ZombieHelper.sol";

/**
    僵尸攻击
*/
contract ZombieAttack is ZombieHelper {

    //随机种子
    uint randNonce = 0;
    //胜率
    uint attactVictoryProbability = 70;

    //随机数
    //_modulus控制生成随机数的范围 0 ~ (_modulus-1)
    function randMod(uint _modulus) internal returns(uint) {
        randNonce++;
        return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
    }

    //设置胜率
    function setAttactVictoryProbability(uint _attactVictoryProbability) public onlyOwner {
        //todo 变量安全校验
        attactVictoryProbability = _attactVictoryProbability;
    }

    //僵尸攻击
    function attact(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
        //创建我的僵尸
        Zombie storage myZombie = zombies[_zombieId];
        //创建敌人的僵尸
        Zombie storage enemyZombie = zombies[_targetId];
        //100以内的随机数
        uint rand = randMod(100);
        //如果随机数小于胜率
        if (rand < attactVictoryProbability) {
            //我的胜利次数+1
            myZombie.winCount++;
            //敌人的失败次数+1
            enemyZombie.lossCount++;
            //我的等级+1
            myZombie.level++;
            //我的dna和敌人的dna合体生成新僵尸
            multiply(_zombieId, enemyZombie.dna);
        } else {
            //我的失败次数+1
            myZombie.lossCount++;
            //敌人的胜利次数+1
            enemyZombie.winCount++;
            //触发冷却
            _triggerColldown(myZombie);
        }


    }
}