// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./productNFT.sol";


 interface DaiTokenVault {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
}

interface ILendingPool {

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  function supply(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);
}

contract Vault {

    DaiTokenVault public daiTokenVault;
    productNFT private _productNFT;
    ILendingPool public iLendingPool;

    // 0xF14f9596430931E177469715c591513308244e8F - V3 DAI contract
    // daiTokenVault V2 = DaiTokenVault(0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F);
    // aPolDAI contract = 0xFAF6a49b4657D9c8dDa675c41cB9a05a94D3e9e9

    mapping(address => bool) daiApproved;
    mapping(address => uint256) userSupplyAvailability;
    mapping(address => bool) contractApproved;

    uint256 totalSales = 0;

    constructor(address _productAddress){
        setContracts(_productAddress);
        daiTokenVault = DaiTokenVault(0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F);
        iLendingPool = ILendingPool(0x0b913A76beFF3887d35073b8e5530755D60F78C7);
    }
    
    function setContracts(address _productAddress) public {
        _productNFT = productNFT(_productAddress);
    }
    
    function buy(uint256 serviceId, uint256 _businessId, address _buyerAddress) public  {
        require(_productNFT.getOwnerOfService(serviceId) != msg.sender, "You cannot buy your own service");
        // require for nonexistentBusiness
        uint256 price = _productNFT.getPriceForAService(serviceId);
        // require(daiTokenVault.balanceOf(msg.sender) >= price, "you want to pay less than the actual price");
        // require(daiTokenVault.allowance(msg.sender, address(this)) >= price, "You don't have enough allowance to buy this product");
        address  receiver = _productNFT.getOwnerOfService(serviceId);

        userSupplyAvailability[_buyerAddress] += price;
        totalSales += price;

        daiTokenVault.transferFrom(msg.sender, receiver, price / 10 * 9);
        daiTokenVault.transferFrom(msg.sender, address(this), price / 10);
        // receiver.transfer(msg.value / 10 * 9);  90% to seller 10% to Vault
        if(daiApproved[_buyerAddress] == false){
            daiApproved[_buyerAddress] = true;
        }
        _productNFT.buyService(serviceId, _businessId);
    }

    function getVaultBalance() public view returns(uint256){
        return daiTokenVault.balanceOf(address(this));
    }

    function sendSomethingOut(address _address, uint256 daiAmount) public payable {
        daiTokenVault.transfer(_address, daiAmount);
    }

    function checkBuyAllowance(address buyerAddress) public view returns(bool){
        return daiApproved[buyerAddress];
    }

    function approveAaveContract(address _caller, uint256 _amount) public {
      daiTokenVault.approve(0x0b913A76beFF3887d35073b8e5530755D60F78C7, _amount);
      if(contractApproved[_caller] == false){
        contractApproved[_caller] = true;
      }
      // ez kell a supplyhoz
      // withdrawnál pedig kell a sima metamask sending
    }

    function getTotalSales() public view returns (uint256){
      return totalSales;
    }

    function IsAaveApproved(address _caller) public view returns(bool){
      return contractApproved[_caller];
    }

    function getAaaveAvailibility(address _user) public view returns(uint256){
      return userSupplyAvailability[_user];
    }

    function aaveDeposit(address _address, uint256 _amount) public {
        // require(userSupplyAvailability[_address] >= _amount, "You do not have any allowance to supply any DAI to the pool");

        iLendingPool.deposit(0xF14f9596430931E177469715c591513308244e8F, _amount, msg.sender, 0);
        // userSupplyAvailability[_address] -= _amount;
        // asset address is the DAI address in this example
        // onBehalfOf address is
        // referralCode is always 0
    }

    function aaveWithdraw(uint256 _amount) public {
        iLendingPool.withdraw(0xF14f9596430931E177469715c591513308244e8F, _amount, msg.sender);

        // 1. You need to send aPolDai to this contract
        // 2. You can hit the Withdraw button 
    }
}


    // function aaveSupply(address _address, uint256 _amount) public {
    //     // require(userSupplyAvailability[_sender] > 0, "You do not have any allowance to supply any DAI to the pool");
    //     iLendingPool.supply(_address, _amount, msg.sender, 0);

    //     // You need to send the amount to the Vault Contract first
    //     // Then you have to use the approveAaveContract function which is approving Dai on this contract
    //     // then you can hit on Supply
    // }