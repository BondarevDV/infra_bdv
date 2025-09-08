export SPARK_HOME=/opt/bitnami/spark
export SPARK_MASTER=spark://spark-master-1:7077,spark-master-2:7077,spark-master-3:7077
export LIVY_URL=http://livy:8998
export ZEPPELIN_JAVA_OPTS="-Dspark.master=$SPARK_MASTER -Dlivy.url=$LIVY_URL"