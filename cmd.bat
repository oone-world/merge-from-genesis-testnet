
cd local/_pos

rd /s /q _execution
rd /s /q _execution2
rd /s /q _beacon
rd /s /q _beacon2
rd /s /q _validator

## GENESIS STATE ##
.\eth2-testnet-genesis.exe merge ^
--config "beacon-config.yaml" ^
--eth1-config "execution-genesis.json" ^
--mnemonics "beacon-mnemonics.yaml" ^
--state-output "beacon-genesis.ssz"

## GETH ##
geth --datadir _execution init execution-genesis.json
geth --datadir _execution2 init execution-genesis.json
geth --datadir _execution account import execution-sk.json

geth ^
--networkid=39677693 ^
--http ^
--http.api=eth,net,web3,personal,miner,engine,admin ^
--http.addr=127.0.0.1 ^
--authrpc.vhosts=* ^
--authrpc.jwtsecret rpc-jwt.hex ^
--datadir _execution ^
--allow-insecure-unlock ^
--unlock 0x123463a4b065722e99115d6c222f267d9cabb524 ^
--password execution-pw.txt ^
--syncmode full ^
console

geth ^
--networkid 39677693 ^
--datadir _execution2 ^
--authrpc.port 8651 ^
--authrpc.jwtsecret rpc-jwt.hex ^
--port 31303 ^
--ipcdisable
--bootnodes "enode://99a16a0106b1d447fd35b882ba402c702e1ed6e784f23a56ed885313a9add8ba86525435130ff880664bf072da47634f97d97de35a7eaafd93ff91f203c33280@127.0.0.1:30303" ^

## BEACON ##
.\prysm\prysm.bat beacon-chain ^
--execution-endpoint=http://127.0.0.1:8551 ^
--jwt-secret=rpc-jwt.hex ^
--datadir=_beacon ^
--chain-id=39677693 ^
--chain-config-file=beacon-config.yaml ^
--contract-deployment-block 0 ^
--deposit-contract 0x0420420420420420420420420420420420420420 ^
--genesis-state=beacon-genesis.ssz ^
--min-sync-peers=0 ^
--suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 ^
--verbosity debug ^
--accept-terms-of-use

## BEACON NODE 2 ##
curl http://localhost:8080/p2p

.\prysm\prysm.bat beacon-chain ^
--execution-endpoint=http://127.0.0.1:8651 ^
--jwt-secret=rpc-jwt.hex ^
--datadir=_beacon2 ^
--chain-id=39677693 ^
--chain-config-file=beacon-config.yaml ^
--contract-deployment-block 0 ^
--deposit-contract 0x0420420420420420420420420420420420420420 ^
--genesis-state=beacon-genesis.ssz ^
--min-sync-peers=0 ^
--suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 ^
--peer=/ip4/192.168.1.5/tcp/13000/p2p/16Uiu2HAkz33cgj7kbQ7QBdnbriJWLkZPMAXbNkS1ho9khWUG1XQy ^
--rpc-port=4001 ^
--p2p-tcp-port=13001 ^
--p2p-udp-port=12001 ^
--grpc-gateway-port=3501 ^
--monitoring-port=8001 ^
--verbosity trace ^
--accept-terms-of-use

## VALIDATOR ##
.\prysm\prysm.bat validator accounts import ^
--keys-dir=validator-keys ^
--wallet-dir=_validator/wallet ^
--wallet-password-file=validator-password.txt ^
--mainnet

.\prysm\prysm.bat validator ^
--datadir=_validator ^
--wallet-dir=_validator/wallet ^
--wallet-password-file=validator-password.txt ^
--chain-config-file=beacon-config.yaml ^
--suggested-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 ^
--verbosity info ^
--accept-terms-of-use

## DEBUGGING ##
curl localhost:3500/eth/v1/node/syncing
curl http://localhost:8080/healthz
curl http://localhost:3500/eth/v1alpha1/node/eth1/connections