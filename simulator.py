import os
os.environ["PGCLIENTENCODING"] = "utf-8"

import sys
import psycopg2
from psycopg2.extras import RealDictCursor
import random
import time
from datetime import datetime, timedelta
import threading

# ============================================
# CONFIGURACIÓN DE CONEXIÓN
# ============================================
DB_PARAMS = {
    "host": "postgres_db",
    "dbname": "production_data",
    "user": "admin",
    "password": "secret_password",
    "port": "5432"
}

# ============================================
# CONFIGURACIÓN DE SIMULACIÓN
# ============================================
INTERVALO_PRODUCCION = 5  # segundos entre cada producto
TASA_DEFECTOS = 0.04  # 4% de defectos
MAX_REINTENTOS_CONEXION = 10  # Reintentos de conexión inicial

# Rangos de parámetros de máquina
TEMP_RANGE = (65, 85)
HUMEDAD_RANGE = (40, 60)
VELOCIDAD_RANGE = (80, 120)

# ============================================
# FUNCIONES AUXILIARES
# ============================================

def log_mensaje(mensaje, tipo="INFO"):
    """Función mejorada de logging con timestamp"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    iconos = {
        "INFO": "ℹ️",
        "OK": "✅",
        "ERROR": "❌",
        "WARNING": "⚠️",
        "SUCCESS": "🎉"
    }
    icono = iconos.get(tipo, "📝")
    print(f"[{timestamp}] {icono} {mensaje}", flush=True)
    sys.stdout.flush()

def esperar_postgres():
    """Espera a que PostgreSQL esté listo antes de continuar"""
    log_mensaje("Esperando a que PostgreSQL esté listo...", "INFO")
    
    for intento in range(1, MAX_REINTENTOS_CONEXION + 1):
        try:
            conn = psycopg2.connect(**DB_PARAMS, connect_timeout=5)
            conn.close()
            log_mensaje("PostgreSQL está listo!", "SUCCESS")
            return True
        except psycopg2.OperationalError as e:
            log_mensaje(f"Intento {intento}/{MAX_REINTENTOS_CONEXION} - PostgreSQL no está listo aún...", "WARNING")
            if intento < MAX_REINTENTOS_CONEXION:
                time.sleep(5)
            else:
                log_mensaje(f"No se pudo conectar a PostgreSQL después de {MAX_REINTENTOS_CONEXION} intentos", "ERROR")
                log_mensaje(f"Error: {e}", "ERROR")
                return False
    return False

def obtener_turno_actual():
    """Determina el turno basado en la hora actual"""
    hora = datetime.now().hour
    if 6 <= hora < 14:
        return 1  # Mañana
    elif 14 <= hora < 22:
        return 2  # Tarde
    else:
        return 3  # Noche

def generar_codigo_operador():
    """Genera un código de operador aleatorio"""
    return f"OP-{random.randint(1000, 9999)}"

def calcular_peso_real(peso_objetivo, tolerancia):
    """Genera un peso real con distribución normal"""
    desviacion = tolerancia / 3
    peso = random.gauss(peso_objetivo, desviacion)
    return round(peso, 2)

def es_defecto(peso_real, peso_objetivo, tolerancia):
    """Determina si un bulto es defecto"""
    if abs(peso_real - peso_objetivo) > tolerancia:
        return True
    return random.random() < TASA_DEFECTOS

# ============================================
# CLASE SIMULADOR POR MÁQUINA
# ============================================

class SimuladorMaquina:
    def __init__(self, maquina_data, productos_permitidos):
        self.maquina_id = maquina_data['id']
        self.codigo = maquina_data['codigo']
        self.planta = maquina_data['planta']
        self.pais = maquina_data['pais']
        self.productos = productos_permitidos
        
        # Parámetros operativos "estables" de la máquina
        self.temp_base = random.uniform(*TEMP_RANGE)
        self.humedad_base = random.uniform(*HUMEDAD_RANGE)
        self.velocidad_base = random.randint(*VELOCIDAD_RANGE)
        
        # Contador de productos
        self.productos_generados = 0
        
    def simular_produccion(self, conn):
        """Simula la producción de un bulto"""
        try:
            # Seleccionar producto según probabilidades
            producto = random.choices(
                self.productos,
                weights=[p['probabilidad'] for p in self.productos]
            )[0]
            
            # Generar peso real
            peso_real = calcular_peso_real(
                producto['peso_objetivo'],
                producto['tolerancia']
            )
            
            # Determinar estado
            estado = 'DEFECTO' if es_defecto(
                peso_real,
                producto['peso_objetivo'],
                producto['tolerancia']
            ) else 'OK'
            
            # Parámetros de máquina con variación leve
            temperatura = round(self.temp_base + random.uniform(-2, 2), 1)
            humedad = round(self.humedad_base + random.uniform(-3, 3), 1)
            velocidad = self.velocidad_base + random.randint(-5, 5)
            
            # Insertar en base de datos
            cur = conn.cursor()
            query = """
                INSERT INTO produccion_global 
                (id_maquina, id_producto, id_turno, peso_real, estado, 
                 codigo_operador, temperatura_maquina, humedad_ambiente, velocidad_linea)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            cur.execute(query, (
                self.maquina_id,
                producto['id'],
                obtener_turno_actual(),
                peso_real,
                estado,
                generar_codigo_operador(),
                temperatura,
                humedad,
                velocidad
            ))
            conn.commit()
            cur.close()
            
            self.productos_generados += 1
            
            # Log de actividad
            icono = "✅" if estado == "OK" else "❌"
            log_mensaje(
                f"{icono} [{self.pais}] {self.codigo} | {producto['nombre'][:30]} | {peso_real}kg | {estado} | Total: {self.productos_generados}",
                "OK" if estado == "OK" else "WARNING"
            )
            
            return True
            
        except psycopg2.Error as e:
            log_mensaje(f"Error de BD en {self.codigo}: {e}", "ERROR")
            return False
        except Exception as e:
            log_mensaje(f"Error inesperado en {self.codigo}: {e}", "ERROR")
            return False

