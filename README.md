# 🏭 Sistema de Producción Multinacional
## Simulador de Plantas con Análisis en Metabase

---

## 📦 CONTENIDO DEL PROYECTO

```
proyecto/
├── docker-compose.yml          # Orquestación de contenedores
├── Dockerfile                  # Imagen del simulador Python
├── simulator.py                # Simulador de producción (10 máquinas)
├── init_database.sql          # Estructura completa de la BD
├── GUIA_METABASE.md           # Guía detallada de Metabase
└── README.md                  # Este archivo
```

---

## 🎯 ¿QUÉ HACE ESTE PROYECTO?

Simula un sistema de producción de **alimentos concentrados** en **5 países** con:

- ✅ **8 plantas** distribuidas globalmente
- ✅ **19 máquinas** operando simultáneamente
- ✅ **10 productos diferentes** (concentrados y cuido)
- ✅ **3 turnos** de producción (mañana/tarde/noche)
- ✅ **4% de tasa de defectos** (realista)
- ✅ **Datos en tiempo real** insertándose en PostgreSQL

Todo esto visualizable en **Metabase** con dashboards profesionales.

---

## 🚀 INICIO RÁPIDO (5 MINUTOS)

### Prerequisitos

- Docker instalado
- Docker Compose instalado
- Puertos libres: 3000, 5432, 8080

### Paso 1: Preparar Archivos

```bash
# Crear directorio del proyecto
mkdir produccion-multinacional
cd produccion-multinacional

# Copiar todos los archivos aquí:
# - docker-compose.yml
# - Dockerfile
# - simulator.py
# - init_database.sql
```

### Paso 2: Iniciar Sistema

```bash
# Iniciar todos los servicios
docker-compose up -d

# Ver logs en tiempo real (CTRL+C para salir)
docker-compose logs -f
```

### Paso 3: Esperar Inicialización

⏰ **Tiempos de espera:**
- PostgreSQL: ~15 segundos
- Metabase: **2-3 minutos** (primera vez)
- Simulador: Inicia automáticamente

💡 **Verificar estado:**
```bash
docker-compose ps
```

Todos deben estar "Up" (running).

### Paso 4: Acceder a las Aplicaciones

| Aplicación | URL | Usuario | Contraseña |
|------------|-----|---------|------------|
| **Metabase** | http://localhost:3000 | (configurar) | - |
| **PgAdmin** | http://localhost:8080 | admin@admin.com | secret_password |

---

## 📊 CONFIGURACIÓN DE METABASE

### Primera Vez

1. Abrir: http://localhost:3000
2. Crear cuenta de administrador
3. Conectar a PostgreSQL:
   - Host: `postgres_db`
   - Puerto: `5432`
   - Base de datos: `production_data`
   - Usuario: `admin`
   - Contraseña: `secret_password`

📖 **Guía completa**: Ver archivo `GUIA_METABASE.md`

---

## 🏗️ ARQUITECTURA DEL SISTEMA

### Estructura de Datos

```
TABLAS MAESTRAS:
├── paises (5 países)
├── plantas (8 plantas)
├── maquinas (19 máquinas)
├── productos (10 productos)
├── turnos (3 turnos)
└── planta_productos (configuración de producción)

TABLA TRANSACCIONAL:
└── produccion_global (datos en tiempo real)

VISTAS ANALÍTICAS:
├── vista_produccion_completa
└── kpi_por_planta
```

### Distribución Geográfica

| País | Plantas | Máquinas | Productos Principales |
|------|---------|----------|----------------------|
| 🇨🇴 Colombia | 2 | 3 | Aves, Bovinos, Caninos |
| 🇲🇽 México | 2 | 5 | Mascotas, Bovinos, Porcinos |
| 🇧🇷 Brasil | 2 | 5 | Diversificado |
| 🇺🇸 USA | 1 | 3 | Todas las líneas |
| 🇪🇸 España | 1 | 2 | Mascotas Premium |

---

## 🔧 COMANDOS ÚTILES

### Ver Logs en Tiempo Real

```bash
# Todos los servicios
docker-compose logs -f

# Solo el simulador
docker-compose logs -f simulator

# Solo Metabase
docker-compose logs -f metabase
```

### Detener el Sistema

```bash
# Detener sin borrar datos
docker-compose stop

# Detener y eliminar contenedores (datos persisten)
docker-compose down

# Detener y eliminar TODO (incluye datos)
docker-compose down -v
```

### Reiniciar un Servicio Específico

```bash
docker-compose restart simulator
docker-compose restart metabase
```

### Acceder a PostgreSQL desde Terminal

```bash
docker exec -it production_db psql -U admin -d production_data
```

Dentro de psql:
```sql
-- Ver cuántos registros hay
SELECT COUNT(*) FROM produccion_global;

-- Ver producción de las últimas 24 horas
SELECT 
  pais, 
  COUNT(*) as total,
  SUM(CASE WHEN estado = 'OK' THEN 1 ELSE 0 END) as ok
FROM vista_produccion_completa
WHERE timestamp > NOW() - INTERVAL '24 hours'
GROUP BY pais;
```

