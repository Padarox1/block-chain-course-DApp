// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MyERC20.sol";
// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract BorrowYourCar is ERC721 {

    // use an event to represent time, you can choose block.timestamp
    event CarBorrowed(uint256 carTokenId, address borrower, uint256 startTime, uint256 duration);

    struct Car {
        address owner;
        address borrower;
        uint256 borrowUntil;
        bool isBorrowed;
    }

    mapping(uint256 => Car) public cars; // A map from car token ID to its information
    uint256 public totalCars; // Total number of cars
    uint256 public totalRentedCars;
    MyERC20 public myERC20;
    uint256 tokenAmount;
    constructor() ERC721("BorrowYourCar", "BYC") {
        totalCars = 0;
        totalRentedCars = 0;
        tokenAmount = 0;
        myERC20 = new MyERC20("ZJUToken", "ZJUTokenSymbol");
    }

    function mintCar(address owner) internal returns (uint256) {
        uint256 newTokenId = totalCars;
        _mint(owner, newTokenId);
        totalCars++;
        return newTokenId;
    }

    function createCars() external {
        // Create and distribute NFTs representing cars to test users
        // For example, give NFTs to certain addresses for testing purposes
        address[] memory users = new address[](10);
        users[0] = address(uint160(0x859Ca8C1e19513660196B8d74A1fB4A08927A885));
        users[1] = address(uint160(0xE9e23470b6650aD812f3bf0bAA12B5a088DB18e7));
        users[2] = address(uint160(0x44218b38F3770209209ce9d180718Ff2a1b1B143));
        users[3] = address(uint160(0x1071FfC8Bde4ae5E57544135D06608cf65ea454F));
        users[4] = address(uint160(0x679678dafaeDF62DbD3aE50e2e8dCbd03cbfdCf6));
        users[5] = address(uint160(0x00aeBE263b9B67c34537e5f83fCEAa654595Cf87));
        users[6] = address(uint160(0xC4F84CEe0814Adf20E323a50150BFD903B1cCd0E));
        users[7] = address(uint160(0x88950d3B95C641184768FFA14d2f1bF042643f93));
        users[8] = address(uint160(0xc2dc570c655a29Ad5cc717A4AE64054eDd4B7Fa6));
        users[9] = address(uint160(0x2433B92a5Ed3F71d41A78d0f4521f29CFE8fE49B));
        //[address(0x30f270d7dc5a03391b3d9098116d78c419dc185bf7e4b58b4fc14fa0b583d57b), address(0xf13d4b0ab910c8d78bb22629c858ea73ee22d9b0a5e8bd462d48190c49bd14b3)];
        for (uint256 i = 0; i < 2; i++) {
            // Mint a car NFT and assign it to the user
            uint256 tokenId = mintCar(users[i]);
            // Update the car's owner in the cars mapping
            cars[tokenId].owner = users[i];
        }
        for (uint256 i = 0; i < 5; i++) {
                    // Mint a car NFT and assign it to the user
                    uint256 tokenId = mintCar(users[i]);
                    // Update the car's owner in the cars mapping
                    cars[tokenId].owner = users[i];
                }
        for (uint256 i = 0; i < 7; i++) {
                    // Mint a car NFT and assign it to the user
                    uint256 tokenId = mintCar(users[i]);
                    // Update the car's owner in the cars mapping
                    cars[tokenId].owner = users[i];
                }
         for (uint256 i = 0; i < 10; i++) {
                             // Mint a car NFT and assign it to the user
                             uint256 tokenId = mintCar(users[i]);
                             // Update the car's owner in the cars mapping
                             cars[tokenId].owner = users[i];
                         }
    }

    function getOwnedCars(address owner) external view returns (uint256[] memory) {
        // Get the list of car token IDs owned by a specific user
        uint256 counter = 0;
        for (uint256 i = 0; i < totalCars; i++) {
            if (ownerOf(i) == owner) {

                counter++;
            }
        }
        uint256[] memory ownedCars=new uint256[](counter) ;
        counter=0;
        for (uint256 i = 0; i < totalCars; i++) {
            if (ownerOf(i) == owner) {
                ownedCars[counter] = i;
                counter++;
            }
        }
        return ownedCars;
    }

    function getAvailableCars() external view returns (uint256[] memory) {
        // Get the list of available car token IDs (not currently borrowed)
        uint256[] memory availableCars = new uint256[](totalCars - totalRentedCars);
        uint256 counter = 0;
        for (uint256 i = 0; i < totalCars; i++) {
            if (ownerOf(i) != address(0) && !cars[i].isBorrowed) {
                availableCars[counter] = i;
                counter++;
            }
        }
        return availableCars;
    }

    function calculateBorrowCost( uint256 duration) public  returns (uint256) {
        // Calculate the cost of borrowing based on the car's characteristics and the duration
        // Add your logic here to determine the token amount required for borrowing
       tokenAmount = duration/3600 + 1; // Example: 1 token per hour of borrowing
        return tokenAmount;
    }

    function borrowCar(uint256 carTokenId, uint256 duration) external {
        require(ownerOf(carTokenId) != address(0), "Car does not exist");
        require(cars[carTokenId].borrower == address(0), "Car is already borrowed");

        address borrower = msg.sender;
        uint256 startTime = block.timestamp;
        uint256 borrowUntil = startTime + duration;
        calculateBorrowCost(duration);
        // Update the car's information
        cars[carTokenId].borrower = borrower;
        cars[carTokenId].borrowUntil = borrowUntil;
        cars[carTokenId].isBorrowed = true;
        totalRentedCars++;
        myERC20.transferFrom(msg.sender,address(this) , tokenAmount);
        myERC20.transfer(cars[carTokenId].owner, myERC20.balanceOf(address(this)));
        // emit CarBorrowed(carTokenId, borrower, startTime, duration);
    }
    function returnCar(uint256 carTokenId) external {

            // Update the car's information
            cars[carTokenId].borrower = address(0);
            cars[carTokenId].borrowUntil = 0;
            cars[carTokenId].isBorrowed = false;
            totalRentedCars--;
        }
     function borrowCar2(uint256 carTokenId, uint256 returnTime) external {
            require(ownerOf(carTokenId) != address(0), "Car does not exist");
            require(cars[carTokenId].borrower == address(0), "Car is already borrowed");

            address borrower = msg.sender;
            uint256 startTime = block.timestamp;
            uint256 borrowUntil = returnTime;

            // Update the car's information
            cars[carTokenId].borrower = borrower;
            cars[carTokenId].borrowUntil = borrowUntil;
            cars[carTokenId].isBorrowed = true;
            totalRentedCars++;
            emit CarBorrowed(carTokenId, borrower, startTime, returnTime - startTime);
        }

    function isCarBorrowed(uint256 carTokenId) external view returns (bool) {
        require(ownerOf(carTokenId) != address(0), "Car does not exist");
        return cars[carTokenId].isBorrowed;
    }

    function refreshCarStatus(uint256 carTokenId) external {
        require(ownerOf(carTokenId) != address(0), "Car does not exist");
        if (cars[carTokenId].isBorrowed && cars[carTokenId].borrowUntil < block.timestamp) {
            cars[carTokenId].isBorrowed = false;
            totalRentedCars--;
        }
    }

    function refreshAllCarStatus() external {
        for (uint256 i = 0; i < totalCars; i++) {
            if (cars[i].isBorrowed && cars[i].borrowUntil < block.timestamp) {
                cars[i].isBorrowed = false;
                cars[i].borrower = address(0);
                cars[i].borrowUntil = 0;
                totalRentedCars--;
            }
        }
    }

    function getAllCars() external view returns (uint256[] memory) {
        uint256[] memory allCars = new uint256[](totalCars);
        for (uint256 i = 0; i < totalCars; i++) {
            allCars[i] = i;
        }
        return allCars;
    }

     function getMyBorrowedCars(address borrower1) external view returns (uint256[] memory) {

            uint256 count = 0;

            for (uint256 i = 0; i < totalCars; i++) {
                 if (cars[i].borrower == borrower1&&cars[i].isBorrowed) {
                 count++;
            }}
             uint256[] memory MyBorrowedCars = new uint256[](count);
             count =0;
             for (uint256 i = 0; i < totalCars; i++) {
                  if (cars[i].borrower == borrower1 && cars[i].isBorrowed) {
                  MyBorrowedCars[count] = i;
                   count++;
             }

        }
        return MyBorrowedCars;
}
}
