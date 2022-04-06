const AWS = require("aws-sdk");

const getWishlist = async (event) => {
  try {
    const userId = event.queryStringParameters?.userId?.toLowerCase();

    AWS.config.credentials = {
      accessKeyId: "AKIASVGLKLB6NH25UNHW",
      secretAccessKey: "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",
    };
    var dynamoDB = new AWS.DynamoDB();
    var params = {
      TableName: "Wishlist",
      FilterExpression: "#usr = :userId",
      ExpressionAttributeNames: {
        "#usr": "User",
      },
      ExpressionAttributeValues: {
        ":userId": { S: userId },
      },
    };
    const result = await dynamoDB.scan(params).promise();
    const jsonResult = result.Items.map((item) =>
      AWS.DynamoDB.Converter.unmarshall(item)
    );
    return { statusCode: 200, body: JSON.stringify(jsonResult) };
  } catch (error) {
    const message = error?.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({ message: message }) };
  }
};
module.exports = getWishlist;
