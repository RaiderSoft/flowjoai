const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();
AWS.config.region = 'us-east-2';
const crypto = require("crypto");

// Generate unique id with no external dependencies
const generateUUID = () => crypto.randomBytes(16).toString("hex");

exports.handler = async(event, context, callback) => {
    try {
        const response = JSON.parse(event);
        const body = response.body
        if (!body || body.uuid === undefined) {
            return {
                statusCode: 403,
                body: JSON.stringify('Request must contain body and body must contain a uuid'),
            };
        }

        let updateExpression = "set ";
        let expressionAttributeValues = {};

        if (body.completed !== undefined && body.completed.length > 0) {
            updateExpression += "completed =:co, ";
            expressionAttributeValues = { ...expressionAttributeValues, ":co": body.completed };
        }
        if (body.endpoint !== undefined && body.endpoint.length > 0) {
            updateExpression += "endpoint =:e, ";
            expressionAttributeValues = { ...expressionAttributeValues, ":e": body.endpoint };
        }
        if (body.modelName !== undefined && body.modelName.length > 0) {
            updateExpression += "modelName =:n, ";
            expressionAttributeValues = { ...expressionAttributeValues, ":n": body.modelName };
        }
        if (body.modelStatus !== undefined && body.modelStatus.length > 0) {
            updateExpression += "modelStatus =:s, ";
            expressionAttributeValues = { ...expressionAttributeValues, ":s": body.modelStatus };
        }
    

        if (updateExpression.length < 4) {
            return {
                statusCode: 403,
                body: JSON.stringify('Request body must include attributes to override'),
            };
        }
        updateExpression = updateExpression.substring(0, updateExpression.length - 2);

        const timestamp = new Date().valueOf();
        
        var params = {
            TableName: "flowjoai-models",
            Key: {
                "uuid": body.uuid,
                "created": body.created,
            },
            UpdateExpression: updateExpression,
            ExpressionAttributeValues: expressionAttributeValues,
            ReturnValues: "UPDATED_NEW"
        };

        const updateResponse = await documentClient.update(params).promise();

        return {
            statusCode: 200,
            body: "Database Updated"
        };
    }
    catch (e) {
        return {
            statusCode: 500,
            body: JSON.stringify(e)
        };
    }
};
