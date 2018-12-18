# Generates the orderer | generate the shipping channel transaction

export ORDERER_GENERAL_LOGLEVEL=debug

function usage {
    echo "./generate-channel-tx.sh "
    echo "     Creates the shipping-channel.tx for the channel shippingchannel"
}

echo    '================ Writing shippingchannel ================'

configtxgen -profile ShippingChannel -outputCreateChannelTx ./shipping-channel.tx -channelID shippingchannel

echo    '======= Done. Launch by executing orderer ======'
