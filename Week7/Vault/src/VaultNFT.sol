// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol"; 
import {Vault} from "./Vault.sol";

contract VaultNFT is ERC721, Ownable {
    using Strings for uint256;
    using Strings for address;

    uint256 private _nextTokenId;

    mapping(uint256 => address) public vaultOfToken;
    mapping(address => uint256) public tokenOfVault;

    constructor(address _vaultFactory)
        ERC721("Vault", "VT")
        Ownable(_vaultFactory)
    {}

    function mint(address _to, address _vaultAddress) external onlyOwner returns (uint256) {
        uint256 id = _nextTokenId;

        vaultOfToken[id]            = _vaultAddress;
        tokenOfVault[_vaultAddress] = id;

        _safeMint(_to, id);
        _nextTokenId++;

        return id;
    }

    function _generateSVG(
        string memory tokenName,
        string memory tokenSymbol,
        string memory tokenAddr,
        string memory amount
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" width="350" height="350">',
            '<rect width="350" height="350" fill="#0f0c29" rx="16"/>',
            '<text x="175" y="60" text-anchor="middle" font-family="monospace" font-size="18" font-weight="bold" fill="white">VAULT NFT</text>',
            '<line x1="30" y1="80" x2="320" y2="80" stroke="#7c3aed" stroke-width="1"/>',
            '<text x="30" y="120" font-family="monospace" font-size="11" fill="#60a5fa">TOKEN NAME</text>',
            '<text x="30" y="145" font-family="monospace" font-size="16" font-weight="bold" fill="white">', tokenName, ' (', tokenSymbol, ')</text>',
            '<text x="30" y="190" font-family="monospace" font-size="11" fill="#60a5fa">TOKEN ADDRESS</text>',
            '<text x="30" y="212" font-family="monospace" font-size="11" fill="#ffffff">', tokenAddr, '</text>',
            '<text x="30" y="258" font-family="monospace" font-size="11" fill="#60a5fa">AMOUNT DEPOSITED</text>',
            '<text x="30" y="295" font-family="monospace" font-size="28" font-weight="bold" fill="#a78bfa">', amount, '</text>',
            '<text x="30" y="318" font-family="monospace" font-size="13" fill="#7c3aed">', tokenSymbol, '</text>',
            '</svg>'
        ));
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        address vaultAddr = vaultOfToken[_tokenId];
        Vault vault = Vault(vaultAddr);

        address tokenAddr = vault.tokenAddress();
        IERC20Metadata token = IERC20Metadata(tokenAddr); 

        string memory name = token.name();
        string memory symbol = token.symbol();
        string memory amount = vault.totalLiquidity().toString();
        string memory addrStr= tokenAddr.toHexString();

        string memory svg  = _generateSVG(name, symbol, addrStr, amount);
        string memory json = string(abi.encodePacked(
            '{"name":"', name, ' Vault #', _tokenId.toString(), '",',
            '"description":"Onchain vault NFT for ', name, '",',
            '"image":"data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,", Base64.encode(bytes(json))
        ));
    }
}