const AWS = require("aws-sdk");
const constants = require("../constants");
const cognito = new AWS.CognitoIdentityServiceProvider();

const confirmForgotPassword = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const params = {
      ClientId: constants.ClientId,
      Username: body.email,
      Password: body.password,
      ConfirmationCode: body.code,
    };
    const response = await cognito.confirmForgotPassword(params).promise();
    return { statusCode: 200, body: JSON.stringify({message: "Password reset successful"})  };
  } catch (error) {
    console.log(error);
    const message = error.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({message: message}) };
  }
};
module.exports = confirmForgotPassword;
