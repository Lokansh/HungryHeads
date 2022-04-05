const AWS = require("aws-sdk");

const searchProducts = async (event) => {
  try {
    const name = event.queryStringParameters?.name?.toLowerCase();
    console.log("event.query.search-------" + name);

    AWS.config.credentials = {
      accessKeyId: "AKIASVGLKLB6NH25UNHW",
      secretAccessKey: "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",
    };

    var dynamoDB = new AWS.DynamoDB();
    if (name != null) {
      var params = {
        TableName: "Items",
        ProjectionExpression:
          "ItemType, Image1, Image2, ItemName, ItemId, #usr, Ingreds",
        FilterExpression:
          "(contains (ItemName, :name) OR contains (ItemType, :category)) AND Visible = :visible",
        ExpressionAttributeNames: {
          "#usr": "User",
        },
        ExpressionAttributeValues: {
          ":name": { S: name },
          ":category": { S: name },
          ":visible": { BOOL: true },
        },
      };
    } else {
      var params = {
        TableName: "Items",
        FilterExpression: "Visible = :visible",
        ExpressionAttributeValues: {
          ":visible": { BOOL: true },
        },
      };
    }
    const result = await dynamoDB.scan(params).promise();

    // const s3 = new AWS.S3();
    // try {
    //   const params = {
    //     Bucket: "s3-bucket-s3bucket-1wjvsaapgbhy2",
    //     Key: "pastaacb1012e-6302-402c-b82e-e1c3bbdbb4b2",
    //   };

    //   const data = await s3.getObject(params).promise();
    //   console.log("data" + data);
    //   console.log("data--stringify" + JSON.stringify(data));
    //   //console.log("err" + err);
    //   console.log("data.Location" + data.Location);
    //   //return data.Body.toString('utf-8');
    // } catch (e) {
    //   throw new Error(`Could not retrieve file from S3: ${e.message}`);
    // }

    //console.log(JSON.stringify(result));
    return { statusCode: 200, body: JSON.stringify(result) };
  } catch (error) {
    const message = error?.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({ message: message }) };
  }
};

module.exports = searchProducts;
