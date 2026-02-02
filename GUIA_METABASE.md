# 🎯 GUÍA COMPLETA DE CONFIGURACIÓN DE METABASE
## Sistema de Producción Multinacional

---

## 📋 TABLA DE CONTENIDOS
1. [Instalación y Puesta en Marcha](#1-instalación-y-puesta-en-marcha)
2. [Configuración Inicial de Metabase](#2-configuración-inicial-de-metabase)
3. [Creación de Usuarios y Roles](#3-creación-de-usuarios-y-roles)
4. [Primeros Dashboards](#4-primeros-dashboards)
5. [KPIs Recomendados](#5-kpis-recomendados)
6. [Consejos y Mejores Prácticas](#6-consejos-y-mejores-prácticas)

---

## 1. INSTALACIÓN Y PUESTA EN MARCHA

### Paso 1: Iniciar el Sistema Completo

```bash
# Asegúrate de estar en el directorio del proyecto
cd /ruta/a/tu/proyecto

# Detener contenedores anteriores (si existen)
docker-compose down -v

# Iniciar todos los servicios
docker-compose up -d

# Ver los logs para confirmar que todo está bien
docker-compose logs -f
```

### Paso 2: Esperar Inicialización (IMPORTANTE)

⏰ **Tiempo estimado de espera:**
- PostgreSQL: 10-15 segundos
- PgAdmin: 20-30 segundos
- Metabase: **2-3 minutos** (primera vez puede tomar hasta 5 minutos)
- Simulador: Inicia automáticamente después de PostgreSQL

💡 **Cómo saber si está listo:**
```bash
# Verificar estado de servicios
docker-compose ps

# Ver logs de Metabase (buscar "Metabase Initialization Complete")
docker-compose logs metabase | grep -i "complete"
```

### Paso 3: Acceder a las Interfaces

| Servicio | URL | Usuario | Contraseña |
|----------|-----|---------|------------|
| **Metabase** | http://localhost:3000 | (configurar en primer acceso) | - |
| **PgAdmin** | http://localhost:8080 | admin@admin.com | secret_password |
| **PostgreSQL** | localhost:5432 | admin | secret_password |

---

## 2. CONFIGURACIÓN INICIAL DE METABASE

### Primera Vez - Setup Wizard

1. **Abrir Metabase**: http://localhost:3000

2. **Pantalla de Bienvenida**:
   - Idioma: Español (o el que prefieras)
   - Clic en "Vamos"

3. **Crear Cuenta de Administrador**:
   ```
   Nombre: Gerente General
   Email: gerente@produccion.com
   Contraseña: Admin123!
   Nombre de la empresa: Producción Multinacional
   ```

4. **Conectar Base de Datos**:
   - Tipo: PostgreSQL
   - Nombre: `Producción Global`
   - Host: `postgres_db` (⚠️ NO uses localhost)
   - Puerto: `5432`
   - Nombre de la BD: `production_data`
   - Usuario: `admin`
   - Contraseña: `secret_password`
   
   ✅ Clic en "Probar conexión" → Debe decir "Conexión exitosa"

5. **Configuración de Uso**:
   - Tipo de uso: "Análisis de datos empresariales"
   - Permitir recolección de datos: Tú decides (no afecta el proyecto)

6. **¡Listo!** 🎉

---

## 3. CREACIÓN DE USUARIOS Y ROLES

### Sistema de Permisos en Metabase

Metabase maneja **3 niveles de acceso**:

| Rol | Permisos | Uso Recomendado |
|-----|----------|-----------------|
| **Administrador** | Todo (crear users, dashboards, configurar) | Gerente General, IT |
| **Editor** | Crear/editar preguntas y dashboards | Jefes de Planta, Analistas |
| **Viewer** | Solo ver dashboards compartidos | Supervisores, Operadores |

### Crear Usuarios

1. **Ir a Configuración** (ícono de engranaje arriba a la derecha)
2. **Admin Settings** → **People**
3. **Add someone** (botón azul)

#### Ejemplos de Usuarios:

**Usuario 1: Gerente de Planta (Editor)**
```
Nombre: María López
Email: maria.lopez@produccion.com
Grupos: Editores
Contraseña: PlantaMgr2024!
```

**Usuario 2: Supervisor de Turno (Viewer)**
```
Nombre: Carlos Ruiz
Email: carlos.ruiz@produccion.com
Grupos: Solo lectura (Viewer)
Contraseña: Supervisor2024!
```

**Usuario 3: Analista de Calidad (Editor)**
```
Nombre: Ana Torres
Email: ana.torres@produccion.com
Grupos: Editores
Contraseña: Calidad2024!
```

### Configurar Colecciones (Organización)

1. **Ir a** → **Colecciones** (ícono de carpeta)
2. **Crear colecciones**:
   - 📊 "Dashboards Gerenciales" (Solo Admins)
   - 🏭 "Reportes de Producción" (Editores y Admins)
   - 📈 "KPIs por Planta" (Todos)

---

## 4. PRIMEROS DASHBOARDS

### Dashboard 1: Vista General de Producción

**Pasos para crearlo:**

1. **Nueva Pregunta** (botón azul arriba)
2. **Fuente de datos**: `Producción Global` → Tabla `vista_produccion_completa`
3. **Tipo**: Número (métrica)

**Tarjeta 1: Total de Bultos Producidos Hoy**
```sql
Filtrar: timestamp = hoy
Resumir: Contar registros
```

**Tarjeta 2: Tasa de Calidad Hoy**
```sql
Expresión personalizada:
sum(case when estado = 'OK' then 1 else 0 end) * 100.0 / count(*)
```

**Gráfico 1: Producción por País (Barras)**
- Agrupar por: `pais`
- Resumir: Contar registros
- Ordenar: Descendente

**Gráfico 2: Tendencia de Producción (Línea de Tiempo)**
- Eje X: `timestamp` (por hora)
- Eje Y: Contar registros
- Filtro: Últimos 7 días

**Gráfico 3: Distribución de Productos (Pastel)**
- Segmento: `categoria`
- Valor: Contar registros

### Dashboard 2: Calidad y Defectos

**Tarjeta 1: Tasa de Defectos Global**
```sql
sum(case when estado = 'DEFECTO' then 1 else 0 end) * 100.0 / count(*)
```

**Tabla 1: Top 5 Máquinas con Más Defectos**
- Agrupar por: `codigo_maquina`, `planta`
- Filtro: `estado = 'DEFECTO'`
- Resumir: Contar
- Ordenar: Descendente
- Límite: 5

**Gráfico 1: Defectos por Turno (Barras agrupadas)**
- X: `turno`
- Y: Contar
- Color: `estado`

### Dashboard 3: Análisis por Planta

**Usar vista pre-creada**: `kpi_por_planta`

**Tabla 1: KPIs por Planta**
- Mostrar columnas:
  - Planta
  - País
  - Total Bultos
  - Bultos OK
  - Porcentaje Calidad
  - Peso Promedio

---

## 5. KPIs RECOMENDADOS

### KPIs Productivos (Para Supervisores y Jefes de Planta)

1. **Eficiencia de Producción**
   ```
   (Total producido / Capacidad diaria de la planta) * 100
   ```

2. **Tiempo Promedio entre Productos**
   ```
   Tiempo transcurrido entre registros consecutivos
   ```

3. **Utilización de Máquinas**
   ```
   Horas productivas / Horas totales del turno
   ```

4. **Productos por Hora por Máquina**
   ```
   COUNT(*) agrupado por máquina y hora
   ```

### KPIs Gerenciales (Para Gerentes y Directores)

1. **OEE (Overall Equipment Effectiveness)**
   ```
   (Disponibilidad × Rendimiento × Calidad) × 100
   ```
   - Disponibilidad: 95% (supuesto, sin paros)
   - Rendimiento: Velocidad real / Velocidad teórica
   - Calidad: % bultos OK

2. **Comparativo entre Países**
   ```
   Producción mensual por país
   Tasa de calidad por región
   ```

3. **Tendencias de Calidad**
   ```
   % defectos en los últimos 30 días (línea de tiempo)
   ```

4. **Análisis de Productos**
   ```
   Top 5 productos más producidos
   Productos con mayor tasa de defectos
   ```

5. **Costo Estimado de Defectos**
   ```sql
   SELECT 
     categoria,
     COUNT(*) as total_defectos,
     ROUND(AVG(peso_real * 2.5), 2) as costo_estimado_usd
   FROM vista_produccion_completa
   WHERE estado = 'DEFECTO'
     AND timestamp >= CURRENT_DATE - INTERVAL '30 days'
   GROUP BY categoria
   ORDER BY costo_estimado_usd DESC
   ```
   *(Suponiendo $2.5 USD por kg de producto perdido)*

---

## 6. CONSEJOS Y MEJORES PRÁCTICAS

### ✅ DO's (Hacer)

1. **Usar Vistas Pre-creadas**
   - `vista_produccion_completa` → Para análisis generales
   - `kpi_por_planta` → Para reportes rápidos

2. **Guardar Preguntas Frecuentes**
   - Dale nombres descriptivos
   - Guárdalas en colecciones organizadas

3. **Configurar Filtros en Dashboards**
   - Filtro por fecha (rango)
   - Filtro por país
   - Filtro por planta
   - Filtro por producto

4. **Actualización Automática**
   - En cada tarjeta → "Auto-refresh" cada 1-5 minutos

5. **Compartir Dashboards**
   - Crear enlaces públicos (con precaución)
   - Enviar por email periódicamente

### ❌ DON'Ts (Evitar)

1. **No hacer queries muy pesadas sin filtros**
   - Siempre limita por fecha (últimos 7-30 días)

2. **No dar permisos de Admin a todos**
   - Solo 1-2 administradores

3. **No olvidar documentar**
   - Agrega descripciones a tus preguntas
   - Explica qué mide cada KPI

4. **No ignorar datos anómalos**
   - Si ves picos raros, investiga en PgAdmin

---

## 🚀 EJERCICIO PRÁCTICO PARA EMPEZAR

### Challenge 1: Dashboard de 5 Minutos

Crea un dashboard que muestre:

1. ✅ Total de bultos producidos HOY
2. 📊 Gráfico de barras: Producción por país
3. 📈 Porcentaje de calidad (gauge/medidor)
4. 🏭 Tabla: Top 3 plantas más productivas

**Meta**: Completarlo en menos de 5 minutos usando el editor visual de Metabase.

### Challenge 2: Análisis Avanzado

Crea una pregunta SQL personalizada:

```sql
SELECT 
  p.nombre AS pais,
  t.nombre AS turno,
  COUNT(*) AS total_producido,
  ROUND(AVG(peso_real), 2) AS peso_promedio,
  ROUND(100.0 * SUM(CASE WHEN estado = 'OK' THEN 1 ELSE 0 END) / COUNT(*), 2) AS porcentaje_ok
FROM produccion_global pg
JOIN maquinas m ON pg.id_maquina = m.id
JOIN plantas pl ON m.id_planta = pl.id
JOIN paises p ON pl.id_pais = p.id
JOIN turnos t ON pg.id_turno = t.id
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY p.nombre, t.nombre
ORDER BY total_producido DESC;
```

Guárdala como "Análisis de Producción por País y Turno (7 días)".

---

## 📞 SOLUCIÓN DE PROBLEMAS

### Problema 1: Metabase no carga

**Solución**:
```bash
# Ver logs
docker-compose logs metabase

# Reiniciar solo Metabase
docker-compose restart metabase

# Si persiste, recrear
docker-compose down
docker-compose up -d
```

### Problema 2: No hay datos en Metabase

**Verificar**:
1. ¿El simulador está corriendo?
   ```bash
   docker-compose logs simulator
   ```

2. ¿Hay datos en PostgreSQL?
   - Abrir PgAdmin (localhost:8080)
   - Conectar a `production_db`
   - Query: `SELECT COUNT(*) FROM produccion_global;`

### Problema 3: Dashboard muy lento

**Optimizar**:
1. Agregar filtros de fecha
2. Usar vistas pre-agregadas
3. Limitar resultados (TOP 10, TOP 100, etc.)

---

## 🎓 RECURSOS ADICIONALES

- **Documentación oficial**: https://www.metabase.com/docs/latest/
- **Ejemplos de dashboards**: https://www.metabase.com/learn/
- **SQL para PostgreSQL**: https://www.postgresql.org/docs/15/tutorial-sql.html

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

- [ ] Docker Compose funcionando
- [ ] Base de datos inicializada (ver PgAdmin)
- [ ] Simulador generando datos
- [ ] Metabase configurado
- [ ] Al menos 2 usuarios creados (Admin + Viewer)
- [ ] Dashboard básico creado
- [ ] Filtros configurados
- [ ] Auto-refresh activado
- [ ] Colecciones organizadas

---

**¡ÉXITO EN TU PROYECTO! 🚀**

Si necesitas ayuda adicional, revisa los logs con `docker-compose logs -f`