const AWS = require("aws-sdk");

const getWishlist = async (event) => {
  try {
    const UserId = event.queryStringParameters?.UserId?.toLowerCase();

    AWS.config.credentials = {
      accessKeyId: "****",
      secretAccessKey: "****",
    };
    var dynamoDB = new AWS.DynamoDB();
    var params = {
      TableName: "Wishlist",
      FilterExpression: "UserId = :userId",
      ExpressionAttributeValues: {
        ":userId": { S: UserId },
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
