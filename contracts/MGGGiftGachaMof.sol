// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';

contract MGGGiftGachaMof is
    Ownable,
    Pausable,
    AccessControl,
    ERC1155
{
    // Librarys
    using Strings for uint256;

    // Error functions
    error CallerIsNotUser(address);
    error InsufficientBalance(uint256);

    // Contract Info
    string public name;
    string public symbol;

    // Roles
    bytes32 public constant ADMIN = keccak256("ADMIN");

    // Mint Parameters
    uint256 public cost = 10000000000000000;  // 0.01MATIC (dev)

    // Uri
    string public baseURI;
    string public baseExtention;

    // Addresses
    address payable public withdrawAddress     = payable(0x1a2f4bB65b98A294ce342b64e99667cd149b7caf);
    address payable public momsAddress         = payable(0x24E060A94De09250f4A293616168F7f20d1F48E5);
    address payable public devAddress          = payable(0xF2b12AAa4410928eB8C1a61C0a7BB0447b930303);
    address payable public contributorAddress1 = payable(0x22a61e1314687345E35EDD1955FA2c21b72d28B1);
    address payable public contributorAddress2 = payable(0x0892E00684B1517863Eb831384ea0b0D9f5b18e6);


    constructor() ERC1155("") {
        name = "MGG Gift Gacha for MOF";
        symbol = "GGM";

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN, _msgSender());

        _pause();

        setBaseURI("https://arweave.net/QnyIBNyEJ8hwx27WbN-oZ3ymbCjMXr15Bl5LEg2A7Og/json/");
        setBaseExtention(".json");
    }


    /**
     * Standard functions
     */
    function mint(uint256 _mintAmount)
        external
        payable
        whenNotPaused
    {
        if (cost * _mintAmount > msg.value) revert InsufficientBalance(cost);
        if (tx.origin != msg.sender) revert CallerIsNotUser(msg.sender);

        uint256[] memory mintAmountEachTokens = new uint256[](11);
        uint256 countIds;

        for (uint256 i=0; i<_mintAmount; i++) {
            uint256 time = block.timestamp;
            bytes32 randomValue = keccak256(abi.encodePacked(msg.sender, "-", time, "-", i));
            uint256 tokenSeed = uint256(randomValue) % 21 + 1;
            
            if (tokenSeed == 11) mintAmountEachTokens[tokenSeed - 1]++;
            else if (tokenSeed % 10 == 0) mintAmountEachTokens[10 - 1]++;
            else mintAmountEachTokens[tokenSeed % 10 - 1]++;
        }

        for (uint256 i=0; i<mintAmountEachTokens.length; i++) {
            if (mintAmountEachTokens[i] > 0) countIds++;
        }

        uint256[] memory ids = new uint256[](countIds);
        uint256[] memory amounts = new uint256[](countIds);
        uint256 idx;

        for (uint256 i=0; i<mintAmountEachTokens.length; i++) {
            if (mintAmountEachTokens[i] > 0) {
                ids[idx] = i + 1;
                amounts[idx] = mintAmountEachTokens[i];
                idx++;
            }
        }

        _mintBatch(msg.sender, ids, amounts, "");
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return
            AccessControl.supportsInterface(interfaceId) ||
            ERC1155.supportsInterface(interfaceId);
    }

    function withdraw()
        public
        payable
        onlyRole(ADMIN)
    {
        uint256 balance = address(this).balance;

        // withdrawing for moms wallet
        (bool mom, ) = payable(momsAddress).call{value: balance * 20 / 100}('');
        require(mom);

        // withdrawing for dev wallet
        (bool dev, ) = payable(devAddress).call{value: balance * 20 / 100}('');
        require(dev);

        // withdrawing for contributor's wallet
        (bool cont1, ) = payable(contributorAddress1).call{value: balance * 20 / 100}('');
        require(cont1);

        // withdrawing for contributor's wallet
        (bool cont2, ) = payable(contributorAddress2).call{value: balance * 20 / 100}('');
        require(cont2);

        // withdrawing for dao wallet remainder
        (bool os, ) = payable(withdrawAddress).call{value: balance * 20 / 100}('');
        require(os);
    }

    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(baseURI, _tokenId.toString(), baseExtention));
    }


    /**
     * Pause / Unpause
     */
    function pause()
        external
        onlyRole(ADMIN)
    {
        _pause();
    }

    function unpause()
        external
        onlyRole(ADMIN)
    {
        _unpause();
    }


    /**
     * Setter functions
     */
    function setCost(uint256 _cost)
        external
        onlyRole(ADMIN)
    {
        cost = _cost;
    }

    function setWithdrawAddress(address payable _value)
        external
        onlyRole(ADMIN)
    {
        withdrawAddress = _value;
    }

    function setMomsAddress(address payable _value)
        external
        onlyRole(ADMIN)
    {
        momsAddress = _value;
    }

    function setBaseURI(string memory _uri)
        public
        onlyRole(ADMIN)
    {
        baseURI = _uri;
    }

    function setBaseExtention(string memory _extention)
        public
        onlyRole(ADMIN)
    {
        baseExtention = _extention;
    }
}