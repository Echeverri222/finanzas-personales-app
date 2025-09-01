# Finanzas Personales - iOS App

Una aplicación móvil para iOS desarrollada en Swift y SwiftUI que te permite gestionar tus finanzas personales de manera inteligente, con sincronización en tiempo real usando Supabase.

## 🚀 Características Principales

- **Dashboard Interactivo**: Visualización clara de ingresos, gastos, ahorros y balance neto
- **Gestión de Movimientos**: CRUD completo para transacciones financieras
- **Categorización Inteligente**: Organiza tus movimientos por categorías personalizables
- **Análisis Avanzado**: Gráficos y estadísticas para entender tus patrones de gasto
- **Filtros Flexibles**: Filtra por año, mes y categoría
- **Autenticación Segura**: Sistema de magic links vía email
- **Sincronización en la Nube**: Datos seguros y sincronizados con Supabase
- **UI Moderna**: Diseño nativo de iOS con SwiftUI

## 📋 Requisitos del Sistema

- **Xcode 15.0** o superior
- **iOS 16.0** o superior
- **Swift 5.9** o superior
- Cuenta de **Supabase** (gratuita)

## 🛠 Configuración del Proyecto

### 1. Configurar Dependencias en Xcode

1. Abre tu proyecto en Xcode
2. Ve a **File > Add Package Dependencies**
3. Agrega las siguientes dependencias:

```
https://github.com/supabase/supabase-swift
```

### 2. Configurar Supabase

1. Ve a [supabase.com](https://supabase.com) y crea una cuenta gratuita
2. Crea un nuevo proyecto
3. En tu proyecto de Supabase, ve a **Settings > API**
4. Copia tu **Project URL** y **anon public key**

### 3. Actualizar Configuración

1. Abre el archivo `Services/SupabaseClient.swift`
2. Reemplaza las siguientes líneas con tus datos reales:

```swift
private let supabaseURL = "TU_URL_DE_SUPABASE_AQUI"
private let supabaseKey = "TU_CLAVE_PUBLICA_DE_SUPABASE_AQUI"
```

### 4. Configurar Base de Datos

En el SQL Editor de Supabase, ejecuta el siguiente script para crear las tablas necesarias:

```sql
-- Crear tabla de tipos de movimiento
CREATE TABLE tipo_movimiento (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    meta DECIMAL(10,2) DEFAULT 0,
    usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de movimientos
CREATE TABLE movimientos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    importe DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    descripcion TEXT,
    id_tipo_movimiento INTEGER REFERENCES tipo_movimiento(id),
    usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar categorías por defecto (se crearán automáticamente para cada usuario)
-- Esto se puede hacer desde la app o manualmente para cada usuario

-- Habilitar RLS (Row Level Security)
ALTER TABLE tipo_movimiento ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad para tipo_movimiento
CREATE POLICY "Users can only see their own movement types" ON tipo_movimiento
    FOR ALL USING (auth.uid() = usuario_id);

-- Políticas de seguridad para movimientos
CREATE POLICY "Users can only see their own movements" ON movimientos
    FOR ALL USING (auth.uid() = usuario_id);
```

### 5. Configurar Autenticación por Email

1. En tu proyecto de Supabase, ve a **Authentication > Settings**
2. Habilita **Email** como proveedor de autenticación
3. Configura las plantillas de email si lo deseas
4. En **URL Configuration**, agrega tu esquema de URL de la app (opcional)

## 🏗 Estructura del Proyecto

```
finanzas-personales-app/
├── Models/
│   ├── Movement.swift          # Modelo de datos para movimientos
│   └── MovementType.swift      # Modelo de datos para tipos/categorías
├── Services/
│   ├── SupabaseClient.swift    # Configuración de Supabase
│   ├── AuthService.swift       # Servicio de autenticación
│   └── DatabaseService.swift   # Operaciones de base de datos
├── ViewModels/
│   └── MovementViewModel.swift # Lógica de negocio y estado
├── Views/
│   ├── ContentView.swift       # Vista principal
│   ├── AuthView.swift          # Pantalla de login
│   ├── MainTabView.swift       # Navegación principal
│   ├── DashboardView.swift     # Dashboard con estadísticas
│   ├── MovementsView.swift     # Lista de movimientos
│   ├── AddMovementView.swift   # Formulario para agregar/editar
│   ├── ChartsView.swift        # Análisis y gráficos
│   └── SettingsView.swift      # Configuración y perfil
└── Assets.xcassets/            # Recursos visuales
```

## 🎯 Funcionalidades Principales

### Dashboard
- Resumen de ingresos, gastos y ahorros del período seleccionado
- Balance neto con indicador visual
- Acciones rápidas para agregar movimientos
- Gráfico de distribución de gastos por categoría
- Lista de movimientos recientes

### Gestión de Movimientos
- Lista completa con búsqueda y filtros
- Agregar nuevos movimientos con categorización
- Editar movimientos existentes
- Eliminar movimientos con confirmación
- Filtros por año, mes y categoría

### Análisis
- Evolución mensual con gráficos de área
- Comparación ingresos vs gastos
- Distribución de gastos por categoría
- Tasa de ahorro y progreso
- Indicadores clave de rendimiento

### Configuración
- Perfil de usuario
- Gestión de categorías (próximamente)
- Metas financieras (próximamente)
- Exportación de datos (próximamente)
- Cerrar sesión seguro

## 🔄 Sincronización con Xcode

Los cambios realizados en estos archivos se reflejarán automáticamente en Xcode. Si no ves los cambios:

1. En Xcode, ve a **File > Refresh**
2. O cierra y vuelve a abrir el proyecto
3. Verifica que todos los archivos estén agregados al target

## 🚨 Solución de Problemas Comunes

### Error de compilación con Supabase
- Asegúrate de haber agregado correctamente la dependencia de Supabase
- Verifica que la versión de iOS sea 16.0 o superior

### Errores de autenticación
- Revisa que las credenciales de Supabase sean correctas
- Verifica que la autenticación por email esté habilitada en Supabase

### Problemas de base de datos
- Asegúrate de haber ejecutado el script SQL para crear las tablas
- Verifica que RLS esté habilitado y las políticas configuradas

## 📱 Próximas Funcionalidades

- [ ] Gestión avanzada de categorías
- [ ] Sistema de metas financieras
- [ ] Notificaciones push
- [ ] Exportación a CSV/PDF
- [ ] Modo offline
- [ ] Widget para iOS
- [ ] Análisis predictivo
- [ ] Compartir reportes

## 🤝 Contribuir

Si encuentras bugs o tienes sugerencias de mejora:

1. Crea un issue describiendo el problema
2. Si tienes una solución, haz un pull request
3. Incluye capturas de pantalla si es necesario

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 📞 Soporte

Si necesitas ayuda con la configuración:

- Revisa la documentación de [Supabase](https://supabase.com/docs)
- Consulta la documentación de [SwiftUI](https://developer.apple.com/documentation/swiftui)
- Abre un issue en este repositorio

---

**¡Disfruta gestionando tus finanzas de manera inteligente! 💰📱**
