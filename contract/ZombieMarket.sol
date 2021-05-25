// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.14;

import "./ZombieOwnerShip.sol";

/**
    僵尸市场
*/
contract ZombieMarket is ZombieOwnerShip{

    //税
    uint public tax = 1 finney;
    //最低售价
    uint public minPrice = 1 finney;

    //僵尸出售信息
    struct ZombieSales {
        //出售者-涉及到交易的退回、转让之类，需要声明payable
        address payable seller;
        //价格
        uint price;
    }

    //僵尸id => 僵尸出售信息
    mapping (uint => ZombieSales) public zombieShop;

    //事件：僵尸出售
    event SaleZombie(uint indexed zombieId, address indexed seller);
    //事件：僵尸购买
    event BuyShopZombie(uint indexed zombieId, address indexed buyer, address indexed seller);

    //出售我的僵尸
    function saleMyZombie(uint _zombieId, uint _price) public onlyOwnerOf(_zombieId) {
        //验证僵尸售价 >= 最少售价 + 税金
        require(_price >= minPrice + tax);
        //僵尸商店映射（发送者，售价）
        zombieShop[_zombieId] = ZombieSales(msg.sender, _price);
        //触发僵尸出售事件
        emit SaleZombie(_zombieId, msg.sender);
    }

    //购买僵尸
    function buyShopZombie(uint _zombieId) public payable onlyOwnerOf(_zombieId) {
        //创建僵尸销售构造体
        ZombieSales memory _ZombieSales = zombieShop[_zombieId];
        //验证发送的金额大于僵尸价格
        require(msg.value >= _ZombieSales.price);
        //调用交易内置函数
        _transfer(_ZombieSales.seller, msg.sender, _zombieId);
        //将僵尸价格减去税金后发送给僵尸出售者
        _ZombieSales.seller.transfer(msg.value - tax);
        //删除僵尸商店映射
        delete zombieShop[_zombieId];
        //触发僵尸购买事件
        emit BuyShopZombie(_zombieId, msg.sender, _ZombieSales.seller);
    }

    //设置税金
    function setTax(uint _tax) public onlyOwner {
        tax = _tax;
    }

    //设置最低售价
    function setMinPrice(uint _minPrice) public onlyOwner {
        minPrice = _minPrice;
    }

}