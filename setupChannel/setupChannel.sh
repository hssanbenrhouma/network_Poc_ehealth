#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build your first network (BYFN) end-to-end test"
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/medical.com/orderers/orderer.medical.com/msp/tlscacerts/tlsca.medical.com-cert.pem

#CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"
#if [ "$LANGUAGE" = "node" ]; then
#	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/node/"
#fi

echo "Channel name : "$CHANNEL_NAME

# import utils
. setupChannel/utils.sh

createChannel() {
	setGlobals 0 1

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.medical.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/medicalchannel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.medical.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/medicalchannel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel \"$CHANNEL_NAME\" is created successfully ===================== "
	echo
}

joinChannel () {
	for org in 1 2 3 4; do
	    for peer in 0 1; do
		joinChannelWithRetry $peer $org
		echo "===================== peer${peer}.org${org} joined on the channel \"$CHANNEL_NAME\" ===================== "
		sleep $DELAY
		echo
	    done
	done
}

## Create channel
echo "Creating channel..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for providerorg..."
updateAnchorPeers 0 1
echo "Updating anchor peers for pharmacyorg..."
updateAnchorPeers 0 2

echo "Updating anchor peers for hospitalorg..."
updateAnchorPeers 0 3
echo "Updating anchor peers for regulatororg..."
updateAnchorPeers 0 4