---

## 📈 EJEMPLOS DE CONSULTAS

### Producción del Día por País

```sql
SELECT 
  p.nombre AS pais,
  COUNT(*) AS total_bultos,
  ROUND(100.0 * SUM(CASE WHEN pg.estado = 'OK' THEN 1 ELSE 0 END) / COUNT(*), 2) AS calidad
FROM produccion_global pg
JOIN maquinas m ON pg.id_maquina = m.id
JOIN plantas pl ON m.id_planta = pl.id
JOIN paises p ON pl.id_pais = p.id
WHERE pg.timestamp::date = CURRENT_DATE
GROUP BY p.nombre
ORDER BY total_bultos DESC;
```

### Top 5 Máquinas Más Productivas

```sql
SELECT 
  m.codigo,
  pl.nombre AS planta,
  COUNT(*) AS total_producido
FROM produccion_global pg
JOIN maquinas m ON pg.id_maquina = m.id
JOIN plantas pl ON m.id_planta = pl.id
WHERE pg.timestamp > NOW() - INTERVAL '7 days'
GROUP BY m.codigo, pl.nombre
ORDER BY total_producido DESC
LIMIT 5;
```

### Análisis de Defectos por Producto

```sql
SELECT 
  pr.nombre AS producto,
  COUNT(*) AS total,
  SUM(CASE WHEN pg.estado = 'DEFECTO' THEN 1 ELSE 0 END) AS defectos,
  ROUND(100.0 * SUM(CASE WHEN pg.estado = 'DEFECTO' THEN 1 ELSE 0 END) / COUNT(*), 2) AS tasa_defectos
FROM produccion_global pg
JOIN productos pr ON pg.id_producto = pr.id
GROUP BY pr.nombre
ORDER BY tasa_defectos DESC;
```

---

## 🎓 CASOS DE USO PARA EL PROYECTO ACADÉMICO

### Dashboard Gerencial
- KPI de producción total
- Comparativo entre países
- Tendencias de calidad mensual
- Productos más producidos

### Dashboard de Calidad
- Tasa de defectos por planta
- Análisis de causas (temperatura, humedad)
- Máquinas con problemas
- Tendencia de mejora

### Dashboard Operativo
- Producción en tiempo real
- Estado de máquinas
- Alertas de calidad
- Producción por turno

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### El simulador no inicia

```bash
# Ver qué está pasando
docker-compose logs simulator

# Verificar que PostgreSQL esté listo
docker-compose logs postgres_db | grep "ready to accept"

# Reiniciar el simulador
docker-compose restart simulator
```

### Metabase no conecta a la BD

1. Asegúrate de usar `postgres_db` como host (NO `localhost`)
2. Verifica las credenciales en `docker-compose.yml`
3. Espera 2-3 minutos después de `docker-compose up`

### No veo datos en Metabase

1. Verifica que el simulador esté corriendo:
   ```bash
   docker-compose ps
   ```

2. Verifica que haya datos en PostgreSQL:
   ```bash
   docker exec -it production_db psql -U admin -d production_data -c "SELECT COUNT(*) FROM produccion_global;"
   ```

3. Refresca las tablas en Metabase:
   - Admin → Databases → Producción Global → Sync database schema

---

## 📝 NOTAS IMPORTANTES

### Performance

- El simulador inserta ~10-12 registros por minuto (19 máquinas × 5 seg)
- En 1 hora: ~600 registros
- En 1 día: ~14,400 registros
- En 1 semana: ~100,000 registros

### Almacenamiento

- PostgreSQL crece ~1MB por cada 10,000 registros
- Después de 1 semana: ~10MB de datos
- Los volúmenes persisten entre reinicios

### Recursos del Sistema

- CPU: ~5% en idle
- RAM: ~1.5GB total (todos los contenedores)
- Disco: ~2GB (imágenes + datos)

---

## 🎯 OBJETIVOS DE APRENDIZAJE

Con este proyecto aprenderás:

- ✅ Diseño de bases de datos relacionales
- ✅ Modelado de procesos industriales
- ✅ Docker y orquestación de servicios
- ✅ Análisis de datos con Metabase
- ✅ KPIs productivos y gerenciales
- ✅ Python para simulación de datos
- ✅ PostgreSQL y SQL avanzado

---

## 📚 PRÓXIMOS PASOS

1. **Explorar Metabase**: Crear tus primeros dashboards
2. **Modificar el simulador**: Cambiar tasas de defectos, productos, etc.
3. **Agregar más datos**: Crear nuevas plantas o países
4. **Experimentar con SQL**: Hacer consultas más complejas
5. **Presentar resultados**: Usar Metabase para tu exposición

---

## 🤝 CRÉDITOS

Proyecto académico de simulación de producción multinacional.

---

## 📄 LICENCIA

MIT License - Libre para uso educativo

---

**¿Listo para empezar? 🚀**

```bash
docker-compose up -d
```# metabase_indicadores_maquinas
