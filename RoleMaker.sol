// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./iRoleApprover.sol";
contract RoleMaker {
    iRoleApprover public roleApprover;
    //address public regulator;
    address public Bank;
    address[] public banks;
    mapping(address => bool) public bankAdmins;
    mapping(address => bool) public regulators;
    mapping(address => bool) public regulatorAdmins;
    mapping(address => bool) public approvedBanks;
    
    struct RoleRequest {
        string name;
        uint customerId;
        address requester;
        string roleType;
        bool approved;
        uint8 approvalCount;
        mapping(address => bool) approvals;
    }

     struct AdminRequest {
        address requester;
        string roleType;
        bool approved;
        uint8 approvalCount;
        mapping(address => bool) approvals;
    }

    struct RegulatorRequest {
        address requester;
        string roleType;
        bool approved;
    }

    address[] public Banks;
    RoleRequest[] public roleRequests;
    AdminRequest[] public adminRequests;
    RegulatorRequest[] public regulatorRequests;


    event RoleRequested(address indexed requester, string roleType, string name, uint customerId);
    event RoleApproved(uint256 indexed index);
    event AdminRequested(address indexed requester, string roleType);
    event RegulatorRequested(address indexed requester, string roleType);
    event AdminApproved(uint index);
    event RoleRequestRejected(uint256 indexed index, address requester, string roleType);
    event BankAdminRequestRejected(uint256 indexed index, address requester, string roleType);


    
    modifier onlyRegulator() {
        require(regulators[msg.sender], "Only regulator can perform this action");
        _;
    }
    
    modifier onlyBank() {
        require(msg.sender == Bank, "Only Bank can perform this action");
        _;
    }

    modifier onlyBankAdmin() {
    require(bankAdmins[msg.sender], "Only bank admin can perform this action");
    _;
}

    
    // constructor() {
    //     Bank = msg.sender;
    // }
    constructor(address _roleApprover) {
        roleApprover = iRoleApprover(_roleApprover);
        Bank = msg.sender;
    }
    

     function approveBank(address _bank) external onlyRegulator {
        require(!approvedBanks[_bank], "Bank is already approved");
        approvedBanks[_bank] = true;
        Banks.push(_bank);
    }
    function requestRole(string memory roleType, string memory _name, uint _customerId) external {
        require(msg.sender != Bank, "Bank cannot request a role");
        require(!regulators[msg.sender], "Regulators cannot request a user role");
        require(!bankAdmins[msg.sender], "Bankadmins cannot request a user role");
        require(keccak256(bytes(roleType)) == keccak256("user"), "Invalid role request type");
        require(bytes(roleType).length > 0, "Role type cannot be empty");
        
        // Check if user already has a pending request for the same role type or customer ID
        for (uint256 i = 0; i < roleRequests.length; i++) {
            require(roleRequests[i].requester != msg.sender || keccak256(bytes(roleRequests[i].roleType)) != keccak256(bytes(roleType)), "User already has a pending request for this role type");
            require(roleRequests[i].customerId != _customerId, "Customer ID already exists");
        }
        
        roleRequests.push();
    RoleRequest storage newRequest = roleRequests[roleRequests.length - 1];
    newRequest.name = _name;
    newRequest.customerId = _customerId;
    newRequest.requester = msg.sender;
    newRequest.roleType = roleType;
    newRequest.approved = false;
    newRequest.approvalCount = 0;
        
        emit RoleRequested(msg.sender, roleType, _name, _customerId);
    }
    
    // function approveRoleRequest(uint256 _customerId) external onlyBankAdmin {
    //     uint8 requiredApprovals = 2; 
        
    //     bool found = false;
        
    //     // Iterate through role requests to find the request with the provided customer ID
    //     for (uint256 i = 0; i < roleRequests.length; i++) {
    //         if (roleRequests[i].customerId == _customerId) {
    //             require(!roleRequests[i].approved, "Request already approved");
    //             require(!roleRequests[i].approvals[msg.sender], "Already approved by this bank admin");
                
    //             roleRequests[i].approvals[msg.sender] = true;
    //             roleRequests[i].approvalCount++;
                
    //             if (roleRequests[i].approvalCount >= requiredApprovals) {
    //                 roleRequests[i].approved = true;
    //                 emit RoleApproved(i);
    //             }
                
    //             found = true;
    //             break;
    //         }
    //     }
        
    //     require(found, "No role request found for the provided customer ID");
    // }

     function approveRole(uint256 _customerId) external onlyBankAdmin {
        roleApprover.approveRoleRequest(_customerId);
    }

    function getRoleRequests() external onlyBank view returns (string[] memory, uint[] memory, address[] memory, string[] memory, bool[] memory, uint8[] memory) {
    uint256 length = roleRequests.length;
    
    string[] memory names = new string[](length);
    uint[] memory customerIds = new uint[](length);
    address[] memory requesters = new address[](length);
    string[] memory roleTypes = new string[](length);
    bool[] memory approvedStatus = new bool[](length);
    uint8[] memory approvalCounts = new uint8[](length);
    
    for (uint256 i = 0; i < length; i++) {
        RoleRequest storage request = roleRequests[i];
        names[i] = request.name;
        customerIds[i] = request.customerId;
        requesters[i] = request.requester;
        roleTypes[i] = request.roleType;
        approvedStatus[i] = request.approved;
        approvalCounts[i] = request.approvalCount;
    }
    
    return (names, customerIds, requesters, roleTypes, approvedStatus, approvalCounts);
}

 function requestAdminrole(string memory roleType) external {
    require(msg.sender != Bank, "bank cannot request a role");
    require(!regulators[msg.sender], "Regulators cannot request a admin role");
    require(keccak256(bytes(roleType)) == keccak256("Admin"), "Invalid role request type");
    require(bytes(roleType).length > 0, "Role type cannot be empty");
    
    // Check if user already has a pending request for the same role type
    for (uint256 i = 0; i < adminRequests.length; i++) {
        require(adminRequests[i].requester != msg.sender || keccak256(bytes(adminRequests[i].roleType)) != keccak256(bytes(roleType)), "User already has a pending request for this role type");
    }
    adminRequests.push();
    AdminRequest storage newRequest = adminRequests[adminRequests.length - 1];
    newRequest.requester = msg.sender;
    newRequest.roleType = roleType;
    newRequest.approved = false;
    newRequest.approvalCount = 0;
    emit AdminRequested(msg.sender, roleType);
    }

function approveAdminRequest(uint256 index) external onlyRegulator {
        require(index < adminRequests.length, "Invalid index");
        require(!adminRequests[index].approved, "Request already approved");
        require(!adminRequests[index].approvals[msg.sender], "Already approved by this regulator");

        adminRequests[index].approvals[msg.sender] = true;
        adminRequests[index].approvalCount++;

        if (adminRequests[index].approvalCount >= 2) { 
            adminRequests[index].approved = true;
            bankAdmins[adminRequests[index].requester]= true;
            emit AdminApproved(index);
        }
}


function requestRegulator(string memory roleType) external {
    require(msg.sender != Bank, "bank cannot request a role");
    require(!bankAdmins[msg.sender], "BankAdmins cannot request a Regulator role");
    require(keccak256(bytes(roleType)) == keccak256("Regulator"), "Invalid role request type");
    require(bytes(roleType).length > 0, "Role type cannot be empty");
    
    // Check if user already has a pending request for the same role type
    for (uint256 i = 0; i < regulatorRequests.length; i++) {
        require(regulatorRequests[i].requester != msg.sender || keccak256(bytes(regulatorRequests[i].roleType)) != keccak256(bytes(roleType)), "User already has a pending request for this role type");
    }
    regulatorRequests.push(RegulatorRequest(msg.sender, roleType, false));
    emit RegulatorRequested(msg.sender, roleType);
    }

    function approveregulatorRequest(uint256 index) external onlyBank {
    require(index < regulatorRequests.length, "Invalid index");
    regulatorRequests[index].approved = true;
    regulators[regulatorRequests[index].requester] = true;
}

    function rejectRoleRequest(uint256 _customerId) external onlyBankAdmin {
    // Iterate through role requests to find the request with the provided customer ID
    for (uint256 i = 0; i < roleRequests.length; i++) {
        if (roleRequests[i].customerId == _customerId) {
            
            require(!roleRequests[i].approved, "Request already approved");

            
            roleRequests[i].approved = false;

            
            emit RoleRequestRejected(i, roleRequests[i].requester, roleRequests[i].roleType);

            return; 
        }
    }
    
    // If no request is found for the provided customer ID, revert
    revert("No role request found for the provided customer ID");
}


    function rejectBankAdminRequest(uint256 index) external onlyRegulator {
    require(index < adminRequests.length, "Invalid index");
    AdminRequest storage request = adminRequests[index];
    require(!request.approved, "Request already approved");

    // Mark the request as rejected
    request.approved = false;

    emit BankAdminRequestRejected(index, request.requester, request.roleType);
}



}
