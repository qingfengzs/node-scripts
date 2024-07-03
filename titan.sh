cd ~ && docker pull nezha123/titan-edge && mkdir ~/.titanedge && \
 docker run --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge &&  sleep 10 && \
 sed -i 's/#ListenAddress = "0.0.0.0:1234"/ListenAddress = "0.0.0.0:31234"/' ~/.titanedge/config.toml && \
 sed -i 's/#StorageGB = 2/StorageGB = 100/' ~/.titanedge/config.toml && \
 docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash=xxxx https://api-test1.container1.titannet.io/api/v2/device/binding


docker run --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge && sleep 10  && \
docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash=xxxx https://api-test1.container1.titannet.io/api/v2/device/binding


 titan-edge bind --hash=xxxx https://api-test1.container1.titannet.io/api/v2/device/binding



