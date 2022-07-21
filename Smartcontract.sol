pragma solidity ^0.4.0;

contract Ballot
{
   struct Voter
   {
      uint weight;
      bool voted;
      uint vote;
   }
    enum Stage {Init,Reg,Vote,Done}
    Stage public stage =Stage.Init;
    uint startTime;

   struct Proposal
   {
       uint votecount;
   }
   mapping(address=>Voter) voter;
   Proposal[] proposals;
   address chairperson;
   modifier validStage(Stage reqStage)
   {
       require(stage==reqStage);
       _;
   }
  event votingCompleted();

 constructor(uint _numsproposals) public
   {

      chairperson=msg.sender;
      voter[chairperson].weight=2;
      proposals.length=_numsproposals;
      stage=Stage.Reg;
      startTime=now;
   } 

   function register(address toVoter) public validStage(Stage.Reg)
   {
       if(stage!=Stage.Reg) return;
      if(msg.sender != chairperson || voter[toVoter].voted) return;
      voter[toVoter].weight=1;
      voter[toVoter].voted=false;
      if(now>startTime+20 seconds)
      {
          stage=Stage.Vote;
          startTime=now;
      }
   }

   function vote(uint _proposal) public validStage(Stage.Vote)
   {
       if(stage!=Stage.Vote) return;
       Voter storage votee = voter[msg.sender];
       if(votee.voted || (_proposal >= proposals.length))
        return ;
        votee.voted=true;
        votee.vote=_proposal;
        proposals[_proposal].votecount += votee.weight;
        if(now>startTime+20 seconds)
        {
            stage=Stage.Done;
            emit votingCompleted();
        }
   }
   
   function winner() public validStage(Stage.Done) constant returns(uint _winningproposal)
   {
      /* if(stage!=Stage.Done)
       {
          _winningproposal=20;
          return _winningproposal;
       }  */
       uint winnervotecount=0;
       for(uint i=0; i<proposals.length ; i++)
          {
              if((proposals[i].votecount)>(winnervotecount))
                 {
                     winnervotecount=proposals[i].votecount;
                     _winningproposal=i;
                 }
          }
          return _winningproposal;
   }
}