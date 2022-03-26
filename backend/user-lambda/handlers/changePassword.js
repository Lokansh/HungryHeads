const AWS = require("aws-sdk");

const cognito = new AWS.CognitoIdentityServiceProvider();

const changePassword = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const params = {
      AccessToken: body.accessToken,
      PreviousPassword: body.oldPassword,
      ProposedPassword: body.newPassword,
    };
    const response = await cognito.changePassword(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Password change successful" }),
    };
  } catch (error) {
    console.log(error);
    const message = error.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({message: message}) };
  }
};
module.exports = changePassword;
