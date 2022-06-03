//SPDX-License-Identifier
pragma solidity ^0.8.7;

contract BlindAuction {
    //Variables
    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    address payable public beneficiary;
    uint public biddingEnd;
    uint public revealEnd;
    bool public Ended;

    //users addresses and their respective bids
    mapping( address => Bid[]) public bids;


    //State of the contract
    address public highestBidder;
    uint public highestBid;

    //map to return the bids to the owners
    mapping(address => uint) pendingReturns;

    //events
    event AuctionEnded(address winner, uint highestBid);

    //modifiers
    modifier onlyBefore(uint _time) {
        require(block.timestamp < _time);
        _;
    }

    modifier onlyAfter(uint _time){
        require(block.timestamp > _time);
    }

    //constructor
    constructor(
        uint _biddingTime,
        uint _revealTime,
        address payable _beneficiary
        ){
        beneficiary = _beneficiary;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;

    }
    //functions
    function generateBlindedBidBytes32(uint value, bool fake)public view returns(bytes32) {
        return keccak256(abi.encodePacked(value,fake));
    }

    function bid(bytes32 _blindedBid) public payable onlyBefore(biddingEnd) {
        bid[msg.sender].push(Bid({
            blindedBid: _blindedBid;
            deposit: msg.value;
        }))
    }

    //reveals the winners and details of the bid
    function reveal(
        uint[] memory _values,
         uint memory _fake
         ) 
         public 
         onlyAfter(BiddingEnd)
         onlyBefore(revealEnd) {
        uint length =  bids[msg.sender].length;
        require(_values.length == length);
        require(_fake.length == length);

        
        for(uint i = 0; i < length ;i++){
            Bid Storage bidToCheck = bids[msg.sender][i];
            ( uint value, bool fake ) = (_values[i], _fake[i]);
            if(BidToCheck.blindedBid) != keccak256(abi.encodePacked(value,fake)){
                continue;
            };
            
            if(!fake && bidToCheck.deposit >= value){
                if(!placeBid(msg.sender, value)){
                    payable(msg.sender).transfer(bidToCheck.deposit * (1 ether));
                };
            }
            bidToCheck.blindedBid = bytes32(0);
            
        }
        payable(msg.sender).transfer(amount * (1 ether));


    }

    function auctionEnd() public payable onlyAfter(revealEnd) {
        require(!ended);
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }

    function withdraw() public {
        uint amount = pendingReturn[msg.sender];
        if(amount > 0){
            //set to zero so when function is called again condition fails
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

    function placeBid(address bidder, uint value) internal return(bool success) {
        if(value <= highestBid){
            return false;
        }
        //if current bid is the highestBid and is not a burn address
        //return the previous highestBid
        if(highestBidder != address(0)){
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;

    }
}
