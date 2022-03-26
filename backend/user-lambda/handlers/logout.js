const AWS = require("aws-sdk");

const cognito = new AWS.CognitoIdentityServiceProvider();

const logout = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const params = {
        AccessToken: body.accessToken
    };
    const response = await cognito.globalSignOut(params).promise();
    return { statusCode: 200, body: JSON.stringify({message: "Logout successfull"}) };
  } catch (error) {
    console.log(error);
    const message = error.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({message: message}) };
  }
};
module.exports = logout;
