#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { CdkStack } from '../lib/cdk-stack';

const app = new cdk.App();
new CdkStack(app, 'rearc-quest-stack', {
    env: {
        account: process.env.AWS_ACCOUNT_ID,
        region: process.env.AWS_DEFAULT_REGION ?? 'us-east-1',
    }
});