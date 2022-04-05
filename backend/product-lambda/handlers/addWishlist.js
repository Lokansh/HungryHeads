const AWS = require("aws-sdk");
const Ajv = require("ajv");
const ajv = new Ajv(); // options can be passed, e.g. {allErrors: true}

const addWishlist = async (event) => {
  try {
    const body = JSON.parse(event.body);
    //validateData(body);

    AWS.config.credentials = {
      accessKeyId: "AKIASVGLKLB6K6EQAUPJ",
      secretAccessKey: "d6waIXEGNfm4qd3b96U4M+Bx3p9vodhylVYQzVym",
    };
    body.WishlistId =
      body.User.replace(/\s/g, "") + body.ItemId.replace(/\s/g, "");

    var dynamoDB = new AWS.DynamoDB({ apiVersion: "2012-08-10" });

    var params = {
      TableName: "Wishlist",
      Item: AWS.DynamoDB.Converter.marshall(body),
    };
    const data = await dynamoDB.putItem(params).promise();
    console.log("data" + JSON.stringify(data));
    return { statusCode: 200, body: JSON.stringify(data) };
  } catch (error) {
    console.log("error" + error);
    const message = error?.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({ message: message }) };
  }
};

// const validateData = (data) => {
//   const schema = {
//     type: "object",
//     properties: {
//       User: { type: "string" },
//       ItemId: { type: "string" },
//       // ItemType: { type: "string" },
//       // Image1: { type: "string" },
//       // Image2: { type: "string" },
//       // ItemName: { type: "string" },
//       // Ingreds: { type: "string" },
//     },
//     required: ["ItemId", "User"],
//     additionalProperties: false,
//   };
//   const validate = ajv.compile(schema);
//   const valid = validate(data);
//   if (!valid) throw validate.errors;
//   return true;
// };

module.exports = addWishlist;
