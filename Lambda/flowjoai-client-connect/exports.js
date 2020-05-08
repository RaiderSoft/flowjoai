const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();
const crypto = require("crypto");

const generateUUID = () => crypto.randomBytes(16).toString("hex");

exports.handler = async(event, context, callback) => {
    try {
        const connectionId = event.requestContext ? event.requestContext.connectionId : generateUUID();
        const timestamp = new Date().valueOf();
        const data = await documentClient.put({
            TableName: 'flowjoai-clients',
            Item: {
                connectionId: connectionId,
                connected: timestamp,
            }
        }).promise();

        var responseBody = {
            "statusCode": 200,
            "connectionId": connectionId,
            "connected": timestamp,
        };

        var response = {
            "statusCode": 200,
            "headers": {},
            "body": JSON.stringify(responseBody),
            "isBase64Encoded": false
        };

        return response;
    }
    catch (e) {
        return {
            statusCode: 500,
            body: JSON.stringify(e)
        };
    }
}
