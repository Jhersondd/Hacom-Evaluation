# Demo de Funcionalidades - Telco Order Service Mejorado

## 🚀 Cómo Ejecutar la Demostración

### 1. Iniciar el Servicio

```bash
# Compilar el proyecto
./gradlew clean build

# Ejecutar con perfil de desarrollo
./gradlew bootRun --args='--spring.profiles.active=development'

# O ejecutar con perfil de producción (requiere MongoDB)
./gradlew bootRun --args='--spring.profiles.active=production'
```

### 2. Verificar que el Servicio está Funcionando

```bash
# Health Check General
curl http://localhost:9898/actuator/health

# Health Check Detallado
curl http://localhost:9898/actuator/health | jq '.'

# Métricas Prometheus
curl http://localhost:9898/actuator/prometheus

# Información de la Aplicación
curl http://localhost:9898/actuator/info
```

## 📊 Endpoints de Monitoreo Disponibles

### Health Checks
- `GET /actuator/health` - Estado general del sistema
- `GET /actuator/health/telco` - Health check personalizado de componentes

### Métricas
- `GET /actuator/metrics` - Lista de todas las métricas
- `GET /actuator/metrics/telco.orders.processed.total` - Pedidos procesados
- `GET /actuator/metrics/telco.sms.sent.total` - SMS enviados
- `GET /actuator/metrics/telco.grpc.requests.total` - Peticiones gRPC
- `GET /actuator/prometheus` - Métricas en formato Prometheus

### Información del Sistema
- `GET /actuator/env` - Variables de entorno
- `GET /actuator/configprops` - Propiedades de configuración
- `GET /actuator/beans` - Beans de Spring

## 🧪 Pruebas de Funcionalidad

### 1. Ejecutar Pruebas Unitarias

```bash
# Todas las pruebas unitarias
./gradlew test --tests "*Test"

# Solo pruebas del servicio gRPC
./gradlew test --tests "OrderServiceGrpcImplEnhancedTest"

# Solo pruebas del cliente SMPP
./gradlew test --tests "SmppClientEnhancedTest"
```

### 2. Ejecutar Pruebas de Integración

```bash
# Pruebas de integración (requiere Docker para TestContainers)
./gradlew test --tests "OrderProcessingIntegrationTest"
```

### 3. Ejecutar Pruebas de Rendimiento

```bash
# Pruebas de rendimiento completas
./gradlew test --tests "OrderProcessingPerformanceTest"

# Prueba específica de carga concurrente
./gradlew test --tests "OrderProcessingPerformanceTest.shouldProcess200OrdersConcurrentlyWithGoodPerformance"
```

## 🔧 Configuración de Entornos

### Desarrollo (development)
```yaml
# application.yml - perfil development
spring:
  profiles:
    active: development

smpp:
  enabled: false  # SMPP simulado

logging:
  level:
    com.hacom.telco: DEBUG
```

### Producción (production)
```yaml
# application.yml - perfil production
spring:
  profiles:
    active: production

smpp:
  enabled: true
  host: ${SMPP_HOST:localhost}
  port: ${SMPP_PORT:2775}
  systemId: ${SMPP_SYSTEM_ID:telco-service}
  password: ${SMPP_PASSWORD:password123}

mongodbUri: ${MONGODB_URI:mongodb://127.0.0.1:27017}
```

### Variables de Entorno para Producción
```bash
export SMPP_HOST=smpp.provider.com
export SMPP_PORT=2775
export SMPP_SYSTEM_ID=telco-prod
export SMPP_PASSWORD=secure-password
export MONGODB_URI=mongodb://mongo-cluster:27017
export MONGODB_DATABASE=telco_orders_prod
```

## 📈 Monitoreo en Tiempo Real

### 1. Métricas Clave a Monitorear

```bash
# Pedidos procesados por minuto
curl -s http://localhost:9898/actuator/metrics/telco.orders.processed.total | jq '.measurements[0].value'

# Tasa de errores
curl -s http://localhost:9898/actuator/metrics/telco.orders.failed.total | jq '.measurements[0].value'

# Tiempo promedio de procesamiento
curl -s http://localhost:9898/actuator/metrics/telco.order.processing.duration | jq '.measurements[] | select(.statistic=="MEAN") | .value'

# SMS enviados
curl -s http://localhost:9898/actuator/metrics/telco.sms.sent.total | jq '.measurements[0].value'

# Estado de conexión SMPP (via health check)
curl -s http://localhost:9898/actuator/health | jq '.components.telco.details.smpp'
```

### 2. Alertas Recomendadas

