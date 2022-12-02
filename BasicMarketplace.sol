// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract BasicMarketplace {
    struct Product {
        uint8 id;
        address creator;
        address owner;
        string title;
        string description;
        uint8 askingPrice;
        bool isSold;
    }

    mapping(uint256 => Product) public products;
    event savingsEvent(uint256 indexed _productId);
    uint8 public numProduct;

    constructor() {
        numProduct = 0;
        addProduct("Flat TV", "TV that is flat", 100);
    }

    function addProduct(
        string memory title,
        string memory description,
        uint8 askingPrice
    ) public {
        Product storage product = products[numProduct]; // new instance of our product
        product.creator = msg.sender;
        product.owner = msg.sender;
        product.askingPrice = askingPrice;
        products[numProduct] = Product(
            numProduct,
            product.creator,
            product.owner,
            title,
            description,
            product.askingPrice,
            false
        );
        numProduct++;
    }

    //return a particular product
    function getProduct(uint256 productId)
        public
        view
        returns (Product memory)
    {
        return products[productId];
    }

    //return the array of products
    function getProducts() public view returns (Product[] memory) {
        Product[] memory id = new Product[](numProduct);
        for (uint256 i = 0; i < numProduct; i++) {
            Product storage product = products[i];
            id[i] = product;
        }
        return id;
    }

    // Mark as sold
    function sellProduct(uint256 productId) public {
        Product storage product = products[productId];
        product.owner = msg.sender;
        product.isSold = true;
    }
}
