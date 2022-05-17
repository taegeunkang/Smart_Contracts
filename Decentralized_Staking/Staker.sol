// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./ExampleExternalContract.sol";

contract Staker {
  using SafeMath for uint256;

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw;

  event Stake(address, uint256);

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      openForWithdraw = false;
  }
  modifier deadlineExpire() {
    require(block.timestamp >= deadline);
    _;
  }

  modifier deadlineNotExpire() {
    require(block.timestamp < deadline);
    _;
  }
  modifier notCompleted() {
    require(!exampleExternalContract.completed());
    _;
  }
  

  function stake() public payable deadlineNotExpire {
    require(balances[msg.sender].add(msg.value)<= threshold);

    balances[msg.sender] = balances[msg.sender].add(msg.value);
    emit Stake(msg.sender, msg.value);

  }

  function execute() public deadlineExpire notCompleted {
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    }else{
      openForWithdraw = true;
    }
  }

  function withdraw() public payable notCompleted {
    require(openForWithdraw);

    uint256 val = balances[msg.sender];
    require(val >= msg.value);
    balances[msg.sender] = val.sub(msg.value);
    msg.sender.call{value: msg.value}("");
  }

  function timeLeft() public view returns (uint256) {
    
    return (block.timestamp < deadline) ? deadline - block.timestamp : 0;
  
  }

  receive() external payable {
    stake();
  }

}


library SafeMath {
  
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

 
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }


    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
     
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}