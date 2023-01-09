cd writer/

era -c ../edgelessdb-sgx.json -h localhost:8080 -output-root edb.pem
curl --cacert edb.pem https://localhost:8080/signature
sha256sum ../manifest.json
mysql -h127.0.0.1 -uwriter --ssl-ca edb.pem --ssl-cert cert.pem --ssl-key key.pem

