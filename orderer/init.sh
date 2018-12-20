# Generates the orderer | generate genesis block for ordererchannel

BASE_CONFIG_DIR=../setup/

export ORDERER_GENERAL_LOGLEVEL=debug

# Create the Genesis Block
echo    '================ Writing Genesis Block ================'
configtxgen -profile ShippingOrdererGenesis -outputBlock ./shipping-genesis.block -channelID ordererchannel

#3. Create the shipping channel transaction
echo    '================ Writing shippingchannel ================'
configtxgen -profile ShippingChannel -outputCreateChannelTx ./shipping-channel.tx -channelID shippingchannel

echo    '======= Done. Launch by executing orderer ======'
