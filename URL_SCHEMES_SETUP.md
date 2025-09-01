# 🔧 **URL Schemes Setup Manual - Xcode**

## ⚠️ **Si "URL Schemes" no aparece en la búsqueda:**

### **📋 Método 1: Pestaña Info**

1. **Ve a la pestaña "Info"** (al lado de "Signing & Capabilities")
2. **Busca "URL types" en la lista**
3. **Si NO existe:**
   - **Clic derecho** en la lista → **"Add Row"**  
   - **Selecciona "URL types"**
4. **Expande "URL types"**
5. **Clic en "+"** para agregar Item 0
6. **Expande "Item 0"**
7. **En "URL Schemes" agrega:**
   - **Item 0**: `finanzas-personales-app`
   - **Clic "+"** y agrega **Item 1**: `com.googleusercontent.apps.849478111086-n6gnvkleq4dgkl21vlq6mmoq24hj19p6`

### **📋 Método 2: Build Settings**

1. **Ve a "Build Settings"**
2. **Busca "URL Types"**
3. **Agrega los mismos valores**

### **📋 Método 3: Verificación Manual**

**Los URL schemes DEBEN aparecer así en Info.plist:**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>finanzas-personales-app</string>
            <string>com.googleusercontent.apps.849478111086-n6gnvkleq4dgkl21vlq6mmoq24hj19p6</string>
        </array>
    </dict>
</array>
```

---

## ✅ **Una vez configurado:**

1. **Compila**: `Cmd + R`
2. **Prueba Google Sign-In**  
3. **Debería regresar a la app** después del login

---

## 🚨 **Si sigue fallando:**

**Verifica que GoogleService-Info.plist esté en el Navigator izquierdo de Xcode.**
