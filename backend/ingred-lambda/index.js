const AWS = require("aws-sdk");
const pluralize = require("pluralize");

const config = require("./config");

var ingredType = require('./final-ingreds-type.json'); 
var ingred = require('./ingreds.json'); 
var ingreds = ingred.ingredients;

var ingredCom ={
    "vegan":1,
    "vegetarian":2,
    "egg":3,
    "non-vegetarian":4
}

var reverseIngredCom ={
    1:"vegan",
    2:"vegetarian",
    3:"egg",
    4:"non-vegetarian"
}

module.exports.handler = async (event) => {
    var imageData = event?.Records[0]?.s3;
    var key = imageData?.object?.key;

    AWS.config.update({
        accessKeyId: config.accessKeyId,
        secretAccessKey: config.secretAccessKey,
        region: config.region
      });

    const client = new AWS.Textract();

    const params = {
        Document: {
                S3Object: {
                    Bucket: imageData?.bucket?.name,
                    Name:key
                }
            },
        }
    
    try {
        const res = await client.detectDocumentText(params).promise();
        
        var ingreds = getIngreds(res);

        var map = getMapping(ingreds.checked);
        mapping = map[0]
        reason = map[1]
        var db = new AWS.DynamoDB();
        var table = "Items";
        if(key.includes(".")){
            var dataname = key.split('.')[0];
        }
        else{
            var dataname = key;
        }
        var params2 = {
            TableName:table,
            Key:{
                "ItemId": {
                    S:dataname
                },
                "ItemType": {
                    S:"#"
                }
            }
        };

        var data1 = await db.getItem(params2).promise();

        if(data1){
            realData= AWS.DynamoDB.Converter.unmarshall(data1.Item);
            realData.Visible = true;
            realData.Ingreds = ingreds.results;
            realData.Detected = ingreds.checked;
            realData.ItemType = mapping;
            realData.reasonIngre = reason;
            // To manually add product type
            if(realData.ItemName.includes("#")){
                realData.ItemType = realData.ItemName.split("#")[1];
                realData.ItemName = realData.ItemName.split("#")[0]
            }

            var deleteData= await db.deleteItem(params2).promise();

            var params3 = {
                TableName: 'Items',
                Item: AWS.DynamoDB.Converter.marshall(realData)
              };
            const data = await db.putItem(params3).promise();
            return;
            
        }
        return;
    }
    catch (error) {
        console.log("Error , ",error);
    } 
    finally {
    }
};

const getIngreds = (res)=>{
    var results = []
    var checked = []
    var flag =true;
    if(res.Blocks){
        var con ="";
        res.Blocks.forEach(block => {
            
            if(block.BlockType=="WORD" & block.TextType=="PRINTED" & block.Confidence > 70){
                var word =block.Text.toLowerCase();
                var cleanWord = word.replace(/[^a-zA-Z ]/g, "");

                if(cleanWord=="ingredients"&flag){
                    con="";
                    word="";
                    results = []
                    checked = []
                    cleanWord="";
                    flag =false;
                }else if(cleanWord=="contains"){
                    con="";
                    word="";
                    cleanWord="";
                }
                if(con){
                    if(word.endsWith(",")| word.endsWith(".")| word.endsWith(")")|word.endsWith(":")|word.endsWith("}")|word.endsWith("]")){
                        results.push(con+"-"+cleanWord);
                        if(checkIngred(con+"-"+cleanWord)){
                            checked.push(con+"-"+cleanWord);
                        }
                        con=""
                    }
                    else if(word.startsWith("(")| word.startsWith("{")|word.startsWith("[")){
                        results.push(con);
                        if(checkIngred(con)){
                            checked.push(con);
                        }
                        con=cleanWord;
                    }
                    else{
                        con =con+"-"+cleanWord;
                    }
                }
                else{
                    if(word.endsWith(",")| word.endsWith(".")|word.endsWith(")")|word.endsWith(":")|word.endsWith("}")|word.endsWith("]")){
                        results.push(cleanWord);
                        if(checkIngred(cleanWord)){
                            checked.push(cleanWord);
                        }
                        con=""
                    }
                    else if(word.startsWith("(")| word.startsWith("{")|word.startsWith("[")){
                        con=cleanWord;
                    }
                    else{
                        con =cleanWord;
                    }
                }
            }
          }) 
        output={}
        output.results =results;
        output.checked = checked;
        return output;
    }
    else return []
}

const getMapping = (res)=>{
    output = 1;
    reason="";
    res.forEach(ingred => {
        Object.keys(ingredType).forEach(key=>{
            if(ingred.includes(key)){
                if(ingredCom[ingredType[key]] >output){
                    output = ingredCom[ingredType[key]];
                    reason = key;
                }
            }
        })
    })
    return [reverseIngredCom[output],reason];
}

const checkIngred = (res)=>{
    if(ingreds.includes(pluralize.singular(res))){
        return true;
    }
    return false;
}