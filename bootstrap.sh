#!/bin/bash

JAVA=`which java`
if [ "$?" != "0" ]; then 
    echo "No JAVA installation found. Export JAVA_HOME. Bailing out!"
    exit 1
fi

CONSUL_HOST=$CONSUL_HOST
CONSUL_PORT=$CONSUL_PORT
if [ -z "$CONSUL_HOST" ] || [ -z "$CONSUL_PORT" ]; then
    echo "ERROR - export CONSUL_HOST & CONSUL_PORT with your consul host, port settings."
    exit 1
fi

PATH=$PATH:`pwd`
CONSUL_TEMPLATE=`which consul-template`
if [ "$?" != "0" ]; then
    echo "consul-template not found. please make sure it is in PATH."
    echo "."
    read -p "Do you want to install consul-template? (y/n)[n]" -n 1 -r 
    echo ""
    echo "."
    
    OS=`uname -s`
    DIST=linux_amd64
    if [ "$OS" == "Darwin" ]; then 
        DIST=darwin_amd64
    fi

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        wget https://releases.hashicorp.com/consul-template/0.15.0/consul-template_0.15.0_${DIST}.zip
        if [ "$?" != "0" ]; then 
            echo "failure in downloading consul-template for ubuntu. bailing out!"
            exit 1
        fi

        unzip consul-template_0.15.0_${DIST}.zip
        if [ "$?" != "0" ]; then
            echo "failure in extracting consul-template-*.zip. Do you have unzip? bailing out!"
            exit 1
        fi
        echo "."
        export PATH=$PATH:`pwd`/consul-template
        echo "Added to PATH: $PATH"
    else
        echo "Ok. bailing out!"
        exit 1
    fi
fi

echo "."
echo "Setting up Elastic Search. (may take few minutes)"
echo "."
ESURL=https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.4/elasticsearch-2.3.4.tar.gz
ESTGZ=elasticsearch-2.3.4.tar.gz
ESDIR=elasticsearch-2.3.4
if [ ! -d "$ESDIR" ]; then
    if [ ! -f "$ESTGZ" ]; then
        wget $ESURL
    fi
    tar -xvzf $ESTGZ
fi

echo "."
echo "Copying searchui (elasticUI) into Elastic Search."
echo "."
cp -r searchui $ESDIR/plugins

echo "."
echo "Starting elasticsearch service."
echo "."
nohup $ESDIR/bin/elasticsearch >es.log 2>&1 & 
echo "."
echo "Sleep for 5s."
echo "."
sleep 5

INDEXFILE=`mktemp /tmp/consul-XXXXXXXX`
echo "."
echo "Querying consul and preparing index file: $INDEXFILE ."
echo "."
consul-template -consul $CONSUL_HOST:$CONSUL_PORT -template="prepare-blk-idx-data.ctmpl:$INDEXFILE"

INDEXNAME=`cat $INDEXFILE | grep index | awk -F\" '{print $6}' | head -1`

echo "."
echo "Deleting existing ES index."
echo "."
curl -XDELETE "http://localhost:9200/$INDEXNAME?pretty"

echo "."
echo "Indexing data into ES."
echo "."
curl -s -XPOST 'http://localhost:9200/_bulk?pretty' --data-binary "@$INDEXFILE"

echo "."
echo "Congratulations!! go look at: http://localhost:9200/_plugin/searchui/"
echo "."
