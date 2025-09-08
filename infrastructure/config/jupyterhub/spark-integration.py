# Spark configuration for JupyterHub
c.Spawner.environment = {
    'SPARK_HOME': '/opt/bitnami/spark',
    'PYSPARK_PYTHON': '/usr/bin/python3',
    'PYSPARK_DRIVER_PYTHON': 'python3',
    'SPARK_MASTER': 'spark://spark-master-1:7077,spark-master-2:7077,spark-master-3:7077',
    'LIVY_URL': 'http://livy:8998'
}

# Add Spark kernels
c.KernelSpecManager.whitelist = {
    'python3', 'pyspark', 'spark-r', 'spark-scala'
}