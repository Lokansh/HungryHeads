const AWS = require("aws-sdk");
const constants = require("../constants");
const cognito = new AWS.CognitoIdentityServiceProvider();

const signup = async (event) => {
  try {
    const body = JSON.parse(event.body);

    const listParams = {
      UserPoolId: "us-east-1_L62BPtSMc",
      AttributesToGet: ["email"],
      Filter: "email=" + JSON.stringify(body.email),
    };
    const listResponse = await cognito.listUsers(listParams).promise();
    if (listResponse.Users && listResponse.Users.length > 0) {
      return {
        statusCode: 500,
        body: JSON.stringify({ message: "Account with email already exists" }),
      };
    }
    const params = {
      ClientId: constants.ClientId,
      Username: body.username,
      UserAttributes: [
        {
          Name: "email",
          Value: body.email,
        },
      ],
      Password: body.password,
    };

    const response = await cognito.signUp(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify({ message: "User created successfully" }),
    };
  } catch (error) {
    console.log(error);
    const message = error.message ? error.message : "Internal server error";

    if (error.code === "UsernameExistsException") {
      return { statusCode: 500, body: JSON.stringify({ message: "Username already exists" }) };
    }
    return { statusCode: 500, body: JSON.stringify({ message: message }) };
  }
};

module.exports = signup;