# ============================================
# FUNCIÓN PRINCIPAL
# ============================================

def cargar_configuracion(conn):
    """Carga máquinas y sus productos permitidos desde la BD"""
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    log_mensaje("Cargando configuración de máquinas...", "INFO")
    
    # Obtener todas las máquinas
    cur.execute("""
        SELECT 
            m.id, m.codigo, m.modelo,
            pl.nombre AS planta,
            p.nombre AS pais
        FROM maquinas m
        JOIN plantas pl ON m.id_planta = pl.id
        JOIN paises p ON pl.id_pais = p.id
        WHERE m.estado_actual = 'OPERATIVA'
    """)
    maquinas = cur.fetchall()
    
    log_mensaje(f"Se encontraron {len(maquinas)} máquinas operativas", "INFO")
    
    simuladores = []
    
    for maq in maquinas:
        # Obtener productos de la máquina
        cur.execute("""
            SELECT 
                pr.id, pr.codigo, pr.nombre, pr.peso_objetivo, 
                pr.tolerancia, pp.probabilidad
            FROM planta_productos pp
            JOIN productos pr ON pp.id_producto = pr.id
            JOIN plantas pl ON pp.id_planta = pl.id
            JOIN maquinas m ON m.id_planta = pl.id
            WHERE m.id = %s
        """, (maq['id'],))
        
        productos = cur.fetchall()
        
        if productos:
            simuladores.append(SimuladorMaquina(maq, productos))
            log_mensaje(f"✓ {maq['codigo']} ({maq['pais']}) - {len(productos)} productos", "INFO")
        else:
            log_mensaje(f"⚠️  Máquina {maq['codigo']} sin productos asignados", "WARNING")
    
    cur.close()
    return simuladores

