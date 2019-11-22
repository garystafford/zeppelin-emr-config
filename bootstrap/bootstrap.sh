#!/bin/bash
set -ex

if [[ $# -ne 2 ]] ; then
    echo 'Missing required arguments'
    exit 1
fi

GITHUB_ACCOUNT=$1 # i.e. garystafford
GITHUB_REPO=$2 # i.e. zeppelin-emr-demo

# install extra python packages
sudo python3 -m pip install psycopg2-binary boto3

# install extra linux packages
yes | sudo yum install git htop

# clone github repo
cd /tmp
git clone "https://github.com/${GITHUB_ACCOUNT}/${GITHUB_REPO}.git"

# install extra jars
POSTGRES_JAR="postgresql-42.2.8.jar"
wget -nv "https://jdbc.postgresql.org/download/${POSTGRES_JAR}"
sudo chown -R hadoop:hadoop ${POSTGRES_JAR}
mkdir -p /home/hadoop/extrajars/
cp ${POSTGRES_JAR} /home/hadoop/extrajars/