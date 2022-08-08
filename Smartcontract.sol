pragma solidity ^0.4.0;

contract Ballot
{
   struct Voter
   {
      uint weight;
      bool voted;
      uint vote;
      uint age;
   }
    enum Stage {Init,Reg,Vote,Done}
    Stage public stage =Stage.Init;
    uint startTime;
    
   struct Proposal
   {
       bool registered;
       string candidatename;
       uint votecount;
   }
   mapping(address=>Voter) public voter;
   mapping(uint=>Proposal) public dataofcandidate;
   Proposal[] proposals;
   address chairperson;
 
  event votingCompleted();

 constructor(uint _numsproposals) public
   {

      chairperson=msg.sender;
      voter[chairperson].weight=2;
      voter[chairperson].age=35;
      proposals.length=_numsproposals;
      startTime=now;
   } 
      function setName (uint proposal_1,string name) public
      {
           if(now>startTime+60 seconds)
             {
                 stage=Stage.Reg;
                 startTime=now;
             }

           if(stage!=Stage.Init) return;
          if(msg.sender!=chairperson || proposals[proposal_1].registered || proposal_1>=proposals.length) return;
            proposals[proposal_1].candidatename=name;
            proposals[proposal_1].registered=true;
            dataofcandidate[proposal_1]=proposals[proposal_1];
           
      }  
   function register(address toVoter, uint age) public 
   {
       if(now>(startTime+90 seconds))
      {
          stage=Stage.Vote;
          startTime=now;
      }
       if(stage!=Stage.Reg) return;
      if(msg.sender != chairperson || age<18 ||voter[toVoter].voted) return;
      voter[toVoter].age=age;
      voter[toVoter].weight=1;
      voter[toVoter].voted=false;
      
   }

   function vote(uint _proposal) public 
   {
       if(now>(startTime+120 seconds))
        {
            stage=Stage.Done;
            emit votingCompleted();
        }
       if(stage!=Stage.Vote) return;
       Voter storage votee = voter[msg.sender];
       if(votee.voted || (_proposal >= proposals.length))
        return ;
        votee.voted=true;
        votee.vote=_proposal;
        proposals[_proposal].votecount += votee.weight;
        dataofcandidate[_proposal].votecount+=votee.weight;
        
   }
   
   
   function winner() public  constant returns(uint _winningproposal)
   {
       if(stage!=Stage.Done) return;
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