## ***if you have generated once and you need to regenerate, you need to rm local volumes***

## ***yuo can also get my manual [docker-compoase.yaml](manual/readme.md)***##
```bash
docker volumes ls
docker volumes rm {volumes id}
```

### Create a cluster

[https://hub.docker.com/r/bitnami/redis-cluster/](https://hub.docker.com/r/bitnami/redis-cluster/)

```bash
$ curl -sSL https://raw.githubusercontent.com/bitnami/bitnami-docker-redis-cluster/master/docker-compose.yml > docker-compose.yml
$ docker-compose up -d
```

### check cluster info

```bash
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli  -a bitnami cluster info
```

### check master-slave info

```bash
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli --cluster check redis-cluster_redis-node-3_1:6379 -a bitnami
```

### Docker container network

```bash
$ docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)
```

### Set & Get

```bash
// get 
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli -h redis-cluster_redis-node-3_1  -a bitnami -c get k2

// set
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli -h redis-cluster_redis-node-3_1  -a bitnami -c set k2 123
```

### extend node

1. create maste & slave node
2. add master to cluster
3. assign slots to new master
4. connect slave with master

```bash
//!! need to check redis type in the cluster
docker run -d --name redis-new-master01 --network redis-cluster_default --privileged=true  -p 8106:6379 redis:7.0 --cluster-enabled yes --appendonly yes  --requirepass "bitnami" --masterauth "bitnami"

docker run -d --name redis-new-slave01 --network redis-cluster_default --privileged=true  -p 8107:6379 redis:7.0 --cluster-enabled yes --appendonly yes  --requirepass "bitnami" --masterauth "bitnami"

// check redis-new-master01 network
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli --cluster add-node  redis-new-master01:6379 redis-cluster_redis-node-5_1:6379 -a bitnami

// assign slots
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli --cluster reshard redis-new-master01:6379 -a bitnami

// connect slave with master
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli --cluster add-node redis-new-slave01:6379 redis-cluster_redis-node-5_1:6379 --cluster-slave --cluster-master-id {master node id} -a bitnami
```

### balance slot

```bash
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli --cluster rebalance redis-cluster_redis-node-5_1:6379 -a bitnami
```

### reduce cluster node

1. delete slave node
2. be empty for master node
3. delete master node

```bash
//delete slave
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli --cluster del-node redis-new-slave01:6379 {slave node ID} -a bitnami

//move slots 
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli --cluster reshard redis-new-master01:6379 \
--cluster-from {master node ID} \
--cluster-to  {other node ID} \
--cluster-slots {total slots} \
--cluster-yes \
-a bitnami

//delete master
$ docker exec -it redis-cluster_redis-node-5_1 redis-cli --cluster del-node redis-new-slave01:6379 {delete master node id} -a bitnami
```

## Related

- [https://isdaniel.github.io/redis-cluster-introduce-01/](https://isdaniel.github.io/redis-cluster-introduce-01/)
- [https://segmentfault.com/a/1190000038771812](https://segmentfault.com/a/1190000038771812)
- [https://medium.com/fcamels-notes/redis-和-redis-cluster-概念筆記-fdc19a3117f3](https://medium.com/fcamels-notes/redis-%E5%92%8C-redis-cluster-%E6%A6%82%E5%BF%B5%E7%AD%86%E8%A8%98-fdc19a3117f3)
- [https://iter01.com/593235.html](https://iter01.com/593235.html)
- [https://blog.tienyulin.com/redis-master-slave-replication-sentinel-cluster/](https://blog.tienyulin.com/redis-master-slave-replication-sentinel-cluster/)
- [https://www.tpisoftware.com/tpu/articleDetails/2011](https://www.tpisoftware.com/tpu/articleDetails/2011)
- [https://blog.yowko.com/docker-compose-redis-cluster/](https://blog.yowko.com/docker-compose-redis-cluster/)
