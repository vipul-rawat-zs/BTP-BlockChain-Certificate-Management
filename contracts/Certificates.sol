// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Certificates {
    uint public certificate_counter;

    // Structs
    struct Certificate {
        string ipfsHash;
        uint timeOfIssue;
        address issuer;
        address recipient;
    }

    // Mappings
    mapping(string => address) public issuerOfCertificate;
    mapping(address => address) public issuer;
    mapping(address => address) recipient;
    mapping(string => address[]) allRecipientOfCertificate;
    mapping(uint => Certificate) certificateIdentifier;
    mapping(address => uint[]) recipientCertificates;
    mapping(address => uint[]) issuerCertificates;
    mapping(address => bool) isIssuer;
    mapping(address => bool) isRecipient;
    mapping(string => bool) isVerified;

    // Events
    event IssuerRegistered(address indexed issuer, address indexed issuerPK);
    event RecipientRegistered(address indexed recipient, address studentPK);
    event CertificateRegistered(address indexed issuer, string _ipfsHash);
    event CertificateVerified(address indexed issuer, string _ipfsHash);
    event CertificateIssued(uint indexed certificate, address indexed issuer, address indexed recipient);

    // Functions
    function registerIssuer(address issuerPK) public {
        // require((isIssuer[msg.sender] == true), "Illegal operation");
        require((isIssuer[issuerPK] == false), "Issuer already registered");
        issuer[msg.sender] = issuerPK;
        isIssuer[msg.sender] = true;
        emit IssuerRegistered(msg.sender, issuerPK);
    }

    function registerRecipient(address studentPK) public {
        require(isRecipient[msg.sender] == false, "Recipient already registered");
        recipient[msg.sender] = studentPK;
        isRecipient[studentPK] = true;
        emit RecipientRegistered(msg.sender, studentPK);
    }

    function registerCertificate(string memory _ipfsHash) public {
        require(isIssuer[msg.sender] == true, "Issuer not registered to register a certificate");
        issuerOfCertificate[_ipfsHash] = msg.sender;
        emit CertificateRegistered(msg.sender, _ipfsHash);
    }

    function issueCertificate(address _recipient, string memory certificate_hash) public {
        require(isIssuer[msg.sender] == true, "Issuer not registered to register a certificate");
        require(isRecipient[_recipient] == true, "Recipient not registered to be issued a certificate");
        require(issuerOfCertificate[certificate_hash] == msg.sender, "Issuer not registered to issue this certificate");
        require(isVerified[certificate_hash] == true, "Certificate not verified");
        Certificate memory cert;
        uint id = ++certificate_counter;
        cert.ipfsHash = certificate_hash;
        cert.timeOfIssue = block.timestamp;
        cert.issuer = msg.sender;
        cert.recipient = _recipient;
        certificateIdentifier[id] = cert;
        recipientCertificates[_recipient].push(id);
        issuerCertificates[msg.sender].push(id);
        allRecipientOfCertificate[certificate_hash].push(_recipient);

        emit CertificateIssued(id, msg.sender, _recipient);
    }
    
    function verify(string memory certificate_hash) public {
        require(isRecipient[msg.sender] == true, "Recipient not registered to verify a certificate");
        require(issuerOfCertificate[certificate_hash] != address(0), "Certificate not registered");
        // require(allRecipientOfCertificate[certificate_hash].length > 0, "Certificate not issued to any recipient");
        if(isVerified[certificate_hash] == false) {
            isVerified[certificate_hash] = true;
            emit CertificateVerified(msg.sender, certificate_hash);
        }
        isVerified[certificate_hash] = true;
    }

    function getIssuerOfCertificate(string memory _ipfsHash) public view returns (address) {
        return issuerOfCertificate[_ipfsHash];
    }

    function getIssuer(address _issuer) public view returns (address) {
        return issuer[_issuer];
    }

    function getRecipient(address _recipient) public view returns (address) {
        return recipient[_recipient];
    }

    function getAllRecipientOfCertificate(string memory _ipfsHash) public view returns (address[] memory) {
        return allRecipientOfCertificate[_ipfsHash];
    }

    function getRecipientCertificates(address _recipient) public view returns (uint[] memory) {
        return recipientCertificates[_recipient];
    }

    function getIssuerCertificates(address _issuer) public view returns (uint[] memory) {
        return issuerCertificates[_issuer];
    }

    function getCertificateIdentifier(uint _id) public view returns (string memory, uint, address, address){
        Certificate memory cert = certificateIdentifier[_id];
        return (cert.ipfsHash, cert.timeOfIssue, cert.issuer, cert.recipient);
    }

}