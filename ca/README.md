Motivation
==========
The crypto material in this folder replaces the cryptogen generated msp
In a real world scenario, the msp under this structure will be placed in
the appropriate folders on the independent physical/virtual server
folders.

References are being made to the crypto in the subfolders from the 
orderer/multi-org
peer/pup/multi-org
peer/budget/multi-org

PS:
===
TLS being ignored for the time being.

Scripts
=======
ca/clean.sh             Cleans up the ./server & ./client folder
ca/setclient.sh         Sets the FABRIC_CA_CLIENT_HOME takes ORG and User. 
                        If args not provided current value shown
ca/add-admincerts.sh    Adds the admin's cert to msp/admincerts folder of the specified identity 


ca/server.sh                    (1) Initialize, Start/Stop CA Server, Enroll CA Server admin
                                    ./server.sh start
                                    ./server.sh enroll

ca/register-enroll-admins.sh    (2) Registers and enrolls the admins
                                    ./register-enroll-admins.sh

                                (2.1)  Set up org identity(s) + Add admin certs
                
ca/setup-org-msp.sh             (3) Setup the org msps









peer/launch-peer.sh  Launches the peer specified by ORG-Name & Peer_Name ... port number pending
peer/set-env.sh      Sets the environment vars for the provided ORG_Name & Peer
peer/show-env.sh     Shows the current environment

peer/config/generate-baseline.sh    Generates the baseline json configuration
peer/config/clean.sh                Deletes the json/pb/block files from the folder



Client MSP Folder
================

Roles & Identities
==================
1. admin            CA Server administrator
                    Created as a Bootstrap identity
                    ./server.sh enroll          Generates the MSP client/caserver/admin
                    The admin is then used to enroll other identities

2. orderer-admin    Orderer Org Administrator
                    Allowed to create the identities for Orderer Org
                    . ./setclient.sh caserver admin
                    fabric-ca-client register --id.type client --id.name orderer-admin --id.secret pw --id.affiliation orderer --id.attrs '"hf.Registrar.Roles=orderer"'
    
    * Set the CSR - its causing all identities to have a the default CSR - fix it :()

    2.1 Orderer admin now enrolls
    . ./setclient.sh orderer orderer-admin
    fabric-ca-client enroll -u http://orderer-admin:pw@localhost:7054

    2.2 Orderer admin registers the orderer identity
    . ./setclient.sh orderer orderer-admin
    fabric-ca-client register --id.type orderer --id.name orderer --id.secret pw --id.affiliation orderer 

    2.3 Orderer admin sets the FABRIC_CA_CLIENT_HOME and enrolls the orderer identity
    . ./setclient.sh orderer orderer
    fabric-ca-client enroll -u http://orderer:pw@localhost:7054


3. pup-admin       ACME Org Adminstrator
                    Allowed to create the identities of type peer, user & client for Pup Org
                    Allowed to manage affiliation

                    . ./setclient.sh caserver admin

                    fabric-ca-client register --id.type client --id.name pup-admin --id.secret pw --id.affiliation pup --id.attrs '"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true"'

    3.1 Pup admin now enrolls

    . setclient.sh pup pup-admin
    fabric-ca-client enroll -u http://pup-admin:pw@localhost:7054

    3.2 Pup admin registers user identity (jdoe) for Pup organization

        3.2.1   Create a user identity "John Doe"  Id=jdoe Secret=pw Affiliation=Pup Logistics Type=user

        . setclient.sh pup pup-admin
        fabric-ca-client register --id.type client --id.name jdoe --id.secret pw --id.affiliation pup.logistics 

        3.2.2   John Doe - enrolls as a user

        . setclient.sh pup jdoe
        fabric-ca-client enroll -u http://jdoe:pw@localhost:7054

    3.3 Pup admin registers user identity for a peer - peer1

        3.3.1  Create the peer identity "peer1" Id=peer1 Secret=pw Affiliation=Pup Type=peer
        . setclient.sh pup pup-admin
        fabric-ca-client register --id.type peer --id.name peer1 --id.secret pw --id.affiliation pup

        3.3.2  Pup admin enrolls the peer1
        . setclient.sh pup peer1
        fabric-ca-client enroll -u http://peer1:pw@localhost:7054

MSP Setup
=========
* Rename admin cert as part of the copy PENDING

ADMIN Certificate is Needed in all local MSP

