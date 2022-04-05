const AWS = require("aws-sdk");
const config = require("./config");

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

        var mapping = getMapping(ingreds);

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
            realData.Ingreds = ingreds;

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
    if(res.Blocks){
        var con ="";
        res.Blocks.forEach(block => {
            
            if(block.BlockType=="WORD" & block.TextType=="PRINTED" & block.Confidence > 70){
                var word =block.Text.toUpperCase();
                var cleanWord = word.replace(/[^a-zA-Z ]/g, "");
                if(con){
                    if(word.endsWith(",")| word.endsWith(".")| word.endsWith(")")|word.endsWith(":")|word.endsWith("}")|word.endsWith("]")){
                        results.push(con+" "+cleanWord);
                        con=""
                    }
                    else if(word.startsWith("(")| word.startsWith("{")|word.startsWith("[")){
                        results.push(con);
                        con=cleanWord;
                    }
                    else{
                        con =con+" "+cleanWord;
                    }
                }
                else{
                    if(word.endsWith(",")| word.endsWith(".")|word.endsWith(")")|word.endsWith(":")|word.endsWith("}")|word.endsWith("]")){
                        results.push(cleanWord);
                        con=""
                    }
                    else if(word.startsWith("(")| word.startsWith("{")|word.startsWith("[")){
                        con=cleanWord;
                    }
                    else{
                        con =con+" "+cleanWord;
                    }
                }
            }
          }) 
        return results;
    }
    else return []
}

const getMapping = (res)=>{
    return null;
}