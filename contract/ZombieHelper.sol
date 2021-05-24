// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.14;

import "./zombieFactory.sol";

/**
    僵尸助手
*/
contract ZombieHelper is ZombieFactory {

    //升级费
    uint levelUpFee = 0.001 ether;

    //确认超过某个等级
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
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
        require(msg.value >= levelUpFee);
        //增加等级 | 此处不太需要考虑溢出
        zombies[_zombieId].level++;
    }

    //20级可以改名
    //todo 付费改名
    //todo onlyOwnerOf(_zombieId) 有bug 不能通过验证
    function changeName(uint _zombieId, string calldata _name) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _name;
    }

    //获取发送者的所有僵尸
    function getZombieByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        //遍历所有僵尸，找出owner地址
        for (uint zombieId = 0; zombieId < zombies.length; zombieId++) {
            if(zombieToOwner[zombieId] == _owner) {
                result[counter] = zombieId;
                counter++;
            }
        }
        return result;
    }

    //触发冷却函数
    function _triggerColldown(Zombie storage _zombie) internal {
        //冷却时间 = 当前时间戳 - 当前时间戳 % 冷却时间，确保每天冷却时间为0点
        _zombie.readyTime = uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
    }

    //验证冷却函数
    function _isReady(Zombie storage _zombie) internal view returns(bool) {
        return _zombie.readyTime <= now;
    }

    //僵尸合体 | DNA位数为9
    //todo 指定合体名称 | 僵尸合体后应该删除合体之前的僵尸 逻辑还需要处理
    function multiply(uint _zombieId, uint _targetDna) internal onlyOwnerOf(_zombieId) {
        //冷却结束
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie));
        //DNA位数检查
        _targetDna = _targetDna % dnaModulus;
        //合体
        uint newDna = (myZombie.dna + _targetDna) / 2;
        newDna = newDna - newDna % 10 + 9;
        //创建合体僵尸
        _createZombie("NoName", newDna);
        //重置冷却时间
        _triggerColldown(myZombie);
    }
}