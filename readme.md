### Description

the file downloaded from docker hub, it is example

manual folder is made by jonny


### Create a cluster

[https://hub.docker.com/r/bitnami/redis-cluster/](https://hub.docker.com/r/bitnami/redis-cluster/)

```json
$ curl -sSL https://raw.githubusercontent.com/bitnami/bitnami-docker-redis-cluster/master/docker-compose.yml > docker-compose.yml
$ docker-compose up -d
```

### check cluster info

```json 

$ docker exec -it rediscluster_redis-node-0_1 bash
/$ redis-cli -a bitnami

127.0.0.1:6379> CLUSTER INFO
```

### check master-slave info

```json
/$ redis-cli --cluster check 127.0.0.1:6379 -a bitnami
```

### Docker container network

```json
$ docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)
```

### Set & Get

```json
redis-cli -h 172.22.0.2 -a bitnami -c
get K1
set K1 123
```

### extend node

1. create maste & slave node
2. add master to cluster
3. assign slots to new master
4. connect slave with master

```json
//!! need to check redis type in the cluster
docker run -d --name {name} --network {network} --privileged=true  -p 8106:6379 redis:{type} --cluster-enabled yes --appendonly yes  --requirepass "bitnami" --masterauth "bitnami"

docker run -d --name redis-new-master01 --network redis-cluster_default --privileged=true  -p 8106:6379 redis:7.0 --cluster-enabled yes --appendonly yes  --requirepass "bitnami" --masterauth "bitnami"

docker run -d --name redis-new-slave01 --network redis-cluster_default --privileged=true  -p 8107:6379 redis:7.0 --cluster-enabled yes --appendonly yes  --requirepass "bitnami" --masterauth "bitnami"

// check redis-new-master01 network
redis-cli --cluster add-node  172.19.0.8:6379 172.19.0.2:6379 -a bitnami

// assign slots
redis-cli --cluster reshard 172.19.0.8:6379 -a bitnami

// connect slave with master
redis-cli --cluster add-node {new-slave-redis IP} {cluster-redis IP}  --cluster-slave --cluster-master-id 新節點master-id -a bitnami
```

### balance slot

```json
redis-cli --cluster rebalance 172.19.0.8:6379 -a bitnami
```

### reduce cluster node

1. delete slave node
2. be empty for master node
3. delete master node

```json
//delete slave
redis-cli --cluster del-node {node Redis IP} {node Redis ID} -a bitnami

//move slots 
redis-cli --cluster reshard 172.19.0.8:6379 \
--cluster-from {node ID} \
--cluster-to  {node ID} \
--cluster-slots {total slots} \
--cluster-yes \
-a bitnami

//delete master
redis-cli --cluster del-node 172.19.0.2:6379 2160750c35f1023879828c17c7d146f5933c3319 -a bitnami
```

## Related

- [https://isdaniel.github.io/redis-cluster-introduce-01/](https://isdaniel.github.io/redis-cluster-introduce-01/)
- [https://segmentfault.com/a/1190000038771812](https://segmentfault.com/a/1190000038771812)
- [https://medium.com/fcamels-notes/redis-和-redis-cluster-概念筆記-fdc19a3117f3](https://medium.com/fcamels-notes/redis-%E5%92%8C-redis-cluster-%E6%A6%82%E5%BF%B5%E7%AD%86%E8%A8%98-fdc19a3117f3)
- [https://iter01.com/593235.html](https://iter01.com/593235.html)
- [https://blog.tienyulin.com/redis-master-slave-replication-sentinel-cluster/](https://blog.tienyulin.com/redis-master-slave-replication-sentinel-cluster/)
- [https://www.tpisoftware.com/tpu/articleDetails/2011](https://www.tpisoftware.com/tpu/articleDetails/2011)
- [https://blog.yowko.com/docker-compose-redis-cluster/](https://blog.yowko.com/docker-compose-redis-cluster/)
