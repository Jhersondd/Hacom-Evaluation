# Telco Order Service

Sistema de procesamiento de pedidos para telecomunicaciones que integra múltiples tecnologías incluyendo Spring Boot, gRPC, Akka Actors, MongoDB y SMPP.

## Tecnologías Utilizadas

- **Java 17**
- **Spring Boot 3.5.6**
- **Gradle 8.14.3**
- **Spring WebFlux** (Programación reactiva)
- **Spring Data MongoDB Reactive**
- **gRPC** (Comunicación entre servicios)
- **Akka Classic Actors** (Procesamiento asíncrono)
- **MongoDB** (Base de datos)
- **SMPP** (Envío de SMS)
- **Spring Actuator** (Métricas y monitoreo)
- **Prometheus** (Métricas)
- **Log4j2** (Logging)

## Arquitectura

```
Cliente gRPC → OrderServiceGrpcImpl → OrderProcessorActor → MongoDB
                                                        ↓
                                                   SmppClient (SMS)
```

## Configuración

### Variables de Entorno (application.yml)

```yaml
apiPort: 9898
mongodbUri: mongodb://127.0.0.1:27017
mongodbDatabase: exampleDb
```

### Configuraciones Programáticas

- **MongoDB**: Configurado programáticamente en `MongoConfig.java`
- **WebFlux Puerto**: Configurado programáticamente en `WebFluxConfig.java` (puerto 9898)
- **Akka ActorSystem**: Configurado en `AkkaConfig.java`

## Estructura del Proyecto

```
src/main/java/com/hacom/telco/
├── TelcoOrderServiceApplication.java    # Aplicación principal
├── actor/
│   └── OrderProcessorActor.java         # Actor para procesar pedidos
├── config/
│   ├── AkkaConfig.java                  # Configuración Akka
│   ├── MongoConfig.java                 # Configuración MongoDB
│   └── WebFluxConfig.java               # Configuración WebFlux
├── grpc/
│   ├── OrderServiceGrpcImpl.java        # Implementación servicio gRPC
│   └── proto/
│       └── OrderController.java         # Controlador REST
├── model/
│   └── Order.java                       # Modelo de datos
├── repository/
│   └── OrderRepository.java             # Repositorio MongoDB
└── smpp/
    └── SmppClient.java                  # Cliente SMPP

src/main/proto/
└── order.proto                         # Definición protobuf

src/main/resources/
├── application.yml                      # Configuración aplicación
└── log4j2.yml                          # Configuración logging
```

## Servicios Disponibles

### 1. Servicio gRPC

**Puerto**: Configurado automáticamente por Spring Boot
**Servicio**: `OrderService`
**Método**: `InsertOrder`

**Request**:
```protobuf
message OrderRequest {
  string orderId = 1;
  string customerId = 2;
  string customerPhoneNumber = 3;
  repeated string items = 4;
}
```

**Response**:
```protobuf
message OrderResponse {
  string orderId = 1;
  string status = 2;
}
```

### 2. API REST

**Puerto**: 9898

#### Endpoints:

1. **Consultar estado de pedido**
   ```
   GET /orders/{orderId}
   ```

2. **Consultar pedidos por rango de fecha**
   ```
   GET /orders/range?from=2024-01-01T00:00:00Z&to=2024-12-31T23:59:59Z
   ```

### 3. Actuator y Métricas

- **Health Check**: `http://localhost:9898/actuator/health`
- **Métricas**: `http://localhost:9898/actuator/metrics`
- **Prometheus**: `http://localhost:9898/actuator/prometheus`

## Modelo de Datos

```java
public class Order {
    @Id
    private ObjectId _id;
    private String orderId;
    private String customerId;
    private String customerPhoneNumber;
    private String status;
    private List<String> items;
    private OffsetDateTime ts;
}
```

## Flujo de Procesamiento

1. **Cliente envía pedido** via gRPC
2. **OrderServiceGrpcImpl** recibe la petición
3. **OrderProcessorActor** procesa el pedido asíncronamente:
   - Crea objeto Order
   - Guarda en MongoDB
   - Envía SMS via SMPP
   - Responde al cliente gRPC

## Requisitos del Sistema

### Software Requerido

- Java 17+
- MongoDB 4.4+
- Gradle 8.0+ (incluido wrapper)

### Opcional

- Servidor SMPP (para envío real de SMS)

## Instalación y Ejecución

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd telco-order-service
```

### 2. Configurar MongoDB

Asegúrate de que MongoDB esté ejecutándose en:
```
mongodb://127.0.0.1:27017
```

### 3. Compilar el proyecto

```bash
./gradlew clean build
```

### 4. Ejecutar la aplicación

```bash
./gradlew bootRun
```

La aplicación estará disponible en:
- **API REST**: http://localhost:9898
- **Actuator**: http://localhost:9898/actuator
- **gRPC**: Puerto automático de Spring Boot

## Desarrollo

### Generar clases protobuf

```bash
./gradlew generateProto
```

### Ejecutar tests

```bash
./gradlew test
```

### Ver logs

Los logs se configuran en `src/main/resources/log4j2.yml` y se muestran en consola.

## Configuración SMPP

Para configuración de producción, modifica `SmppClient.java` con:
- Host del servidor SMPP
- Puerto
- Credenciales (systemId, password)
- Configuraciones específicas del proveedor

## Monitoreo

### Métricas Disponibles

- Métricas estándar de Spring Boot
- Métricas de Actuator
- Métricas exportadas a Prometheus

### Health Checks

El endpoint `/actuator/health` proporciona información sobre:
- Estado de la aplicación
- Conectividad MongoDB
- Estado del ActorSystem

## Troubleshooting

### Problemas Comunes

1. **Error de conexión MongoDB**
   - Verificar que MongoDB esté ejecutándose
   - Verificar URI de conexión en application.yml

2. **Error de compilación protobuf**
   - Ejecutar `./gradlew clean generateProto`

3. **Puerto en uso**
   - Cambiar `apiPort` en application.yml

### Logs

Los logs proporcionan información detallada sobre:
- Procesamiento de pedidos
- Conexiones MongoDB
- Envío de SMS
- Errores del sistema

## Contribución

1. Fork el proyecto
2. Crear branch para feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push al branch (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## Licencia

Este proyecto es para fines educativos y de evaluación técnica.

## Contacto

Para preguntas o soporte, Jherson Concha Yangua y contactar a: jjhersond@gmail.com
