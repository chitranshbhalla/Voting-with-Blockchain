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
    
    function addCandidate(string memory _name, string memory _proposal) public onlyOwner {
        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, _name, _proposal, 0);
        emit CandidateAdded(candidateCount, _name, _proposal);
    }
    
    function addVoter(address _voter, string memory _name) public onlyOwner {
        require(voters[_voter].voterAddress == address(0), "Voter already exists");
        voterCount++;
        voters[_voter] = Voter(_voter, _name, false, false, address(0), 0);
        emit VoterAdded(_voter, _name);
    }
    
    function startElection() public onlyOwner {
        electionOngoing = true;
        emit ElectionStarted();
    }
    
    function displayCandidateDetails(uint _id) public view candidateExists(_id) returns (uint, string memory, string memory) {
        Candidate memory candidate = candidates[_id];
        return (candidate.id, candidate.name, candidate.proposal);
        emit CandidateDetails(candidate.id, candidate.name, candidate.proposal);
    }
}