const AWS = require('aws-sdk');
const sagemaker = new AWS.SageMaker();

exports.handler = async(event, context) => {
        const { uuid } = JSON.parse(event).body
        const arnList = context.invokedFunctionArn.split(':')
        const accountId = arnList[4];
        const region = arnList[3];
        
        const createModelParams = {
            ModelName: uuid,
            Containers: [{
                Image: `${accountId}.dkr.ecr.${region}.amazonaws.com/flowjoai-pytorch-inference-v1:latest`,
                Mode: 'SingleModel',
                ModelDataUrl: `s3://flowjoai-bucket/outputs/v1/${uuid}/output/model.tar.gz`
            }],
            ExecutionRoleArn: `arn:aws:iam::${accountId}:role/dynamo-lambda-crud`,
            VpcConfig: {
                SecurityGroupIds: ['sg-3e473e53'],
                Subnets: ['subnet-e22ce8ae', 'subnet-92fc60e8', 'subnet-2365434b']
            },
            EnableNetworkIsolation: true
        }
        
        const response = await sagemaker.createModel(createModelParams).promise();

        return {
            statusCode: 200,
            body: JSON.stringify(response),
        };
};
