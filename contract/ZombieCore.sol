// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.14;

import "./ZombieFeeding.sol";
import "./ZombieAttack.sol";
import "./ZombieMarket.sol";

/**
    僵尸核心
*/
contract ZombieCore is ZombieFeeding, ZombieAttack, ZombieMarket {

    //代币名称
    string public constant name = "CryptoZombie";
    //代币缩写
    string public constant symbol = "CZB";

    //空函数-没有人调用合约但给合约打钱了会进入空函数
    function () external payable {

    }

    //提款合约余额
    function withDraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    //查询当前合约的余额
    function checkBalance() external view onlyOwner returns(uint) {
        return address(this).balance;
    }
}