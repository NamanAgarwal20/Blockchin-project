// ReviewSystem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReviewSystem {
    struct Review {
        string reviewerName;
        string productName;
        string reviewContent;
        uint256 rating;
    }

    Review[] public reviews;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    event ReviewSubmitted(string reviewerName, string productName, uint256 rating);
    event ReviewChecked(uint256 indexed reviewIndex, bool isFake);

    function submitReview(string memory _reviewerName, string memory _productName, string memory _reviewContent, uint256 _rating) public {
        require(bytes(_reviewerName).length > 0, "Reviewer name must not be empty");
        require(bytes(_productName).length > 0, "Product name must not be empty");
        require(bytes(_reviewContent).length > 0, "Review content must not be empty");
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5");

        Review memory newReview = Review({
            reviewerName: _reviewerName,
            productName: _productName,
            reviewContent: _reviewContent,
            rating: _rating
        });

        reviews.push(newReview);
        emit ReviewSubmitted(_reviewerName, _productName, _rating);
    }

    function checkReview(uint256 reviewIndex) public view returns (bool) {
        require(reviewIndex < reviews.length, "Review index out of bounds");
        Review memory review = reviews[reviewIndex];
        
        // Logic for checking if the review is fake
        if (review.rating > 3 && (containsWord(review.reviewContent, "bad") || containsWord(review.reviewContent, "poor") || containsWord(review.reviewContent, "worst"))) {
            return true; // Considered fake
        } else if (review.rating < 3 && (containsWord(review.reviewContent, "amazing") || containsWord(review.reviewContent, "good") || containsWord(review.reviewContent, "excellent"))) {
            return true; // Considered fake
        } else if (wordCount(review.reviewContent) < 5) {
            return true; // Considered fake
        } else if (!checkProductType(review.productName, review.reviewContent)) {
            return true; // Considered fake
        } else {
            return false; // Not fake
        }
    }

    function getReview(uint256 reviewIndex) public view returns (string memory, string memory, string memory, uint256) {
        require(reviewIndex < reviews.length, "Review index out of bounds");
        Review memory review = reviews[reviewIndex];
        return (review.reviewerName, review.productName, review.reviewContent, review.rating);
    }
    
    // Function to check if a word exists in a string
    function containsWord(string memory _string, string memory _word) internal pure returns (bool) {
        bytes memory stringBytes = bytes(_string);
        bytes memory wordBytes = bytes(_word);

        uint256 stringLength = stringBytes.length;
        uint256 wordLength = wordBytes.length;

        for (uint256 i = 0; i < stringLength - wordLength + 1; i++) {
            bool found = true;
            for (uint256 j = 0; j < wordLength; j++) {
                if (stringBytes[i + j] != wordBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return true;
            }
        }
        return false;
    }
    
    // Function to count the number of words in a string
    function wordCount(string memory _string) internal pure returns (uint256) {
        uint256 count = 0;
        bool inWord = false;
        bytes memory stringBytes = bytes(_string);
        
        for (uint256 i = 0; i < stringBytes.length; i++) {
            if (stringBytes[i] == bytes1(" ")) {
                if (inWord) {
                    count++;
                    inWord = false;
                }
            } else {
                inWord = true;
            }
        }
        
        if (inWord) {
            count++;
        }
        
        return count;
    }
    
    // Function to check if the product type matches the product name
    function checkProductType(string memory _productName, string memory _reviewContent) internal pure returns (bool) {
        // Check if product name contains keywords indicating product type
        bool isLaptop = containsWord(_productName, "laptop");
        bool isMobile = containsWord(_productName, "mobile");
        bool isHeadphone = containsWord(_productName, "headphone");
        bool isWatch = containsWord(_productName, "watch");
        
        // Check if review content mentions the same product type
        if ((isLaptop && containsWord(_reviewContent, "laptop")) ||
            (isMobile && containsWord(_reviewContent, "mobile")) ||
            (isHeadphone && containsWord(_reviewContent, "headphone")) ||
            (isWatch && containsWord(_reviewContent, "watch"))) {
            return true;
        }
        
        return false;
    }
}