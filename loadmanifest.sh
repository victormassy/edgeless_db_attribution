./genkeys.sh
cp input1 writer
cd owner
era -c ../edgelessdb-sgx.json -h localhost:8080 -output-root edb.pem
curl --cacert edb.pem --data-binary @../manifest.json https://localhost:8080/manifest
cd ../writer
era -c ../edgelessdb-sgx.json -h localhost:8080 -output-root edb.pem
curl --cacert edb.pem https://localhost:8080/signature
sha256sum ../manifest.json
mysql -h127.0.0.1 -uwriter --ssl-ca edb.pem --ssl-cert cert.pem --ssl-key key.pem

source input1 ;
quit;

cd reader
era -c ../edgelessdb-sgx.json -h localhost:8080 -output-root edb.pem
mysql -h127.0.0.1 -ureader --ssl-ca edb.pem --ssl-cert cert.pem --ssl-key key.pem

call attribution.output(77);