1. Setup the MSP for the Orderer Organization/Member

    . setclient.sh pup pup-admin

    * Copy CA Cert
    mkdir -p ./client/orderer/msp/cacerts
    cp ./server/ca-cert.pem ./client/orderer/msp/cacerts

    * Copy Admin Cert
    mkdir -p ./client/orderer/msp/admincerts
    cp ./client/orderer/orderer-admin/msp/signcerts/*   ./client/orderer/msp/admincerts



2. Setup the MSP for Pup Organization

    . setclient.sh pup pup-admin

    * Copy CA Cert
    mkdir -p ./client/pup/msp/cacerts
    cp ./server/ca-cert.pem ./client/pup/msp/cacerts

    * Copy Admin Cert
    mkdir -p ./client/pup/msp/admincerts
    cp ./client/pup/pup-admin/msp/signcerts/*   ./client/pup/msp/admincerts

    * Copy the Admin cert to pup-admin folder also
    mkdir -p ./client/pup/pup-admin/msp/admincerts
    cp ./client/pup/pup-admin/msp/signcerts/*   ./client/pup/pup-admin/msp/admincerts

    * Copy the Admin cert to peer1 folder also
    mkdir -p ./client/pup/peer1/msp/admincerts
    cp ./client/pup/pup-admin/msp/signcerts/*   ./client/pup/peer1/msp/admincerts

    * Copy the Admin cert to jdoe folder also
    mkdir -p ./client/pup/jdoe/msp/admincerts
    cp ./client/pup/pup-admin/msp/signcerts/*   ./client/pup/jdoe/msp/admincerts

3. Setup the MSP for Orderer

    * Need to set the admin for the Orderer
    mkdir -p ./client/orderer/orderer/msp/admincerts
    FIX THIS - it should be Orderer Admin NOT pup-admin
    cp ./client/pup/pup-admin/msp/signcerts/*  ./client/orderer/orderer/msp/admincerts

Exercise-Create the MSP for Budget
==================================
The generated MSP will be used in the recipe for adding the Org/Budget

1. Update the affiliation 
   Add budget to it

   . ./setclient.sh caserver admin

   fabric-ca-client affiliation list
   fabric-ca-client affiliation add budget


2. budget-admin     Budget Org Adminstrator
                    Allowed to create the identities of type peer, user & client for Budget Org
                    Allowed to manage affiliation

                    . ./setclient.sh caserver admin

                    fabric-ca-client register --id.type client --id.name budget-admin --id.secret pw --id.affiliation budget --id.attrs '"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true"'


3. As budget-admin enroll
    . ./setclient.sh budget budget-admin
    fabric-ca-client enroll -u http://budget-admin:pw@localhost:7054
    This will generte the crypto under ca/multi-org-ca/client/budget

4. Add admin cert to budget-admin

5. Setup MSP for Budget
    4.1 Create folder msp under the budget org
    mkdir -p client/budget/msp/admincerts
    mkdir -p client/budget/msp/cacerts
    mkdir -p client/budget/msp/keystore

    4.2 Copy the CA Cert
    cp ./server/ca-cert.pem ./client/budget/msp/cacerts

    4.3 Copy the admin cert
    cp ./client/budget/budget-admin/msp/signcerts/*   ./client/budget/msp/admincerts

    4.4 setup admincerts in budget-admin/msp  [Otherwise gives an error]
    mkdir -p ./client/budget/budget-admin/msp/admincerts
    cp ./client/budget/budget-admin/msp/signcerts/*   ./client/budget/budget-admin/msp/admincerts/*   

Write a script that would setup the MSP for an org



Configtx.Yaml Setup
===================
* COPYING of policy.0 configtx PENDING

Copy the setup/config/ca/multi-org-ca/policy.0/configtx.yaml   orderer/multi-org-ca

Launch orderer

Shipping Channel Creation
========================
Pup Admin will take the role of (ShippingChannel) channel creator
Although the policy is MAJORITY admin it would 

* Copy the core.yaml file from policy.0 to peer/multi-org-ca/pup
Used by peer binary for admin commands only. It points to the admin MSP - so that admin can take appropriate actions


#PENDING

* Copy the orderer/multi-org-ca/shipping-channel.tx to peer/multi-org-ca/pup
cp ../../../orderer/multi-org-ca/shipping-channel.tx  .

peer channel create -o localhost:7050 -c shippingchannel -f ./shipping-channel.tx

Pup Peer1 Setup & Launch
=========================
./launch-peer.sh  pup peer1

./join-shipping-channel.sh pup peer1

Test setup
==========

. set-env.sh pup pup-admin

* Install the chain code as pup-admin 
peer chaincode install  -n gocc -v 1.0  -p chaincode_example02
peer chaincode list --installed

* Instantiate the chaincode as pup-admin
peer chaincode instantiate  -n gocc -v 1.0 -C shippingchannel -c '{"Args":["init","a","100","b","200"]}'

peer chaincode list --instantiated -C shippingchannel

* Execute the chaincode as pup-admin
   peer chaincode query -C shippingchannel -n gocc  -c '{"Args":["query","a"]}'
   peer chaincode invoke -C shippingchannel -n gocc  -c '{"Args":["invoke","a","b","10"]}'

* Execute the chaincode as user
 . set-env.sh pup jdoe
    - Query execute will go through but install/instantiate will fail as the type of identity is user 
    - Install will fail     peer chaincode install  -n gocc -v 1.0  -p chaincode_example02
    Refer to the policy => getinstalledchaincodes

Recipe: Add a peer to pup org
==============================
1. Pup Admin needs to set up the identity of peer2 &  MSP
    . setclient.sh pup pup-admin

    1.1 Register the identity "peer2" Id=peer2 Secret=pw Affiliation=Pup Type=peer
        
        fabric-ca-client register --id.type peer --id.name peer2 --id.secret pw --id.affiliation pup

    1.2 Pup admin enrolls the peer2
        . setclient.sh pup peer2
        fabric-ca-client enroll -u http://peer2:pw@localhost:7054

    1.3 Pup Admin sets up peer2's local MSP
        mkdir -p ./client/pup/peer2/msp/admincerts
        cp ./client/pup/pup-admin/msp/signcerts/*   ./client/pup/peer2/msp/admincerts

2. Setup the Peer peer2 for pup
   peer/multi-org-ca/peer

    2.1 Launch the peer
        ./launch-peer.sh pup peer2 8050

    2.2 Peer2 to join the channel
        . set-env.sh pup peer2 8050 admin
        ./join-shipping-channel.sh pup peer2

3. Test the Peer2

. set-env.sh pup pup-admin

* Install the chain code as pup-admin 

peer chaincode install  -n gocc -v 1.0  -p chaincode_example02
peer chaincode list --installed

* No need to instantiate as it is already done

* Execute the chaincode as pup-admin
   peer chaincode query -C shippingchannel -n gocc  -c '{"Args":["query","a"]}'
   peer chaincode invoke -C shippingchannel -n gocc  -c '{"Args":["invoke","a","b","10"]}'

Recipe: Add an anchor peer to Pup
==================================
This would require a Network level configuration change.

There are 2 sceanrios
1. Existing Peer added as an acnchor peer
2. New peer added as an anchor peer

multi-org-ca/peer
. set-env.sh pup pup-admin 7050
cd to config 

1. Fetch the latest configuration
peer channel fetch config config_block_original.pb -o localhost:7050 -c ordererchannel

2. Convert to JSON
configtxlator proto_decode --type=common.Block --input=config_block_original.pb > config_block_original.json

3. Extract the config branch
jq .data.data[0].payload.data.config config_block_original.json > config_original.json

4. Make a copy of the config_original.json
cp config_original.json config_updated.json

5. Add another "anchor" peer for pup in config_updated.json
                    {
                      "host": "localhost",
                      "port": 8051
                    }   
6. Encode the original & updated
configtxlator proto_encode --input config_original.json --output config_original.block --type common.Config
configtxlator proto_encode --input config_updated.json --output config_updated.block --type common.Config

7. Compute the delta 
configtxlator compute_update --channel_id ordererchannel  --original config_original.block --updated config_updated.block --output config_update_delta.block

8. Convert to JSON (optional step for dleta inspection)
configtxlator proto_decode --input config_update_delta.block --type common.ConfigUpdate --output=config_update_delta.json
Checkout the content of this JSON it just has the difference between orginal and updated

9. echo '{"payload":{"header":{"channel_header":{"channel_id":"'ordererchannel'", "type":2}},"data":{"config_update":'$(cat config_update_delta.json)'}}}' | jq . > config_update_in_envelope.json

10. Create the proto buf from the updated
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.block

Sign & Update
=============
Admin signs the config block
peer channel signconfigtx -f config_update_in_envelope.block

Since only one admin is needed to sign
peer channel update -f config_update_in_envelope.block -c ordererchannel -o localhost:7050

Recipe: Add an Org Budget to Network
====================================

ca/multi-org-ca

1. Generate the crypto material for Budget
ca/multi-org-ca

multi-org-ca/config

2. Setup configtxgen YAML with params for Budget
- get the configtxgen.yaml 
cp ../../../orderer/multi-org-ca/configtx.yaml .
FABRIC_CFG_PATH=$PWD/.. && configtxgen -channelID ordererchannel -printOrg Budget > budget.json
(Solution=setup/config/multi-org-ca/policy.1)



3. Extract config GENERATE THE BASELINE FOR CONFIG

peer/config/generate-baseline.sh ordererchannel

peer channel fetch config config_block_original.pb -o localhost:7050 -c ordererchannel
configtxlator proto_decode --type=common.Block --input=config_block_original.pb > config_block_original.json
jq .data.data[0].payload.data.config config_block_original.json > config_original.json

4. Add the budget org - create the config_updated.json
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Budget":.[1]}}}}}' config_original.json budget.json > config_updated.json

At this point two JSON files
config_original.json     Has Pup orgs
config_updated.json      Has Pup and Budget orgs

5. Create the delta

Convert original & updated to pb - this is needed for generating the delta

configtxlator proto_encode --input config_original.json --type common.Config --output config_original.pb
configtxlator proto_encode --input config_updated.json --type common.Config --output config_updated.pb

configtxlator compute_update --channel_id ordererchannel --original config_original.pb --updated config_updated.pb --output budget_update.pb



Script:
create-update-pb


6. Convert update & Wrap in the envelope

configtxlator proto_decode --input budget_update.pb --type common.ConfigUpdate | jq . > budget_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"ordererchannel", "type":2}},"data":{"config_update":'$(cat budget_update.json)'}}}' | jq . > budget_update_in_envelope.json

configtxlator proto_encode --input budget_update_in_envelope.json --type common.Envelope --output budget_update_in_envelope.pb

7. Sign and send update transaction
peer channel signconfigtx -f budget_update_in_envelope.pb
peer channel update -f budget_update_in_envelope.pb -c ordererchannel -o localhost:7050

8. Verify
./clean.sh
./generate-baseline.sh ordererchannel
Chec out the config_original.json - look for budget

Recipe - add the Budget to shipping channel
==========================================

Setup the budget peer1:
=======================
1. Budget admin creates the crypto for peer1
ca/multi-org-ca

- setup the peer identity
. ./setclient.sh budget budget-admin
fabric-ca-client register --id.type peer --id.name budget-peer1 --id.secret pw --id.affiliation budget

-  admin enrolls the peer1
    . setclient.sh budget peer1
    fabric-ca-client enroll -u http://budget-peer1:pw@localhost:7054

- set up MSP for the peer

    Create folder msp under the budget org
    mkdir -p client/budget/peer1/msp/admincerts

    Copy the admin cert
    cp ./client/budget/budget-admin/msp/signcerts/*   ./client/budget/peer1/msp/admincerts

2. Copy the core.yaml from setup/config/multi-org-ca/policy.0 to peer/multi-org-ca/budget
cp 

3. Launch and check logs
./launch-peer.sh budget peer1 9050

[Join, Chaincode install were successful *but* chaincode query failed with access denied]


Add the budget to shipping channel
=================================
Since only pup-admin has the access. The pup-admin will carry out the following task.

peer/multi-org-ca
. set-env.sh pup pup-admin 7050 pup-admin

 
cd config


1. 
FABRIC_CFG_PATH=$PWD/.. && configtxgen -channelID shippingchannel -printOrg Budget > budget.json

2.
./generate-baseline.sh

3. Setup the updated JSON

jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Budget":.[1]}}}}}' config_original.json budget.json > config_updated.json

4. Compute the delta
./create-update-pb.sh shippingchannel   
this outputs the file >> config_update_output.pb

5. 

./create-update-envelope-pb.sh shippingchannel

Generates the file : config_update_output_in_envelope.pb

6. 

peer channel signconfigtx -f config_update_output_in_envelope.pb
peer channel update -f config_update_output_in_envelope.pb -c shippingchannel -o localhost:7050

7. Validate
. set-env.sh 

   peer chaincode query -C shippingchannel -n gocc  -c '{"Args":["query","a"]}'
   peer chaincode invoke -C shippingchannel -n gocc  -c '{"Args":["invoke","a","b","10"]}'
   
Exercise - thought
==================
Create an identity that will act as the admin for pup.logistics apps????







