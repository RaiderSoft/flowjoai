const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();

let send = undefined;

function init(event) {
    const apigwManagementApi = new AWS.ApiGatewayManagementApi({
        apiVersion: '2018-11-29',    
        endpoint: event.requestContext.domainName + '/' + event.requestContext.stage  
    });        
    
    send = async (connectionId, data) => {
        await apigwManagementApi.postToConnection({
            ConnectionId: connectionId,
            Data: data,
    }).promise(); 
}}

exports.handler = (event, context, callback) => {  
    try{
        init(event);
        let message = JSON.parse(event.body).message    
        getConnections().then((data) => {
            data.Items.forEach(function(connection) {
                  send(connection.connectionId, message);
            });    
        });        
    
    var responseBody = {
        "statusCode": 200,
    };

    return {
        "statusCode": 200,
        "headers": {
        },
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


function getConnections(){
    return documentClient.scan({
        TableName: 'flowjoai-clients',
    }).promise();
}
