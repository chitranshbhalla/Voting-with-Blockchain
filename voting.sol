// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Election {
    address public owner;
    uint public candidateCount;
    uint public voterCount;
    bool public electionOngoing;
    
    struct Candidate {
        uint id;
        string name;
        string proposal;
        uint voteCount;
    }
    
    struct Voter {
        address voterAddress;
        string name;
        bool voted;
        bool delegated;
        address delegatee;
        uint vote;
        uint votedCandidateId;

    }
    
    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    event CandidateAdded(uint id, string name, string proposal);
    event VoterAdded(address voterAddress, string name);
    event ElectionStarted();
    event CandidateDetails(uint id, string name, string proposal);
    
    constructor() {
        owner = msg.sender;
        candidateCount = 0;
        voterCount = 0;
        electionOngoing = false;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }
    
    modifier electionInProgress() {
        require(electionOngoing == true, "Election is not currently in progress");
        _;
    }
    
    modifier voterExists(address _voter) {
        require(voters[_voter].voterAddress == _voter, "Voter does not exist");
        _;
    }
    
    modifier voterNotVoted(address _voter) {
        require(voters[_voter].voted == false, "Voter has already voted");
        _;
    }
    
    modifier candidateExists(uint _id) {
        require(candidates[_id].id == _id, "Candidate does not exist");
        _;
    }
    
    
    // 1.Add a new candidate
    function addCandidate(string memory _name, string memory _proposal) public onlyOwner {
        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, _name, _proposal, 0);
        emit CandidateAdded(candidateCount, _name, _proposal);
    }
    
    // 2.	Add a new voter
    function addVoter(address _voter, string memory _name) public onlyOwner {
        require(voters[_voter].voterAddress == address(0), "Voter already exists");
        voterCount++;
        voters[_voter] = Voter(_voter, _name, false, false, address(0), 0);
        emit VoterAdded(_voter, _name);
    }
    //  3.	Start Election
    function startElection() public onlyOwner {
        electionOngoing = true;
        emit ElectionStarted();
    }
    
    //  4.	Display the candidate details
    function displayCandidateDetails(uint _id) public view candidateExists(_id) returns (uint, string memory, string memory) {
        Candidate memory candidate = candidates[_id];
        return (candidate.id, candidate.name, candidate.proposal);
        emit CandidateDetails(candidate.id, candidate.name, candidate.proposal);
    }

    // 5.	Show the Winner of the election
    function showWinner() public view returns (string memory, uint, uint) {
        uint maxVoteCount = 0;
        uint winnerId = 0;
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVoteCount) {
                maxVoteCount = candidates[i].voteCount;
                winnerId = i;
            }
        }
        return (candidates[winnerId].name, winnerId, maxVoteCount);
    }

    //7.	Cast the vote
    function castVote(uint _candidateId, address _voter) public {
        Voter storage voter = voters[_voter];
        require(voter.votedCandidateId == 0, "Already voted");
        require(_candidateId < candidates.length, "Invalid candidate ID");
        voter.votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;
    }

    
    
    //9.	Show election results (candidate wise)
    function showCandidateResult(uint _candidateId) public view returns (uint, string memory, uint) {
        require(_candidateId < candidates.length, "Invalid candidate ID");
        return (_candidateId, candidates[_candidateId].name, candidates[_candidateId].voteCount);
    }

    //10.	View the voter’s profile
    function viewVoterProfile(address _voter) public view returns (string memory, uint, bool) {
        Voter memory voter = voters[_voter];
        return (voter.name, voter.votedCandidateId, voter.delegated);
    }
}