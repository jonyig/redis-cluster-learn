
# get requirepass from redis-cluster
requirepass=$(cat redis-cluster.conf | grep requirepass | cut -d' ' -f2)
# get masterauth from redis-cluster
masterauth=$(cat redis-cluster.conf | grep masterauth | cut -d' ' -f2)

# get first master node id
firstMasterNode=$(docker exec -t manual_redis-node1_1 redis-cli -h manual_redis-node1_1 -p 6379 -a $requirepass cluster nodes| grep -v fail | grep master | head -1 | cut -d' ' -f1)

# create master redis container
docker run -d --name redis-new-master01 --network manual_default redis:7.0 --cluster-enabled yes --appendonly yes  --requirepass $requirepass --masterauth $masterauth
# create slave redis container
docker run -d --name redis-new-slave01 --network manual_default redis:7.0 --cluster-enabled yes --appendonly yes  --requirepass $requirepass --masterauth $masterauth

# add master to cluster
docker exec -it manual_redis-node1_1 redis-cli --cluster add-node redis-new-master01:6379  manual_redis-node6_1:6379 -a $requirepass

# get new master node id
newMasterNode=$(docker exec -t manual_redis-node1_1 redis-cli -h redis-new-master01 -p 6379 -a $requirepass cluster nodes | grep myself | cut -d' ' -f1)

# wait for cluster sync
sleep 3

# reshard slots to new master
docker exec -it manual_redis-node1_1 redis-cli --cluster reshard manual_redis-node1_1:6379 --cluster-from $firstMasterNode --cluster-to $newMasterNode --cluster-slots 1 --cluster-yes  -a $requirepass

# balance
docker exec -it manual_redis-node1_1 redis-cli --cluster rebalance manual_redis-node1_1:6379 -a $requirepass

# add slave node
docker exec -t manual_redis-node1_1 redis-cli --cluster add-node redis-new-slave01:6379 manual_redis-node1_1:6379  --cluster-slave -a $requirepass
