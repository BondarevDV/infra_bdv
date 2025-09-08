#!/bin/bash
set -e

echo "🧪 Testing Spark HA Cluster..."

# Test ZooKeeper
echo "Testing ZooKeeper..."
docker-compose -f ../docker-composes/docker-compose.spark-ha.yml exec zookeeper bash -c "echo 'ruok' | nc localhost 2181"

# Test Spark Masters
echo "Testing Spark Masters..."
for i in {1..3}; do
  echo "Master $i: $(curl -s http://localhost:808$i | grep -o 'Spark Master at' || echo 'Not responding')"
done

# Test Livy
echo "Testing Livy..."
curl -X GET "http://localhost:8998/sessions" || echo "Livy test failed"

echo "✅ HA Cluster test completed!"