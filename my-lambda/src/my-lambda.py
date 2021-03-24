import pandas as pd
import boto3
import os
import io

output_bucket = os.environ["OUTPUT_BUCKET"]
deployment_target = os.environ["DEPLOYMENT_TARGET"]


def s3_resource():
    if deployment_target == "aws_local":
        s3 = boto3.resource(
            "s3",
            endpoint_url="https://localstack:4566",
            aws_access_key_id="test",
            aws_secret_access_key="test",
            verify=False,
        )
    else:
        s3 = boto3.resource()
    return s3


def get_input_details(event):
    input_bucket = event["Records"][0]["s3"]["bucket"]["name"]
    input_csv = event["Records"][0]["s3"]["object"]["key"]
    return input_bucket, input_csv


def load_input_csv_to_dataframe(input_bucket, input_csv, s3=s3_resource()):
    obj = s3.Object(input_bucket, input_csv)
    body = obj.get()["Body"]
    df = pd.read_csv(body)
    return df


def lambda_handler(event, context):

    input_bucket, input_csv = get_input_details(event)

    csv_df = load_input_csv_to_dataframe(input_bucket, input_csv)

    csv_df = csv_df.transpose()

    dump_csv = io.StringIO()

    csv_df.to_csv(dump_csv, header=False)

    s3_resource().Object(
        output_bucket, f"{input_csv.split('.')[0]}_transposed.csv"
    ).put(Body=dump_csv.getvalue())

    return {"statusCode": 200}
