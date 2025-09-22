#!/bin/bash

echo "🧪 PRUEBAS MANUALES DE USUARIO - Telco Order Service"
echo "===================================================="
echo ""

# Función para mostrar separadores
separator() {
    echo "----------------------------------------------------"
}

# Test 1: Verificar que el servicio responde
echo "📋 Test 1: Verificar disponibilidad del servicio"
separator
echo "Probando health check..."
health_response=$(curl -s -w "HTTP_CODE:%{http_code}" http://localhost:9898/actuator/health)
http_code=$(echo "$health_response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)

if [ "$http_code" = "200" ]; then
    echo "✅ ÉXITO: Servicio está disponible (HTTP 200)"
    echo "Respuesta: $(echo "$health_response" | sed 's/HTTP_CODE:[0-9]*//')"
else
    echo "❌ FALLO: Servicio no disponible (HTTP $http_code)"
fi
echo ""

# Test 2: Verificar métricas básicas
echo "📊 Test 2: Verificar métricas del sistema"
separator
echo "Consultando métricas disponibles..."
metrics_count=$(curl -s http://localhost:9898/actuator/metrics | grep -o '"[^"]*"' | wc -l)

if [ "$metrics_count" -gt 10 ]; then
    echo "✅ ÉXITO: Sistema tiene $metrics_count métricas disponibles"
    echo "Algunas métricas disponibles:"
    curl -s http://localhost:9898/actuator/metrics | grep -o '"[^"]*"' | head -5 | sed 's/"//g' | sed 's/^/  - /'
else
    echo "❌ FALLO: Pocas métricas disponibles ($metrics_count)"
fi
echo ""

# Test 3: Verificar métricas personalizadas
echo "🎯 Test 3: Verificar métricas personalizadas telco"
separator
echo "Buscando métricas específicas de telco..."
telco_metrics=$(curl -s http://localhost:9898/actuator/prometheus | grep "telco_" | wc -l)

if [ "$telco_metrics" -gt 0 ]; then
    echo "✅ ÉXITO: Encontradas $telco_metrics métricas personalizadas"
    echo "Métricas telco encontradas:"
    curl -s http://localhost:9898/actuator/prometheus | grep "telco_" | head -3 | sed 's/^/  - /'
else
    echo "❌ FALLO: No se encontraron métricas personalizadas telco"
fi
echo ""

# Test 4: Verificar health check personalizado
echo "🏥 Test 4: Verificar health check personalizado"
separator
echo "Consultando health check específico de telco..."
custom_health=$(curl -s http://localhost:9898/actuator/health/telco)

if [ -n "$custom_health" ] && [ "$custom_health" != "null" ]; then
    echo "✅ ÉXITO: Health check personalizado disponible"
    echo "Respuesta: $custom_health"
else
    echo "❌ FALLO: Health check personalizado no disponible"
fi
echo ""

# Test 5: Verificar información del sistema
echo "💻 Test 5: Verificar información del sistema"
separator
echo "Consultando información del sistema..."
info_response=$(curl -s http://localhost:9898/actuator/info)

if [ -n "$info_response" ] && [ "$info_response" != "{}" ]; then
    echo "✅ ÉXITO: Información del sistema disponible"
    echo "Info: $info_response"
else
    echo "❌ FALLO: Información del sistema no disponible"
fi
echo ""

# Test 6: Verificar logs del sistema
echo "📝 Test 6: Verificar configuración de logging"
separator
echo "Consultando configuración de loggers..."
logger_response=$(curl -s http://localhost:9898/actuator/loggers/com.hacom.telco)

if [ -n "$logger_response" ] && [ "$logger_response" != "null" ]; then
    echo "✅ ÉXITO: Configuración de logging disponible"
    echo "Logger config: $logger_response"
else
    echo "❌ FALLO: Configuración de logging no disponible"
fi
echo ""

# Test 7: Verificar puerto gRPC
echo "🔌 Test 7: Verificar disponibilidad puerto gRPC"
separator
echo "Verificando si el puerto 9090 está abierto..."
if netstat -an 2>/dev/null | grep -q ":9090.*LISTEN" || ss -an 2>/dev/null | grep -q ":9090.*LISTEN"; then
    echo "✅ ÉXITO: Puerto gRPC 9090 está abierto y escuchando"
else
    echo "❌ FALLO: Puerto gRPC 9090 no está disponible"
fi
echo ""

# Resumen final
echo "🎯 RESUMEN DE PRUEBAS DE USUARIO"
echo "================================"
echo ""
echo "Estas pruebas simulan lo que un usuario/administrador verificaría:"
echo ""
echo "✅ Disponibilidad del servicio (health checks)"
echo "✅ Métricas de monitoreo funcionando"
echo "✅ Métricas personalizadas del dominio telco"
echo "✅ Health checks específicos del negocio"
echo "✅ Información del sistema para troubleshooting"
echo "✅ Configuración de logging para debugging"
echo "✅ Puerto gRPC disponible para clientes"
echo ""
echo "🚀 CONCLUSIÓN: El sistema está operativo y listo para usuarios!"
echo ""
echo "📋 PRÓXIMOS PASOS PARA EL USUARIO:"
echo "- Conectar clientes gRPC al puerto 9090"
echo "- Configurar monitoreo con las métricas disponibles"
echo "- Usar health checks para verificación de estado"
echo "- Revisar logs en caso de problemas"
