
# get requirepass from redis-cluster
requirepass=$(cat redis-cluster.conf | grep requirepass | cut -d' ' -f2)

# get slave node id
deleteSlaveNode=$(docker exec -t manual_redis-node1_1 redis-cli -h redis-new-slave01 -p 6379 -a $requirepass cluster nodes | grep myself | cut -d' ' -f1)

# delete slave node
docker exec -t manual_redis-node1_1 redis-cli --cluster del-node redis-new-slave01:6379 $deleteSlaveNode -a $requirepass

# get master node id
masterNode=$(docker exec -t manual_redis-node1_1 redis-cli -h redis-new-master01 -p 6379 -a $requirepass cluster nodes | grep -v myself | grep master | head -1 | cut -d' ' -f1)

# get delete master node id
deleteMasterNode=$(docker exec -t manual_redis-node1_1 redis-cli -h redis-new-master01 -p 6379 -a $requirepass cluster nodes | grep myself | head -1 | cut -d' ' -f1)

# get delete master node slot
deleteMasterNodeSlot=$(docker exec -t manual_redis-node1_1 redis-cli --cluster info redis-new-master01:6379 -a $requirepass | grep redis-new-master01 | cut -d'|' -f2 | sed 's/slots//g')

# reshard deleteNode to other node
docker exec -it manual_redis-node1_1 redis-cli --cluster reshard redis-new-master01:6379 --cluster-from $deleteMasterNode --cluster-to $masterNode --cluster-slots $deleteMasterNodeSlot --cluster-yes  -a $requirepass


# delete master node
docker exec -t manual_redis-node1_1 redis-cli --cluster del-node redis-new-master01:6379 $deleteMasterNode -a $requirepass

# balance
#docker exec -it manual_redis-node1_1 redis-cli --cluster rebalance manual_redis-node1_1:6379 -a $requirepass

# remove container
docker rm -f redis-new-slave01
docker rm -f redis-new-master01
