// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.14;

import "../lib/SafeMath.sol";
import "../lib/Ownable.sol";

/**
    僵尸工厂
*/
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

    //事件：生成僵尸
    event NewZombie(uint zombieId, string name, uint dna);

    //生成随机DNA
    function _generateRandomDna(string memory _str) private view returns(uint) {
        return uint(uint(keccak256(abi.encodePacked(_str, block.timestamp))) % dnaDigits);
    }

    //创建僵尸
    function _createZombie(string memory _name, uint _dna) internal {
        uint id = zombies.push(Zombie(_name, _dna, 0, 0, 1, 0));
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        zombieCount = zombieCount.add(1);
        emit NewZombie(id, _name, _dna);
    }

    //输入名称创建僵尸
    function createZombie(string memory _name) public {
        //验证发送者僵尸数量为0
        require(ownerZombieCount[msg.sender] == 0);
        //根据名称获取随机数dna
        uint randDna = _generateRandomDna(_name);
        //将dna最后一位数字改为0
        randDna = randDna - randDna % 10;
        //创建僵尸
        //返回值为数组个数, -1 得数组序号
        uint id = zombies.push(Zombie(_name, randDna, 0, 0, 1, 0));
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        zombieCount = zombieCount.add(1);
        //通知：创建僵尸
        emit NewZombie(id, _name, randDna);
    }

    //购买僵尸
    function buyZombie(string memory _name) public payable {
        //验证发送者是否拥有僵尸
        require(ownerZombieCount[msg.sender] > 0);
        //验证发送者是否拥有足够金额
        require(msg.value > zombiePrice);
        uint randDna = _generateRandomDna(_name);
        //将dna最后一位数字为 1 (代表买到的)
        randDna = randDna - randDna % 10 + 1;
        _createZombie(_name, randDna);
    }

    //调整僵尸售价 | 单位为 wei | 必须是合约拥有者才能调用
    function setZombiePrice(uint _price) external onlyOwner {
        zombiePrice = _price;
    }
}