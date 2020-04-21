const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();
const crypto = require("crypto");

// Generate unique id with no external dependencies
const generateUUID = () => crypto.randomBytes(16).toString("hex");

exports.handler = async (event, context, callback) => {  
    const connectionId = event.requestContext ? event.requestContext.connectionId : generateUUID(); 
    const timestamp = new Date().valueOf();
    
    try {
    const data = await documentClient.delete({        
        TableName: 'flowjoai-clients',
        Key: {          
            connectionId: connectionId,
        }    
    }).promise();
    
     var responseBody = {
        "statusCode": 200,
        "connectionId": connectionId,
        "disconnected": timestamp,
    };

    return {
        "statusCode": 200,
        "headers": {},
        "body": JSON.stringify(responseBody),
        "isBase64Encoded": false
    };

  } catch (e) {
    return {
      statusCode: 500,
      body: JSON.stringify(e)
    };
  }
}
