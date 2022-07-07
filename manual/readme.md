## Description
This is practiced by my composing docker-compose yaml 

There are six container for redis cluster (maybe you wanna more..) and there is a container as redis-cluster creator 

There are two shell for adding and deleting nodes

## Command

***You need to create redis-cluster by docker-compose.yaml before you run these shells***
### add the 
```shell
redis-cluster/manual $ sh add-node.sh 
```

### delete node
```shell
redis-cluster/manual $ sh delete-node.sh
```
