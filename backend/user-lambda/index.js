const signUp = require("./handlers/signup");
const verification = require("./handlers/verification");
const login = require("./handlers/login");
const forgotPassword = require("./handlers/forgotPassword");
const resendCode = require("./handlers/resendCode");
const confirmForgotPassword = require("./handlers/confirmForgotPassword");
const logout = require("./handlers/logout");
const changePassword = require("./handlers/changePassword");

module.exports.handler = async (event) => {
  
  switch (event["path"]) {
    case "/api/user/signup":
      const signupResponse = signUp(event);
      return signupResponse;
    case "/api/user/verification":
      const verificationResponse = verification(event);
      return verificationResponse;
    case "/api/user/login":
      const loginResponse = login(event);
      return loginResponse;
    case "/api/user/forgotPassword":
      const forgotPasswordResponse = forgotPassword(event);
      return forgotPasswordResponse;
    case "/api/user/resendCode":
      const resendCodeResponse = resendCode(event);
      return resendCodeResponse;
    case "/api/user/confirmForgotPassword":
      const confirmForgotPassowrdResponse = confirmForgotPassword(event);
      return confirmForgotPassowrdResponse;
    case "/api/user/logout":
      const logoutResponse = logout(event);
      return logoutResponse;
    case "/api/user/changePassword":
      const changePasswordResponse = changePassword(event);
      return changePasswordResponse;
  }
};
