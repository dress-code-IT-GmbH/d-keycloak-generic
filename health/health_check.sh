#!/bin/bash

java -cp /opt/helper/health:/opt/helper/health/lib/* /opt/helper/health/HealthCheck.java https://localhost:9000/health/live
