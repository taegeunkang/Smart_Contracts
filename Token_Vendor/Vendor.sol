pragma solidity 0.8.13;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  //event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100; // 이더당 토큰 개수
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfEth, uint256 amountOfTokens);

  constructor(address tokenAddress) payable {
    yourToken = YourToken(tokenAddress);
  }


  // ToDo: create a payable buyTokens() function:
  function buyTokens() payable public {
    uint256 tokensBuying = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, tokensBuying);

    emit BuyTokens(msg.sender, msg.value, tokensBuying); 


  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() payable public onlyOwner {
    require(address(this).balance > 0);
    msg.sender.call{value: address(this).balance}("");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 _amount) public {
    uint256 backEth = _amount / tokensPerEth;
    
    require(yourToken.balanceOf(msg.sender) * 10 ** 18 >= _amount, "your balance is lower than you requrested.");
    require(address(this).balance  > backEth, "Vendor doesn't have enough eth");

    uint256 amount = yourToken.allowance(msg.sender, address(this));
    require(amount >= _amount);
    bool res = yourToken.transferFrom(msg.sender, address(this), _amount);
    require(res, "transaction faild");
    (bool sent,) = msg.sender.call{value: backEth}("");
    require(res, "transaction faild");

    emit SellTokens(msg.sender, backEth, _amount);
      
  }

}
