// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.14;

import "./ZombieHelper.sol";
import "../lib/ERC721.sol";

/**
    僵尸所有权
*/
contract ZombieOwnerShip is ZombieHelper, ERC721 {

    //批准映射 僵尸id => 拥有者
    mapping (uint => address) zombiesApprovals;

    //交易内置函数
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        //发送者的僵尸数-1
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        //接收者的僵尸数+1
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        //修改僵尸所有者的映射为接收者
        zombieToOwner[_tokenId] = _to;
        //触发交易事件
        emit Transfer(_from, _to, _tokenId);
    }

    /*重写方法*/
    //余额 - 查询发送者的僵尸数量
    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerZombieCount[_owner];
    }

    //查询僵尸所有者
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return zombieToOwner[_tokenId];
    }

    //交易
    function transfer(address _to, uint256 _tokenId) public {
        //调用交易内置函数
        _transfer(msg.sender, _to, _tokenId);
    }

    //批准
    function approve(address _to, uint256 _tokenId) public {
        //设置批准映射为接受者
        zombiesApprovals[_tokenId] = _to;
        //触发批准事件
        emit Approval(msg.sender, _to, _tokenId);
    }

    //接受
    function takeOwnership(uint256 _tokenId) public {
        //验证批准映射的接收者为消息发送者
        require(msg.sender == zombiesApprovals[_tokenId]);
        //根据id查找到僵尸原所有者
        address owner = ownerOf(_tokenId);
        //调用交易内置函数
        _transfer(owner, msg.sender, _tokenId);
    }
}