// //SPDX-Lincense-Identifier:MIT
// pragma solidity ^0.8.3;

// contract ProofOfExistence{
//     struct Document{
//        uint id;
//        bytes32 hashes;
//        uint stamp;
//        string description;
//     }
//     Document[] public documents;
//     mapping(address=>Document[]) public userDocument;
//     mapping (address=>bool) public isUser;
//     address[] public userAddresses;
//     uint docId;

//     error HashAlreadyExist();

//     event Registered(uint stamp, address indexed sender);


//     function addDocument(bytes32 _hashes, string memory _description)  external {
//         for(uint i; i < userDocument[msg.sender].length; i++){
//             if(userDocument[msg.sender][i].hashes == _hashes){
//                 revert ("Hash already exist");
//             }
//         }

//         Document memory newDocument = Document(userDocument[msg.sender].length +1, _hashes, block.timestamp, _description);
//         documents.push(newDocument);
//         userDocument[msg.sender].push(newDocument);
        
//         if(!isUser[msg.sender]){
//             userAddresses.push(msg.sender);
//             isUser[msg.sender]=true;
//         }
        
//         emit Registered(block.timestamp, msg.sender);
//     }

//     function getUserDocument(address _userAddress) external returns(){
//         _userAddress = msg.sender;
//         return userDocument[_userAdress];
//     }

//     function getAllDocument() external returns(Document[]){
//         return documents;
//     }



// }

// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.30;

// contract ProofOfExistence {
//     // store a document hash
//     struct Document {
//         uint16 id;
//         bytes32  hashes;
//         string description;
//         uint256 stamp;
//     }

//     Document[] public documents;
//     mapping(address => Document[]) public addressToDocuments;
//     mapping(bytes32 => mapping(address => bool)) public userDocumentExist;
//     address[] public documentAddress;
//     // mapping(address => bool) userExist;

//     event Registered(uint256 timeStamp, address indexed _sender);

//     function addDocument(bytes32 _documentHash, string memory _description) public {
//         require(!userDocumentExist[_documentHash][msg.sender], "User Document Exist");
//         Document memory newDoc = Document({
//             id: uint16(addressToDocuments[msg.sender].length + 1),
//             hashes: bytes32(_documentHash),
//             description: _description,
//             stamp: block.timestamp
//         });

//     addressToDocuments[msg.sender].push(newDoc);
//     documents.push(newDoc);
//     userDocumentExist[_documentHash][msg.sender] = true;

//     }

    
//     function verifyDocumentExistence(bytes32 _documentHash) public view returns(bool){
//         require(userDocumentExist[_documentHash][msg.sender], "Document does not exist");
//         return true;
//     }

//     function getDocument()public view returns(Document[] memory){
//         return  addressToDocuments[msg.sender];
//     }

//     function getAllDocuments()public view returns(Document[] memory){
//         return documents;
//     }
    
// }


//SPDX-License-Idenfier:MIT
pragma solidity ^0.8.30;

contract ProofOfExistence {
    // store a document hash
    struct Document {
        uint16 id;
        bytes32  hashes;
        string description;
        uint256 stamp;
    }

    Document[] public documents;
    mapping(address => Document[]) public addressToDocuments;
    mapping(bytes32 => bool) public DocumentExist;
    address[] public documentAddress;
    // mapping(address => bool) userExist;

    event Registered(uint256 timeStamp, address indexed _sender);
    error DocumentAlreadyExist();

    function addDocument(bytes32 _documentHash, string memory _description) public {
        require(!DocumentExist[_documentHash], DocumentAlreadyExist());
        Document memory newDoc = Document({
            id: uint16(addressToDocuments[msg.sender].length + 1),
            hashes: bytes32(_documentHash),
            description: _description,
            stamp: block.timestamp
        });

        addressToDocuments[msg.sender].push(newDoc);
        documents.push(newDoc);
        DocumentExist[_documentHash] = true;

        emit Registered(block.timestamp, msg.sender);
    }

    function verifyDocumentExistence(bytes32 _documentHash) public view returns(bool){
        require(DocumentExist[_documentHash], DocumentAlreadyExist());
        return true;
    }

    function getDocument()public view returns(Document[] memory){
        return  addressToDocuments[msg.sender];
    }

    function getAllDocuments()public view returns(Document[] memory){
        return documents;
    }
}
