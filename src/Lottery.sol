// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Lottery{
	uint currentTime;
	uint16 lotteryNum; // 당첨번호
	uint lotteryAmount; 

	bool claimis;
	bool drawis;

	address[] public buyers; //구매자
	address[] public winners; //당첨자
	
	mapping(address=>uint16) public nums; //구매자-로또
	mapping(address=>uint) public award; 

	constructor(){
		currentTime=block.timestamp;
		lotteryNum=0;
		lotteryAmount=0;
        // phase
		claimis=false;
		drawis=false;
	}

    function reset() public {
        currentTime=block.timestamp;
        drawis=false;
        claimis=false;
        buyers=new address[](0);
        winners=new address[](0);
    }
	
	/** buy : 구매, draw : 추첨, claim : 청구 */
	function buy(uint16 num) public payable{
        if(claimis){ // reset
			reset();
		}
		require(msg.value==0.1 ether,"amount must be 0.1 ether");
        require(block.timestamp<currentTime+24 hours);
        require(nums[msg.sender]!=num+1, "already buy");

        nums[msg.sender]=num+1; // 중복 구분
		lotteryAmount += msg.value; 
		buyers.push(msg.sender); 
	}

	
	function draw() public {
		require(claimis==false);
        require(block.timestamp>=currentTime+24 hours);
		
        for (uint i=0; i<buyers.length; i++){
            address buyer=buyers[i];
            if (nums[buyer]-1==winningNumber()){
                winners.push(buyer);
            }
        }
    
        // 2명 고려해야 함
        if (winners.length>0){
            uint payout=lotteryAmount/winners.length;
            for (uint i=0; i<winners.length; i++){
                address buyer=winners[i];
                award[buyer]+=payout;
            }
        }
        drawis=true;
	}

	
	function claim() public { // 청구
		require(drawis==true);
		claimis=true;

		uint amount=award[msg.sender];
		award[msg.sender]=0;
		payable(msg.sender).call{value: amount}("");
	}
	
	function winningNumber() public view returns (uint16){
		return lotteryNum;
	}
}	

