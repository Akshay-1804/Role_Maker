RoleMaker Smart Contract
Overview
RoleMaker is a Solidity smart contract designed to manage a multi-level role-based access control system for a decentralized financial or regulatory application. It provides mechanisms for banks, bank administrators, users, and regulators to request and approve roles in a secure, transparent, and decentralized manner.

The contract supports:

Controlled user onboarding with multi-party approval

Role approval and rejection by verified parties

Decentralized bank and regulator management

Secure admin elevation workflows

Seamless integration with an external role approval contract via interface

🔐 Roles & Permissions
Role	Can Do
Bank	Approve regulators, view all role requests
Regulator	Approve banks, approve/reject bank admin role requests
Bank Admin	Approve/reject user role requests
User	Request user roles

💡 Key Features
✅ Role Requests
Users can request a "user" role.

Requires multi-admin approval (2 approvals minimum).

Can be rejected by bank admins.

🔧 Admin Role Requests
Any external address (except regulators and banks) can request the "Admin" role.

Approved by at least 2 regulators.

Rejected requests are logged.

🏛️ Regulator Requests
Entities can apply to become regulators.

Approved by the Bank.

🔒 Approval System
Each approval is recorded.

Requesters cannot self-approve.

Duplicate requests are prevented.

🧩 Integration
The contract uses an external interface iRoleApprover to offload role approval logic:

solidity
Copy
Edit
iRoleApprover public roleApprover;
This abstraction allows plugging in custom approval logic or on-chain governance rules.

🔄 Events
The contract emits a variety of events to enable off-chain tracking and integrations:

RoleRequested: User requests a role

RoleApproved: Role approved by enough admins

RoleRequestRejected: Role request denied

AdminRequested: Admin role request made

AdminApproved: Admin request approved

BankAdminRequestRejected: Admin request denied

RegulatorRequested: Regulator request made

⚙️ Deployment
solidity
Copy
Edit
constructor(address _roleApprover) {
    roleApprover = iRoleApprover(_roleApprover);
    Bank = msg.sender;
}
The deployer becomes the initial Bank

iRoleApprover contract address must be provided

🛡️ Security Features
✅ Modifiers (onlyBank, onlyRegulator, onlyBankAdmin) restrict critical actions

✅ Re-entrancy resistant role approval logic

✅ Prevents duplicate and malicious requests

✅ Clear on-chain audit trail via events

🧪 Functions Summary
Requests
requestRole(...) – Request a user role

requestAdminrole(...) – Request an admin role

requestRegulator(...) – Request regulator status

Approvals
approveRole(...) – Trigger role approval via iRoleApprover

approveAdminRequest(...) – Regulator approves admin request

approveregulatorRequest(...) – Bank approves regulator

Rejections
rejectRoleRequest(...)

rejectBankAdminRequest(...)

Views
getRoleRequests(...) – View all pending role requests (Bank only)

🧱 Data Structures
solidity
Copy
Edit
struct RoleRequest {
    string name;
    uint customerId;
    address requester;
    string roleType;
    bool approved;
    uint8 approvalCount;
    mapping(address => bool) approvals;
}
Same pattern is used for AdminRequest and RegulatorRequest.



👨‍💻 Author
Developed by Akshay Deore.
