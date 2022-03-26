const AWS = require("aws-sdk");
const constants = require("../constants");
const cognito = new AWS.CognitoIdentityServiceProvider();

const verification = async (event) => {
  try {
    const body = JSON.parse(event.body);

    let params;
    if(validateEmail(body.username)) {
      const listParams = {
        UserPoolId: "us-east-1_L62BPtSMc",
        AttributesToGet: [
         "email",
       ],
        Filter: "email="+JSON.stringify(body.username)
      };
        const listResponse = await cognito.listUsers(listParams).promise();
        params = {
          ClientId: constants.ClientId,
          Username: listResponse.Users[0].Username,
          ConfirmationCode: body.code,
        };
    } else {
      params = {
        ClientId: constants.ClientId,
        Username: body.username,
        ConfirmationCode: body.code,
      };
    }

    const response = await cognito.confirmSignUp(params).promise();
    return { statusCode: 200, body: JSON.stringify({message: "User verified successfully"})  };
  } catch (error) {
    console.log(error);
    const message = error.message ? error.message : "Internal server error";
    return { statusCode: 500, body: JSON.stringify({message: message}) };
  }
};

const validateEmail = (email) => {
  var pattern = /^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$/;
  if(email.match(pattern)) {
    return true;
  }
  return false;
}

module.exports = verification;
