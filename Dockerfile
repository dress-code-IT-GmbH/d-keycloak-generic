# Documentation: https://www.keycloak.org/server/containers
FROM quay.io/keycloak/keycloak:latest AS builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=token-exchange

# Declare DB is pgsql for build
ENV KC_DB=postgres

WORKDIR /opt/keycloak
 
# RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

# Health check
USER root
WORKDIR /opt/helper/health

RUN mkdir -p lib
RUN cp /opt/keycloak/lib/lib/main/com.fasterxml.jackson.* lib
COPY health/health_check.sh .
COPY health/HealthCheck.java .



FROM quay.io/keycloak/keycloak:latest

COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=builder /opt/helper/ /opt/helper/

HEALTHCHECK --interval=1m --start-period=30s --timeout=30s \
  CMD bash /opt/helper/health/health_check.sh

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