```bash
# Alerta si la tasa de error supera el 5%
error_rate=$(curl -s http://localhost:9898/actuator/metrics/telco.orders.failed.total | jq '.measurements[0].value')
total_rate=$(curl -s http://localhost:9898/actuator/metrics/telco.orders.processed.total | jq '.measurements[0].value')

# Alerta si el tiempo de procesamiento supera 2 segundos
avg_time=$(curl -s http://localhost:9898/actuator/metrics/telco.order.processing.duration | jq '.measurements[] | select(.statistic=="MEAN") | .value')

# Alerta si MongoDB no está disponible
mongo_status=$(curl -s http://localhost:9898/actuator/health | jq '.components.telco.details.mongodb.status')
```

## 🎯 Casos de Uso de Demostración

### 1. Procesamiento Normal de Pedidos

```bash
# Simular cliente gRPC (requiere grpcurl o cliente personalizado)
# Ejemplo de pedido válido:
{
  "orderId": "DEMO-001",
  "customerId": "CUSTOMER-DEMO",
  "customerPhoneNumber": "+1234567890",
  "items": ["Smartphone", "Plan de datos", "Seguro"]
}
```

### 2. Validación de Errores

```bash
# Pedido con OrderId inválido (debería fallar)
{
  "orderId": "",
  "customerId": "CUSTOMER-DEMO",
  "customerPhoneNumber": "+1234567890",
  "items": ["Smartphone"]
}

# Pedido con teléfono inválido (debería fallar)
{
  "orderId": "DEMO-002",
  "customerId": "CUSTOMER-DEMO",
  "customerPhoneNumber": "invalid-phone",
  "items": ["Smartphone"]
}
```

### 3. Prueba de Carga

```bash
# Script para generar carga (ejemplo en bash)
#!/bin/bash
for i in {1..100}; do
  # Simular envío de pedido
  echo "Enviando pedido $i"
  # Aquí iría la llamada gRPC real
  sleep 0.1
done
```

## 📊 Dashboard de Métricas Recomendado

### Grafana Dashboard (ejemplo de queries)

```promql
# Throughput de pedidos
rate(telco_orders_processed_total[5m])

# Tasa de error
rate(telco_orders_failed_total[5m]) / rate(telco_orders_processed_total[5m]) * 100

# Latencia P95
histogram_quantile(0.95, telco_order_processing_duration_bucket)

# Pedidos activos
telco_orders_active

# Estado de componentes
up{job="telco-order-service"}
```

### Alertas Prometheus (ejemplo)

```yaml
groups:
- name: telco-order-service
  rules:
  - alert: HighErrorRate
    expr: rate(telco_orders_failed_total[5m]) / rate(telco_orders_processed_total[5m]) > 0.05
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High error rate in telco order service"
      
  - alert: HighLatency
    expr: histogram_quantile(0.95, telco_order_processing_duration_bucket) > 2
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High latency in order processing"
      
  - alert: ServiceDown
    expr: up{job="telco-order-service"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Telco order service is down"
```

## 🔍 Troubleshooting

### Problemas Comunes

1. **MongoDB no conecta**
   ```bash
   # Verificar estado
   curl http://localhost:9898/actuator/health | jq '.components.telco.details.mongodb'
   
   # Logs
   tail -f logs/application.log | grep MongoDB
   ```

2. **SMPP no conecta**
   ```bash
   # Verificar configuración
   curl http://localhost:9898/actuator/env | jq '.propertySources[] | select(.name=="applicationConfig") | .properties | with_entries(select(.key | startswith("smpp")))'
   
   # Estado de conexión
   curl http://localhost:9898/actuator/health | jq '.components.telco.details.smpp'
   ```

3. **Akka ActorSystem problemas**
   ```bash
   # Estado del sistema de actores
   curl http://localhost:9898/actuator/health | jq '.components.telco.details.akka'
   
   # Logs de Akka
   tail -f logs/application.log | grep akka
   ```

### Logs Útiles

```bash
# Logs de procesamiento de pedidos
tail -f logs/application.log | grep "OrderServiceGrpcImplEnhanced\|OrderProcessorActor"

# Logs de SMPP
tail -f logs/application.log | grep "SmppClientEnhanced"

# Logs de métricas
tail -f logs/application.log | grep "OrderMetrics"

# Logs de health checks
tail -f logs/application.log | grep "TelcoHealthIndicator"
```

## 🎉 Resultados Esperados

Después de ejecutar la demostración, deberías ver:

1. **Servicio funcionando** en puerto 9898
2. **Health checks** mostrando estado UP
3. **Métricas** incrementándose con cada pedido
4. **Logs estructurados** con información detallada
5. **Pruebas pasando** con métricas de rendimiento
6. **SMPP simulado** funcionando (o real si está configurado)
7. **MongoDB** persistiendo pedidos correctamente

El sistema está ahora listo para producción con monitoreo completo y observabilidad avanzada.
