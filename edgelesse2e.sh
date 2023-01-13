sudo docker stop my-edb
sudo docker rm my-edb 
sudo docker run -t \
	  --name my-edb \
	    -p3306:3306 \
	      -p8080:8080 \
	        --device /dev/sgx_enclave --device /dev/sgx_provision \
		  ghcr.io/edgelesssys/edgelessdb-sgx-1gb &

sleep 10
rm -rf owner/ writer/ reader/
./genkeys.sh

cd owner
era -c ../edgelessdb-sgx.json -h localhost:8080 -output-root edb.pem
curl --cacert edb.pem --data-binary @../manifest.json https://localhost:8080/manifest


cd ../writer
era -c ../edgelessdb-sgx.json -h localhost:8080 -output-root edb.pem
curl --cacert edb.pem https://localhost:8080/signature

sleep 10 


sha256sum ../manifest.json
mysql -h127.0.0.1 -uwriter --ssl-ca edb.pem --ssl-cert cert.pem --ssl-key key.pem < ../input1

cd ../reader
era -c ../edgelessdb-sgx.json -h localhost:8080 -output-root edb.pem
mysql -h127.0.0.1 -ureader --ssl-ca edb.pem --ssl-cert cert.pem --ssl-key key.pem < ../output >> ../results.txt
