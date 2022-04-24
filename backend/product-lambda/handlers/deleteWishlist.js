const AWS = require("aws-sdk");

const deleteWishlist = async (event) => {
  try {
    const wishlistId = event.queryStringParameters?.wishlistId?.toLowerCase();

    AWS.config.credentials = {
      accessKeyId: "****",
      secretAccessKey: "****",
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
    console.log("error--" + error);
    const message = error?.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({ message: message }) };
  }
};
module.exports = deleteWishlist;
