export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp
export CORE_PEER_ADDRESS=peer0.providerorg.medical.com:7051
export CORE_PEER_LOCALMSPID="ProviderOrgMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt

export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp
export CORE_PEER_ADDRESS=peer0.pharmacyorg.medical.com:7051
export CORE_PEER_LOCALMSPID="PharmacyOrgMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt


peer chaincode install -n evmcc -l golang -v 0 -p github.com/hyperledger/fabric-chaincode-evm/evmcc

peer chaincode instantiate -n evmcc -v 0 -C medicalchannel -c '{"Args":[]}' -o orderer.medical.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/medical.com/orderers/orderer.medical.com/msp/tlscacerts/tlsca.medical.com-cert.pem




openssl x509 -in /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/medical.com/orderers/orderer.medical.com/msp/tlscacerts/tlsca.medical.com-cert.pem -text


export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/medical.com/orderers/orderer.medical.com/msp/tlscacerts/tlsca.medical.com-cert.pem

peer channel create -o orderer.medical.com:7050 -c medicalchannel -f ./channel-artifacts/medicalchannel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA 

export GOPATH=$HOME/go

export FABPROXY_CONFIG=${GOPATH}/src/github.com/hyperledger/fabric-chaincode-evm/examples/network-sdk-config.yaml # Path to a compatible Fabric SDK Go config file
export FABPROXY_USER=User1 # User identity being used for the proxy (Matches the users names in the crypto-config directory specified in the config)
export FABPROXY_ORG=ProviderOrg  # Organization of the specified user
export FABPROXY_CHANNEL=medicalchannel # Channel to be used for the transactions
export FABPROXY_CCID=evmcc # ID of the EVM Chaincode deployed in your fabric network
export PORT=5000 # Port the proxy will listen on. If not provided default is 5000.