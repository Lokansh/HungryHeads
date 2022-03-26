const addProduct = require("./handlers/addProduct");

module.exports.handler = async (event) => {
  
  switch (event["path"]) {
    case "/api/product/add":
      const addResponse = addProduct(event);
      return addResponse;
  }
};
