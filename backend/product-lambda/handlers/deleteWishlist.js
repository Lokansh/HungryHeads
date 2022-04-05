const AWS = require("aws-sdk");

const deleteWishlist = async (event) => {
  try {
    const wishlistId = event.queryStringParameters?.wishlistId?.toLowerCase();

    AWS.config.credentials = {
      accessKeyId: "AKIASVGLKLB6NH25UNHW",
      secretAccessKey: "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",
    };
    var dynamoDB = new AWS.DynamoDB();
    var params = {
      TableName: "Wishlist",
      Key: {
        WishlistId: { S: wishlistId },
      },
    };
    const result = await dynamoDB.deleteItem(params).promise();
    return { statusCode: 200, body: JSON.stringify(result) };
  } catch (error) {
    const message = error?.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({ message: message }) };
  }
};
module.exports = deleteWishlist;
