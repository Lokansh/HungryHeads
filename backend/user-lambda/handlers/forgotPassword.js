const AWS = require("aws-sdk");
const constants = require("../constants");
const cognito = new AWS.CognitoIdentityServiceProvider();

const forgotPassword = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const params = {
      ClientId: constants.ClientId,
      Username: body.email
    };
    const response = await cognito.forgotPassword(params).promise();
    return { statusCode: 200, body: JSON.stringify(response) };
  } catch (error) {
    console.log(error);
    const message = error.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({message: message}) };
  }
};
module.exports = forgotPassword;
