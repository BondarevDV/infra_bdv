import os
from datetime import timedelta

# MinIO S3 Storage Configuration
STORAGES = {
    "default": {
        "class": "storages.backends.s3boto3.S3Boto3Storage",
        "options": {
            "access_key": os.getenv('LABEL_STUDIO_S3_ACCESS_KEY_ID', 'minioadmin'),
            "secret_key": os.getenv('LABEL_STUDIO_S3_SECRET_ACCESS_KEY', 'minioadmin'),
            "endpoint_url": os.getenv('LABEL_STUDIO_S3_ENDPOINT', 'http://minio:9000'),
            "bucket_name": os.getenv('LABEL_STUDIO_S3_BUCKET', 'label-studio-data'),
            "region_name": os.getenv('LABEL_STUDIO_S3_REGION', 'us-east-1'),
            "custom_domain": None,
            "secure_urls": False,
        }
    }
}

# Database Configuration
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('LABEL_STUDIO_DB_NAME', 'label_studio'),
        'USER': os.getenv('LABEL_STUDIO_DB_USER', 'admin'),
        'PASSWORD': os.getenv('LABEL_STUDIO_DB_PASSWORD', 'securepassword123'),
        'HOST': os.getenv('LABEL_STUDIO_DB_HOST', 'postgres'),
        'PORT': os.getenv('LABEL_STUDIO_DB_PORT', '5432'),
    }
}

# Redis Configuration
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": f"redis://{os.getenv('LABEL_STUDIO_REDIS_HOST', 'redis')}:{os.getenv('LABEL_STUDIO_REDIS_PORT', '6379')}/{os.getenv('LABEL_STUDIO_REDIS_DB', '1')}",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
        }
    }
}

# Security
SECRET_KEY = os.getenv('LABEL_STUDIO_SECRET_KEY', 'your-secret-key-here')
ALLOWED_HOSTS = ['*']
CSRF_TRUSTED_ORIGINS = ['http://localhost:8080', 'http://127.0.0.1:8080']

# Features
ENABLE_ML_BACKEND = True
ENABLE_TASKS_STREAM = True