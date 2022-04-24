const AWS = require("aws-sdk");

const searchProducts = async (event) => {
  try {
    const name = event.queryStringParameters?.name?.toLowerCase();
    const userId = event.queryStringParameters?.userId;
    console.log(
      "event.query.name-------" + name + "event.query.userId" + userId
    );

    AWS.config.credentials = {
      accessKeyId: "****",
      secretAccessKey: "****",
    };

    var dynamoDB = new AWS.DynamoDB();

    var userParams = {
      TableName: "Recommendation",
      FilterExpression: "UserId = :userId",
      ExpressionAttributeValues: {
        ":userId": { S: userId },
      },
    };
    const userResult = await dynamoDB.scan(userParams).promise();
    const jsonUserResult = userResult.Items.map((item) =>
      AWS.DynamoDB.Converter.unmarshall(item)
    );
    console.log("jsonUserResult" + JSON.stringify(jsonUserResult));

    var userSearchHistoryCategory = jsonUserResult[0]?.SearchHistory;
    console.log("userSearchHistory--------" + userSearchHistoryCategory);

    if (name != null) {
      //when user has provided name to search
      var params = {
        TableName: "Items",
        ProjectionExpression:
          "ItemType, Image1, Image2, ItemName, ItemId, #usr, Ingreds",
        FilterExpression:
          "(contains (ItemName, :name) OR ItemType = :category) AND Visible = :visible",
        ExpressionAttributeNames: {
          "#usr": "User",
        },
        ExpressionAttributeValues: {
          ":name": { S: name },
          ":category": { S: name },
          ":visible": { BOOL: true },
        },
      };
    } else if (userSearchHistoryCategory != null) {
      //when no name is passed but user has previous search history
      var params = {
        TableName: "Items",
        ProjectionExpression:
          "ItemType, Image1, Image2, ItemName, ItemId, #usr, Ingreds",
        FilterExpression: "ItemType = :category AND Visible = :visible",
        ExpressionAttributeNames: {
          "#usr": "User",
        },
        ExpressionAttributeValues: {
          ":category": { S: userSearchHistoryCategory },
          ":visible": { BOOL: true },
        },
      };
    } else if (userSearchHistoryCategory == null) {
      //when new user with no name nor search history
      var params = {
        TableName: "Items",
        ProjectionExpression:
          "ItemType, Image1, Image2, ItemName, ItemId, #usr, Ingreds",
        FilterExpression: "Visible = :visible",
        ExpressionAttributeNames: {
          "#usr": "User",
        },
        ExpressionAttributeValues: {
          ":visible": { BOOL: true },
        },
      };
    }
    const scanResult = await dynamoDB.scan(params).promise();
    const jsonResponse = scanResult.Items.map((item) =>
      AWS.DynamoDB.Converter.unmarshall(item)
    );
    var recommendBody = {};

    if (name != null && Object.keys(jsonResponse).length > 0) {
      recommendBody.RecommendId = userId;
      recommendBody.UserId = userId;
      recommendBody.SearchHistory = jsonResponse[0]?.ItemType;
    }
    console.log("recommendBody----" + JSON.stringify(recommendBody));

    if (Object.keys(recommendBody).length > 0) {
      console.log("has data");
      var recommendParams = {
        TableName: "Recommendation",
        Item: AWS.DynamoDB.Converter.marshall(recommendBody),
      };
      const data = await dynamoDB.putItem(recommendParams).promise();
      console.log("Data saved/updated on recommendation");
    }

    return { statusCode: 200, body: JSON.stringify(jsonResponse) };
  } catch (error) {
    const message = error?.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({ message: message }) };
  }
};

module.exports = searchProducts;
