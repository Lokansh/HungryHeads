const addProduct = require("./handlers/addProduct");
const searchProducts = require("./handlers/searchProducts");
const addWishlist = require("./handlers/addWishlist");
const getWishlist = require("./handlers/getWishlist");
const deleteWishlist = require("./handlers/deleteWishlist");

module.exports.handler = async (event) => {
  switch (event["path"]) {
    case "/api/product/add":
      const addResponse = addProduct(event);
      return addResponse;
    case "/api/product/search":
      const searchProductsResponse = searchProducts(event);
      return searchProductsResponse;
    case "/api/product/addWishlist":
      const addWishlistResponse = addWishlist(event);
      return addWishlistResponse;
    case "/api/product/getWishlist":
      const getWishlistResponse = getWishlist(event);
      return getWishlistResponse;
    case "/api/product/deleteWishlist":
      const deleteWishlistResponse = deleteWishlist(event);
      return deleteWishlistResponse;
  }
};
