// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.14;

import "./ZombieFactory.sol";

/**
    僵尸助手
*/
contract ZombieFactory is ZombieFactory {

    //升级费
    uint levelUpFee = 0.001 ether;

    //确认超过某个等级
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[id].level >= _level);
        _;
    }

    //确认只能持有者调用
    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    //设置升级费 | 单位 wei
    function setLevelUpFee(uint _fee) external onlyOwner() {
        levelUpFee = _fee;
    }

    //僵尸升级
    //todo 可选升多少级
    function levelUp(uint _zombieId) external payable {
        //验证余额大于升级费 | 如果钱给多了那我就笑纳了
        require(msg.value >= _levelUpFee);
        //增加等级 | 此处不太需要考虑溢出
        zombies[_zombie].level++;
    }

    //改名函数

    //获取发送者的所有僵尸

    //触发冷却函数

    //验证冷却函数

    //合体函数
}