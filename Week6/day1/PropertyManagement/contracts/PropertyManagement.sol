// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;
import {MyToken} from "./MyToken.sol";

contract PropertyManagement{
    uint8 propCount;
    address owner;
    
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

    modifier isOwner(uint8 _id){
        for(uint8 i; i<props.length; i++){
            if(msg.sender != props[i].propOwner){
                revert NOT_OWNER();
            }
        }
        _;
    }



    function addProperty(string memory _name, string memory _location,uint256 _price, string memory _description) external {

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
                paymentToken.transferFrom(msg.sender,paymentAddress, price);

                props[i].isSold = true;
                props[i].propOwner = msg.sender;
                break;
            }
        }
    }

    function deleteProperty(uint8 _id) external isOwner(_id) {
        for(uint8 i; i<props.length; i++){
            if(props[i].id == _id){
                

                props[i] = props[props.length - 1];
                props.pop();
            }
        }
    }

    function getAllProperties() external view returns(Property[] memory){
        return props;
    }

    function getUnsoldProperties() external returns(Property[] memory) {
       Property[] memory active;
        for(uint8 i; i<props.length; i++){
            if(props[i].isSold == false){
               // return props[i];
            }
        }
    }

}