def ejecutar_maquina(simulador, conn_params):
    """Ejecuta la simulación de una máquina en un thread separado"""
    log_mensaje(f"Iniciando thread para {simulador.codigo}", "INFO")
    
    # Cada thread tiene su propia conexión
    conn = None
    intentos_reconexion = 0
    max_intentos = 5
    
    while True:
        try:
            # Conectar si no hay conexión
            if conn is None or conn.closed:
                log_mensaje(f"Conectando {simulador.codigo} a la BD...", "INFO")
                conn = psycopg2.connect(**conn_params)
                intentos_reconexion = 0
            
            # Simular producción
            exito = simulador.simular_produccion(conn)
            
            if not exito:
                intentos_reconexion += 1
                if intentos_reconexion >= max_intentos:
                    log_mensaje(f"Demasiados errores en {simulador.codigo}, reiniciando conexión...", "ERROR")
                    if conn:
                        conn.close()
                    conn = None
                    intentos_reconexion = 0
                    time.sleep(10)
            
            # Variación aleatoria en el tiempo
            time.sleep(INTERVALO_PRODUCCION + random.uniform(-1, 1))
            
        except psycopg2.OperationalError as e:
            log_mensaje(f"Error de conexión en {simulador.codigo}: {e}", "ERROR")
            if conn:
                conn.close()
            conn = None
            time.sleep(10)
            
        except Exception as e:
            log_mensaje(f"Error crítico en {simulador.codigo}: {e}", "ERROR")
            time.sleep(10)

def main():
    """Función principal del simulador multinacional"""
    print("\n" + "=" * 80)
    log_mensaje("🌍 SIMULADOR DE PRODUCCIÓN MULTINACIONAL", "INFO")
    print("=" * 80)
    log_mensaje(f"⏰ Hora de inicio: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", "INFO")
    log_mensaje(f"⚙️  Intervalo de producción: {INTERVALO_PRODUCCION}s por bulto", "INFO")
    log_mensaje(f"📊 Tasa de defectos: {TASA_DEFECTOS*100}%", "INFO")
    print("=" * 80 + "\n")
    
    # Esperar a PostgreSQL
    if not esperar_postgres():
        log_mensaje("No se pudo conectar a PostgreSQL. Abortando.", "ERROR")
        sys.exit(1)
    
    # Conectar a la base de datos
    try:
        log_mensaje("Conectando a PostgreSQL...", "INFO")
        conn = psycopg2.connect(**DB_PARAMS)
        log_mensaje("Conexión exitosa!", "SUCCESS")
        
        # Verificar que las tablas existen
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM produccion_global")
        count = cur.fetchone()[0]
        log_mensaje(f"Registros actuales en produccion_global: {count}", "INFO")
        cur.close()
        
        # Cargar configuración
        simuladores = cargar_configuracion(conn)
        log_mensaje(f"✅ {len(simuladores)} máquinas cargadas y listas", "SUCCESS")
        
        if len(simuladores) == 0:
            log_mensaje("No hay máquinas para simular. Verifica la configuración de la BD.", "ERROR")
            conn.close()
            sys.exit(1)
        
        # Mostrar resumen
        print("\n" + "=" * 80)
        log_mensaje("🏭 RESUMEN DE PLANTAS ACTIVAS:", "INFO")
        print("=" * 80)
        
        paises_dict = {}
        for sim in simuladores:
            if sim.pais not in paises_dict:
                paises_dict[sim.pais] = []
            paises_dict[sim.pais].append(sim.codigo)
        
        for pais, maquinas in paises_dict.items():
            log_mensaje(f"🌎 {pais}: {len(maquinas)} máquinas - {', '.join(maquinas)}", "INFO")
        
        print("=" * 80)
        log_mensaje("🚀 Iniciando producción en todas las plantas...\n", "SUCCESS")
        
        conn.close()
        
        # Crear y lanzar threads
        threads = []
        for simulador in simuladores:
            thread = threading.Thread(
                target=ejecutar_maquina,
                args=(simulador, DB_PARAMS),
                daemon=True
            )
            thread.start()
            threads.append(thread)
            time.sleep(0.2)
        
        log_mensaje("💡 Presiona Ctrl+C para detener la simulación\n", "INFO")
        
        # Mantener el programa corriendo
        while True:
            time.sleep(1)
            
    except psycopg2.OperationalError as e:
        log_mensaje("ERROR DE CONEXIÓN A LA BASE DE DATOS:", "ERROR")
        log_mensaje(str(e), "ERROR")
        sys.exit(1)
        
    except KeyboardInterrupt:
        print("\n")
        log_mensaje("🛑 Simulación detenida por el usuario", "WARNING")
        log_mensaje(f"⏰ Hora de fin: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", "INFO")
        
    except Exception as e:
        log_mensaje(f"ERROR INESPERADO: {e}", "ERROR")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()