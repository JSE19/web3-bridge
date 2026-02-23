// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;
import {MyToken} from "./MyToken.sol";

contract PropertyManagement{
    uint8 propCount;
    address owner;
    address callerAddress;
    MyToken public paymentToken;

    error NOT_OWNER();

    struct Property{
        uint8 id;
        string name;
        string location;
        address propOwner;
        uint256 price;
        string description;
        bool isSold;
        uint256 createdAt;
    }

    Property[] public props;

    constructor(address _tokenAddress){
        owner = msg.sender;
        paymentToken = MyToken(_tokenAddress);
    }

    modifier isOwner{
        if(owner != msg.sender){
            revert NOT_OWNER() ;
        }
        _;
    }



    function addProperty(string memory _name, string memory _location,uint256 _price, string memory _description) external {

        callerAddress = msg.sender;
        propCount = propCount + 1;

        require(_price > 0, "Price must by Greater Than 0");
        Property memory newProperty = Property(propCount, _name, _location, msg.sender, _price, _description, false, block.timestamp);

        props.push(newProperty);

    }


    function buyProperty(uint8 _id) external {
        for(uint8 i; i<props.length; i++){
            if(props[i].id == _id){
                address paymentAddress = props[i].propOwner;
                uint256 price = props[i].price;
                paymentToken.transfer(paymentAddress, price);

                props[i].isSold = true;
                break;
            }
        }
    }

    function deleteProperty(uint _id) external {
        for(uint8 i; i<props.length; i++){
            if(props[i].id == _id){
                require(props[i].propOwner == callerAddress);

                props[i] = props[props.length - 1];
                props.pop();
            }
        }
    }

    function getUnsoldProperties() public external returns(props []){
        Property[] memory active
    }

}