// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./itemNFT.sol";

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

  interface aPolDAI {
    function balanceOf(address user) external view returns (uint256);
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
    itemNFT private _itemNFT;
    ILendingPool public iLendingPool;
    aPolDAI public _apolDAI;

    // Polygon contracts:
    // 0xF14f9596430931E177469715c591513308244e8F - V3 DAI contract
    // aPolDAI contract = 0xFAF6a49b4657D9c8dDa675c41cB9a05a94D3e9e9
    // Pool Contract = 0x0b913A76beFF3887d35073b8e5530755D60F78C7

    // Göerli contracts:
    // DAI: 0xBa8DCeD3512925e52FE67b1b5329187589072A55
    // Pool contract: 0x7b5C526B7F8dfdff278b4a3e045083FBA4028790
    // aETHDAI: 0xADD98B0342e4094Ec32f3b67Ccfd3242C876ff7a

    // Optimism Göerli Contracts:
    // DAI: 0xD9662ae38fB577a3F6843b6b8EB5af3410889f3A
    // Pool Contract: 0xCAd01dAdb7E97ae45b89791D986470F3dfC256f7
    // 

    // Arbitrum Göerli contracts:
    // DAI: 0xf556C102F47d806E21E8E78438E58ac06A14A29E
    // Pool Contract: 0xeAA2F46aeFd7BDe8fB91Df1B277193079b727655
    // AArgDAI: 0x951ce0CFd38b4ADd03272C458Cc2973D77E2C000

    mapping(address => bool) daiApproved;
    mapping(address => uint256) userSupplyAvailability;
    mapping(address => bool) contractApproved;
    mapping(address => uint256) totalSales;
    mapping(address => bool) hasSupplied;

    uint256 totalBalance = 0;

    constructor(address _itemAddress){
        setContracts(_itemAddress);
        daiTokenVault = DaiTokenVault(0xf556C102F47d806E21E8E78438E58ac06A14A29E);
        iLendingPool = ILendingPool(0xeAA2F46aeFd7BDe8fB91Df1B277193079b727655);
        _apolDAI = aPolDAI(0x951ce0CFd38b4ADd03272C458Cc2973D77E2C000); // or aETHDAI
    }
    
    function setContracts(address _itemAddress) public {
        _itemNFT = itemNFT(_itemAddress);
    }
    
    function buy(uint256 _businessId, uint256 serviceId, address _buyerAddress) public  {
        require(_itemNFT.getOwnerOfService(serviceId) != _buyerAddress, "You cannot buy your own service");
        // require for nonexistentBusiness
        uint256 price = _itemNFT.getPriceForAService(serviceId);
        // require(daiTokenVault.balanceOf(msg.sender) >= price, "you want to pay less than the actual price");
        // require(daiTokenVault.allowance(msg.sender, address(this)) >= price, "You don't have enough allowance to buy this product");
        address receiver = _itemNFT.getOwnerOfService(serviceId);

        userSupplyAvailability[receiver] += price ; // 100% goes into Vault now
        totalBalance += price;
        totalSales[receiver]+= price;

        daiTokenVault.transferFrom(msg.sender, address(this), price);
        // daiTokenVault.transferFrom(msg.sender, receiver, price / 10 * 9); // 90% DAI to the receiver
        // daiTokenVault.transferFrom(msg.sender, address(this), price / 10); // 10% DAI to the Vault
        // receiver.transfer(msg.value / 10 * 9);  90% to seller 10% to Vault
        if(daiApproved[_buyerAddress] == false){
            daiApproved[_buyerAddress] = true;
        }
        _itemNFT.buyService(_businessId, serviceId, _buyerAddress);
    }

    function getVaultBalance() public view returns(uint256){
        return daiTokenVault.balanceOf(address(this));
    }

    function sendDaiOut(address _address, uint256 daiAmount) public payable {
        require(userSupplyAvailability[_address] >= daiAmount, "You do not have that much DAI in the vault which you can send out");
        userSupplyAvailability[_address] -= daiAmount;
        daiTokenVault.transfer(_address, daiAmount);
    }

    function checkBuyAllowance(address buyerAddress) public view returns(bool){
        return daiApproved[buyerAddress];
    }

    function approveAaveContract(address _caller, uint256 _amount) public {
      daiTokenVault.approve(0xeAA2F46aeFd7BDe8fB91Df1B277193079b727655, _amount);
      if(contractApproved[_caller] == false){
        contractApproved[_caller] = true;
      }
    }

    function getTotalSales(address _owner) public view returns (uint256){
      return totalSales[_owner];
    }

    function IsAaveApproved(address _caller) public view returns(bool){
      return contractApproved[_caller];
    }

    function getAaaveAvailibility(address _user) public view returns(uint256){
      return userSupplyAvailability[_user];
    }

    function aaveDeposit(address _address, uint256 _amount) public {
        require(userSupplyAvailability[_address] >= _amount, "You do not have any allowance to supply any DAI to the pool");

        iLendingPool.deposit(0xf556C102F47d806E21E8E78438E58ac06A14A29E, _amount, msg.sender, 0);
        userSupplyAvailability[_address] -= _amount;
        totalBalance -= _amount;
        hasSupplied[msg.sender] = true;
    }

    function aaveWithdraw(uint256 _amount) public {
        iLendingPool.withdraw(0xf556C102F47d806E21E8E78438E58ac06A14A29E, _amount, msg.sender);
    }

    function getTotalBalance() public view returns (uint256){
      return totalBalance;
    }

    function getWithdrawBalance() public view returns (uint256){
      return _apolDAI.balanceOf(msg.sender);
    }

    function getYourDaiBalance(address _user) public view returns (uint256){
      return daiTokenVault.balanceOf(_user);
    }

    function directSupply(uint256 _amount) public {
      iLendingPool.deposit(0xf556C102F47d806E21E8E78438E58ac06A14A29E, _amount, msg.sender, 0);
    }

    function isSupplied() public view returns(bool){
      return hasSupplied[msg.sender];
    }
}

