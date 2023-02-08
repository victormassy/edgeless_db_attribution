# EdgelessDB Attribution reporting

This repo contains a prototype for privacy preserving attribution reporting in a secure enclave. 

For more information check the paper: TODO 

# Quickstart

Before going into the details of this repo, I suggest that you check [edgelessDB demo](https://github.com/edgelesssys/edgelessdb/tree/main/demo)
In this repo we use the same architecture than demo. 

Input files are located in another repo.  
 ```
 git clone https://github.com/victormassy/input.git
 ```
 
Unzip input:
 
```
cd input
unzip TODO
```

Copy one input file as source:
```
cd ..
cp input/TODO input1
```


# Run a single test

```
sudo docker run -t \
          --name my-edb \
            -p3306:3306 \
              -p8080:8080 \
                --device /dev/sgx_enclave --device /dev/sgx_provision \
                  ghcr.io/edgelesssys/edgelessdb-sgx-1gb &

```
Open a new termninal: 
```
./genkeys.sh

cd owner
era -c ../edgelessdb-sgx.json -h localhost:8080 -output-root edb.pem
curl --cacert edb.pem --data-binary @../manifest.json https://localhost:8080/manifest


cd ../writer
era -c ../edgelessdb-sgx.json -h localhost:8080 -output-root edb.pem
curl --cacert edb.pem https://localhost:8080/signature
```
Write data in the database: 

```
sha256sum ../manifest.json
mysql -h127.0.0.1 -uwriter --ssl-ca edb.pem --ssl-cert cert.pem --ssl-key key.pem 
```
From mysql:

```
source input1;
quit; 
```

Compute and read output:
```
cd ../reader
era -c ../edgelessdb-sgx.json -h localhost:8080 -output-root edb.pem
mysql -h127.0.0.1 -ureader --ssl-ca edb.pem --ssl-cert cert.pem --ssl-key key.pem < ../output >> ../results.txt
 ```
 From mysql:
 ```
 call attribution(100);
 select * from attribution.output;
 ```
 
 
# Run multiple tests
Some scripts can be used to run multiple tests. For these scipts to work, you need to follow these steps: 
 - Run tests:
``` 
chmod +x 100tests.sh 
./100tests.sh 
```

Execution times are stored in file results.txt in microseconds (ms). 

# Description of the database

In the manifest file, I define 2 tables, 3 types of users, their permissions and some stored procedure. 

writers can only write data into the database.

readers can execute the output_opt() stored procedure and read the table aggregated. 

fakeUser can acces data in the clear but can never be instantiated from outside the enclave. 

The only stored procedure that can be executed from outside the enclave is output_opt(). It computes the attribution reporting process and store the result in the table aggregated.

The manifest file also initiate the database. 






