const AWS = require("aws-sdk");
// const textract = require("@aws-sdk/client-textract");
const constants = require("../constants");

const addProduct = async (event) => {
  try {
    const body = JSON.parse(event.body);
    // const REGION = "us-east-1";
    // const textractClient = new textract.TextractClient({ region: REGION });

    // const params = {
    //   Document: {
    //     S3Object: {
    //       Bucket: "s3-bucket-s3bucket-1wjvsaapgbhy2",
    //       Name: "hellman-mayo.pdf",
    //     },
    //   },
    // };
    // console.log("params set");
    // AWS.config.loadFromPath("./config.json");
    AWS.config.credentials = {
      "accessKeyId": "AKIASVGLKLB6K6EQAUPJ",
      "secretAccessKey": "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"
    };
    var s3 = new AWS.S3();

    // var params = {
    //   Bucket: "s3-bucket-s3bucket-1wjvsaapgbhy2",
    //   Key: body.name,
    //   Body: body.frontPhoto,
    // };

    // s3.upload(params, function (err, data) {
    //   if (err) {
    //     res.send({ error: err });
    //   }
    //   if (data) {
    //     res.status(200);
    //     return {
    //       statusCode: 200,
    //       body: JSON.stringify({ message: "Product added successfully" }),
    //     };
    //   }
    // });

    var presignedPUTURL = s3.getSignedUrl('putObject', {
      Bucket: 's3-bucket-s3bucket-1wjvsaapgbhy2',
      Key: body.name, //filename
      Expires: 500 //time to expire in seconds
    });
    // try {
    //   const aExpense = new textract.AnalyzeDocumentCommand(params);
    //   console.log("aexpense");
    //   const response = await textractClient.send(aExpense);
    //   console.log("response");
    //   console.log(response)
    //   response.ExpenseDocuments.forEach((doc) => {
    //     doc.LineItemGroups.forEach((items) => {
    //       items.LineItems.forEach((fields) => {
    //         fields.LineItemExpenseFields.forEach((expenseFields) => {
    //           console.log(expenseFields);
    //         });
    //       });
    //     });
    //   });
    //   // return response; // For unit tests.
    // } catch (err) {
    //   console.log("Error", err);
    // }

    return {
      statusCode: 200,
      body: JSON.stringify({ url: presignedPUTURL }),
    };
  } catch (error) {
    console.log(error);
    const message = error.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({ message: message }) };
  }
};

module.exports = addProduct;
