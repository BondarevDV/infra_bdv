#!/bin/bash
set -e

echo "🔧 Managing HA Spark Cluster..."

case "$1" in
  status)
    echo "Spark Masters:"
    docker-compose -f ../docker-composes/docker-compose.spark-ha.yml ps | grep spark-master
    echo ""
    echo "Spark Workers:"
    docker-compose -f ../docker-composes/docker-compose.spark-ha.yml ps | grep spark-worker
    echo ""
    echo "ZooKeeper:"
    docker-compose -f ../docker-composes/docker-compose.spark-ha.yml ps | grep zookeeper
    ;;
    
  scale)
    if [ -z "$2" ]; then
      echo "Usage: $0 scale <number-of-workers>"
      exit 1
    fi
    docker-compose -f ../docker-composes/docker-compose.spark-ha.yml up -d --scale spark-worker=$2 --no-recreate
    echo "✅ Spark workers scaled to $2 instances"
    ;;
    
  restart-master)
    if [ -z "$2" ]; then
      echo "Usage: $0 restart-master <master-number>"
      exit 1
    fi
    docker-compose -f ../docker-composes/docker-compose.spark-ha.yml restart spark-master-$2
    echo "✅ Spark master $2 restarted"
    ;;
    
  monitor)
    echo "Opening Spark monitoring..."
    echo "Spark Master UI: http://spark-master-1.dev.tnt.ru:8081"
    echo "Spark History: http://spark-history.dev.tnt.ru:18080"
    echo "Grafana: http://spark-grafana.dev.tnt.ru:3000"
    echo "Livy: http://livy.dev.tnt.ru:8998"
    ;;
    
  *)
    echo "Usage: $0 {status|scale|restart-master|monitor}"
    exit 1
    ;;
esac