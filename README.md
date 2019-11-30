# Apache Zeppelin on Amazon EMR Demo

Configuration files for the accompanying post, [Getting Started with Apache Zeppelin on Amazon EMR, using AWS Glue, RDS, and S3](https://wp.me/p1RD28-6y6).

## Files

```text
.
├── LICENSE
├── README.md
├── bootstrap
│   ├── bootstrap.sh
│   └── helium.json
├── cloudformation
│   ├── crawler.yml
│   ├── emr_cluster.yml
│   ├── emr_single_node.yml
│   └── rds_postgres.yml
└── sql
    └── ratings.sql
```

## Architecture

![Demonstration Architecture](https://programmaticponderings.files.wordpress.com/2019/11/emr-zeppelin-6.png)

## Instructions

### Step 1

Create S3 EMR bucket.

```bash
# change me
ZEPPELIN_DEMO_BUCKET="your-bucket-name"

aws s3api create-bucket \
    --bucket ${ZEPPELIN_DEMO_BUCKET}
aws s3api put-public-access-block \
    --bucket ${ZEPPELIN_DEMO_BUCKET} \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

Copy EMR config files to S3.

```bash
aws s3 cp bootstrap/bootstrap.sh s3://${ZEPPELIN_DEMO_BUCKET}/bootstrap/
aws s3 cp bootstrap/helium.json s3://${ZEPPELIN_DEMO_BUCKET}/bootstrap/
aws s3 cp sql/ratings.sql s3://${ZEPPELIN_DEMO_BUCKET}/bootstrap/
```

### Step 2

Create EMR Roles.

```bash
aws emr create-default-roles
```

Create S3 EMR log bucket.

```bash
# change me
LOG_BUCKET="aws-logs-your_aws_account_id-your_region"

aws s3api create-bucket --bucket ${LOG_BUCKET}
aws s3api put-public-access-block --bucket ${LOG_BUCKET} \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

### Step 3

Create single-node Amazon EMR cluster.

```bash
# change me
ZEPPELIN_DEMO_BUCKET="your-bucket-name"
EC2_KEY_NAME="your-key-name"
LOG_BUCKET="aws-logs-your_aws_account_id-your_region"
GITHUB_ACCOUNT="your-account-name"
GITHUB_REPO="your-new-project-name"
GITHUB_TOKEN="your-token-value"
MASTER_INSTANCE_TYPE="m5.xlarge" # optional

aws cloudformation create-stack \
    --stack-name zeppelin-emr-dev-stack \
    --template-body file://cloudformation/emr_single_node.yml \
    --parameters ParameterKey=ZeppelinDemoBucket,ParameterValue=${ZEPPELIN_DEMO_BUCKET} \
                 ParameterKey=Ec2KeyName,ParameterValue=${EC2_KEY_NAME} \
                 ParameterKey=LogBucket,ParameterValue=${LOG_BUCKET} \
                 ParameterKey=MasterInstanceType,ParameterValue=${MASTER_INSTANCE_TYPE} \
                 ParameterKey=GitHubAccount,ParameterValue=${GITHUB_ACCOUNT} \
                 ParameterKey=GitHubRepository,ParameterValue=${GITHUB_REPO} \
                 ParameterKey=GitHubToken,ParameterValue=${GITHUB_TOKEN}
```

Create Amazon RDS PostgreSQL database.

```bash
# change me
DB_MASTER_USER="your-db-username"
DB_MASTER_PASSWORD="your-db-password"
MASTER_INSTANCE_TYPE="db.m4.large" # optional

aws cloudformation create-stack \
    --stack-name zeppelin-rds-stack \
    --template-body file://cloudformation/rds_postgres.yml \
    --parameters ParameterKey=DBUser,ParameterValue=${DB_MASTER_USER} \
                 ParameterKey=DBPassword,ParameterValue=${DB_MASTER_PASSWORD} \
                 ParameterKey=DBInstanceClass,ParameterValue=${MASTER_INSTANCE_TYPE}
```

Create AWS Glue Data Catalog database and Crawlers.

```bash
# change me
ZEPPELIN_DEMO_BUCKET="your-bucket-name"

aws cloudformation create-stack \
    --stack-name zeppelin-crawlers-stack \
    --template-body file://cloudformation/crawler.yml \
    --parameters ParameterKey=ZeppelinDemoBucket,ParameterValue=${ZEPPELIN_DEMO_BUCKET} \
    --capabilities CAPABILITY_NAMED_IAM
```

### Step 4

Configure EMR on Master node.

```bash
cd /tmp/zeppelin-emr-demo/
sudo chown -R zeppelin:zeppelin .

# change me
ZEPPELIN_DEMO_BUCKET="your-bucket-name"

sudo aws s3 cp s3://${ZEPPELIN_DEMO_BUCKET}/bootstrap/helium.json \
    /usr/lib/zeppelin/conf/helium.json
sudo chown zeppelin:zeppelin /usr/lib/zeppelin/conf/helium.json

sudo sh /usr/lib/zeppelin/bin/install-interpreter.sh --all

sudo sh /usr/lib/zeppelin/bin/install-interpreter.sh \
    --name "postgres" \
    --artifact org.apache.zeppelin:zeppelin-jdbc:0.8.0

sudo stop zeppelin && sudo start zeppelin
```

### Step 5

Create multi-node EMR cluster.

```bash
# change me
ZEPPELIN_DEMO_BUCKET="your-bucket-name"
EC2_KEY_NAME="your-key-name"
LOG_BUCKET="aws-logs-your_aws_account_id-your_region"
GITHUB_ACCOUNT="your-account-name"
GITHUB_REPO="your-new-project-name"
GITHUB_TOKEN="your-token-value"
MASTER_INSTANCE_TYPE="m5.xlarge" # optional
CORE_INSTANCE_TYPE="m5.2xlarge" # optional
CORE_INSTANCE_COUNT=3 # optional

aws cloudformation create-stack \
    --stack-name zeppelin-emr-prod-stack \
    --template-body file://cloudformation/emr_cluster.yml \
    --parameters ParameterKey=ZeppelinDemoBucket,ParameterValue=${ZEPPELIN_DEMO_BUCKET} \
                 ParameterKey=Ec2KeyName,ParameterValue=${EC2_KEY_NAME} \
                 ParameterKey=LogBucket,ParameterValue=${LOG_BUCKET} \
                 ParameterKey=MasterInstanceType,ParameterValue=${MASTER_INSTANCE_TYPE} \
                 ParameterKey=CoreInstanceType,ParameterValue=${CORE_INSTANCE_TYPE} \
                 ParameterKey=CoreInstanceCount,ParameterValue=${CORE_INSTANCE_COUNT} \
                 ParameterKey=GitHubAccount,ParameterValue=${GITHUB_ACCOUNT} \
                 ParameterKey=GitHubRepository,ParameterValue=${GITHUB_REPO} \
                 ParameterKey=GitHubToken,ParameterValue=${GITHUB_TOKEN}
```

### Step 6

Delete multi-node EMR cluster.

```bash
aws cloudformation delete-stack --stack-name zeppelin-emr-prod-stack
```

Run Glue Crawlers.

```bash
aws glue start-crawler --name bakery-transactions-crawler
aws glue start-crawler --name movie-ratings-crawler
```
