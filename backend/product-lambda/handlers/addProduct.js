const AWS = require("aws-sdk");
const Ajv = require("ajv");
const ajv = new Ajv(); // options can be passed, e.g. {allErrors: true}

const uuid = require("uuid");
const constants = require("../constants");

const addProduct = async (event) => {
  try {
    const body = JSON.parse(event.body);
    validateData(body);

    AWS.config.credentials = {
      "accessKeyId": "AKIASVGLKLB6K6EQAUPJ",
      "secretAccessKey": "d6waIXEGNfm4qd3b96U4M+Bx3p9vodhylVYQzVym"
    };
    var s3 =new AWS.S3(),res={};
    body.ItemId = body.ItemName.replace(/\s/g,"")+ uuid.v4();

    if(body.Image1){

      var presignedPUTURL = s3.getSignedUrl('putObject', {
        Bucket: 's3-bucket-s3bucket-1wjvsaapgbhy2',
        Key: body.ItemId, //filename
        Expires: 500 //time to expire in seconds
      });
      body.Image1 = presignedPUTURL;
      res.Image1 = presignedPUTURL;
    }

    if(body.Image2){
      var presignedPUTURL = s3.getSignedUrl('putObject', {
        Bucket: 's3-bucket-s3bucketingreds-ydw7cqk3z7ig',
        Key: body.ItemId, //filename
        Expires: 500 //time to expire in seconds
      });
      body.Image2 = presignedPUTURL;
      res.Image2 = presignedPUTURL;

    }
    body.Visible = false;
    body.ItemType = "#";

    var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
    
    var params = {
      TableName: 'Items',
      Item: AWS.DynamoDB.Converter.marshall(body)
    };

    const data = await ddb.putItem(params).promise();
    return {statusCode: 200,body: JSON.stringify(res)};

  } catch (error) {
      const message = error?.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({ message: message }) };
  }
};

const validateData = (data) => {
  const schema = {
    type: "object",
    properties: {
      ItemName: {type: "string"},
      Image1: {type: "boolean"},
      Image2:{type:"boolean"},
      User:{type:"string"},
      ItemInfo:{type:"string"},
      Location:{type:"string"}
    },
    required: ["ItemName","User"],
    additionalProperties: false

  };
  const validate = ajv.compile(schema)
  const valid = validate(data)
  if (!valid) throw validate.errors;
  return true;
}
module.exports = addProduct;
