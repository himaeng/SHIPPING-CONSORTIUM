# Generates the orderer | generate genesis block for ordererchannel
export ORDERER_GENERAL_LOGLEVEL=debug
export FABRIC_CFG_PATH=`pwd`

# Create the Genesis Block
echo    '================ Writing Genesis Block ================'
configtxgen -profile ShippingOrdererGenesis -outputBlock ./shipping-genesis.block -channelID ordererchannel
