//SPDX-License-Identifier:MIT
pragma solidity ^0.8.3

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract OnChainNft is ERC721URIStorage, Ownable{
    uint tokenIdCounter;

    constructor() ERC721("NTONGHO","NT") Ownable(msg.sender){}

    function mint(address _to) external OnlyOwner{
        tokenIdCounter++;
        _mint(_to, tokenIdCounter);

    }

    function tokenURI(uint256 tokenId) public pure override returns(string memory){
        string memory svg = "<svg width="400" height="400" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">"
            "<defs>
                <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" style="stop-color:#fdfcfb;stop-opacity:1" />
                <stop offset="100%" style="stop-color:#e2d1c3;stop-opacity:1" />
                </linearGradient>
            </defs>"
            
            "<rect width="100%" height="100%" fill="url(#grad1)" rx="20" />"

            "<path d="M150 320 
                    C 150 280, 130 250, 130 200 
                    C 130 130, 180 100, 220 100 
                    C 270 100, 300 150, 280 220 
                    C 270 260, 290 280, 300 320 
                    M 220 100 
                    C 200 80, 160 90, 140 130 
                    C 120 180, 150 210, 170 210
                    M 205 180
                    C 215 175, 235 175, 245 180
                    M 225 240
                    C 235 250, 255 245, 260 230" 
                    stroke="#333" 
                    stroke-width="3" 
                    fill="none" 
                    stroke-linecap="round" />"

            "<circle cx="260" cy="140" r="12" fill="#ff6b6b" opacity="0.8" />"
            "<circle cx="275" cy="155" r="8" fill="#feb236" opacity="0.8" />"
            
            "<path d="M220 100 Q 350 120, 320 300" 
                    stroke="#5d5d5d" 
                    stroke-width="2" 
                    fill="none" 
                    stroke-dasharray="5,5" />"
    "</svg>"

    string memory imageURI = string(abi.encodePacked("data:image/svg+xml;base64,",
    Base64.encode(bytes(svg))));

    string memory json = string(abi.encodePacked(
        '"name": "Ntongho #', Strings.toString(tokenId),'",
        "description":"NteeSeries",
        "image":"',imageURI,'", {"trait_type": "Background", "value": "Blue"}]}"'
    ));
    return string(
        abi.encodePacked("data:appliction/json;base64,",Base64.encode(bytes(json)));
    )
    }

}