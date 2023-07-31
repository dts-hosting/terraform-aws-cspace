/**
  * AWS Lambda function for redeploy of service environment
  *
  * @param event    AWS event object containing event data
  * @param context  Execution context of the function
  * @param callback Optional callback to return information to the caller
  */

exports.handler = function(event, context, callback) {
    "use strict";
    var AWS = require('aws-sdk');
  
    var body          = { "message": "ok" };
    var statusCode    = '200';
  
    var ecs = new AWS.ECS({apiVersion: '2014-11-13'});
  
    var params = {
     cluster: process.env.CLUSTER,
     forceNewDeployment: true,
     service: process.env.SERVICE
    };
  
    ecs.updateService(params, function(err, data) {
      console.log('Updating ECS service');
      if (err) {
        body       = [err, err.stack];
        statusCode = '500';
      }
      else {
        body = data;
      }
    });
  
    callback(null, {
      statusCode: statusCode,
      body: JSON.stringify(body),
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
