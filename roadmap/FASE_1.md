# Fase 1 — Home & navegación `v0.2`

> La pantalla de inicio, el explorador de archivos y la navegación entre documentos.
> Primer código de UI real. Toda la lógica de estado va en Riverpod.

---

## 1. Infraestructura de estado (Application layer) ✅

- [x] `WorkspaceState` — estado global del workspace:
  - [x] `openedDirectory: Directory?` — carpeta activa en el sidebar
  - [x] `openedDocuments: List<OpenedDocument>` — documentos en tabs
  - [x] `activeDocumentId: String?` — tab activo
  - [x] `recentPaths: List<String>` — historial de rutas recientes
- [x] `WorkspaceNotifier` (Riverpod `Notifier`):
  - [x] `openDirectory(String path)` — carga árbol de archivos
  - [x] `openDocument(String path)` — abre un `.runa` y lo añade a tabs
  - [x] `closeDocument(String id)` — cierra un tab
  - [x] `setActiveDocument(String id)`
  - [x] `createDocument(String directory, String name)` — crea `.runa` en blanco y lo abre
  - [x] `createSubdirectory(String parent, String name)`
- [x] `RecentFilesService`:
  - [x] Persistir `recentPaths` en JSON local (`runa_recents.json`)
  - [x] Limitar a 20 entradas; deduplicar
- [x] `FileSystemService`:
  - [x] `listRunaFiles(String directory)` — lista `.runa` recursivamente
  - [x] `watchDirectory(String directory)` — stream de cambios con `dart:io`
  - [x] `createDirectory(String path)`
- [x] Tests unitarios de `WorkspaceNotifier` con fakes del repositorio (45 tests)
- [x] Tests de `RecentFilesService` (añadir, deduplicar, cap 20, persistencia) (12 tests)
- [x] Tests de `FileSystemService` (listar, crear, watch) (10 tests)

---

## 2. Pantalla de inicio (`HomeScreen`) ✅

- [x] Layout principal: sidebar izquierdo + área central
- [x] Estado inicial (sin carpeta abierta):
  - [x] Botón "Abrir carpeta" → `FilePicker.platform.getDirectoryPath()`
  - [x] Botón "Nuevo documento" → crea `.runa` en `~/Runa/` (`sin_titulo_<timestamp>.runa`)
  - [x] Sección "Recientes" con lista de rutas recientes clicables
  - [x] Ruta inexistente → indicador visual en rojo + botón de eliminar
- [x] Estado con carpeta abierta:
  - [x] Sidebar placeholder: header con nombre de carpeta + lista de archivos
  - [x] Área central: `DocumentEditorPlaceholder` o mensaje de "selecciona un documento"
- [x] `DocumentEditorPlaceholder`: nombre, count de bloques, botón Guardar
- [x] `WorkspaceNotifier.removeRecentPath()` añadido
- [x] `main.dart` con `ProviderScope` + `HomeScreen` + tema Material 3
- [x] `file_picker ^8.1.7` añadido
- [x] Tests de widget (10): welcome state, recents, folder open, editor placeholder

---

## 3. Sidebar — árbol de archivos ✅

- [x] `FileSidebarWidget`:
  - [x] Muestra nombre de la carpeta raíz abierta en el header
  - [x] Lista archivos `.runa` y subcarpetas en árbol expandible (flat-list con depth)
  - [x] Icono diferenciado: `folder`/`folder_open` para carpetas, `description_outlined` para archivos
  - [x] Resalta el archivo del tab activo (`ListTile.selected`)
  - [x] Click en archivo → `WorkspaceNotifier.openDocument(path)`
  - [x] Ordenar: carpetas primero, luego archivos; ambos alfabéticamente
- [x] Menú contextual (click derecho con `onSecondaryTapDown`):
  - [x] Sobre archivo: "Abrir", "Renombrar", "Eliminar"
  - [x] Sobre carpeta: "Nuevo documento aquí", "Nueva subcarpeta", "Renombrar", "Eliminar"
- [x] Botón "+" en el header con `MenuAnchor`: "Nuevo documento" y "Nueva subcarpeta"
- [x] Watch del directorio (`watchDirectory` recursive) → recarga automática
- [x] `FileSystemService` extendido: `listDirectory`, `renameEntry`, `deleteFile`, `deleteDirectory`
- [x] `WorkspaceNotifier` extendido: `renameDocument`, `deleteDocument`, `deleteDirectory`
- [x] Tests de widget (12): listing, icons, tapping, expand/collapse, highlighting, nested indent
- [x] Tests unitarios notifier (13 nuevos): removeRecentPath, renameDocument, deleteDocument, deleteDirectory

---

## 4. Crear nuevo documento

- [ ] Flujo "Nuevo documento":
  - [ ] Si hay carpeta abierta → preguntar nombre (dialog inline o text field en sidebar)
  - [ ] Si no hay carpeta abierta → guardar en `~/Runa/` con nombre por defecto
  - [ ] Validación: nombre no vacío, no contiene caracteres inválidos, no existe ya un archivo con ese nombre
  - [ ] Crear documento vacío (sin bloques) con `DocumentRepository.save()`
  - [ ] Abrir el documento recién creado en un nuevo tab
- [ ] Flujo "Nueva subcarpeta":
  - [ ] Dialog inline con text field para el nombre
  - [ ] Validación equivalente a la de documentos
  - [ ] Crear directorio con `dart:io`
- [ ] Tests:
  - [ ] Creación exitosa → documento aparece en sidebar y tab activo
  - [ ] Nombre duplicado → error mostrado sin crear el archivo
  - [ ] Nombre vacío → botón de confirmar deshabilitado

---

## 5. Navegación entre documentos (tabs)

- [ ] `DocumentTabBar`:
  - [ ] Muestra un tab por documento abierto con nombre del archivo
  - [ ] Tab activo resaltado visualmente
  - [ ] Botón "×" en cada tab para cerrarlo
  - [ ] Si hay cambios sin guardar → indicador (punto o asterisco en el nombre)
  - [ ] Scroll horizontal si hay muchos tabs
- [ ] Comportamiento al cerrar tab:
  - [ ] Sin cambios → cierra directamente
  - [ ] Con cambios → dialog de confirmación: "Guardar", "Descartar", "Cancelar"
- [ ] Keyboard shortcuts (registrar con `Shortcuts` + `Actions`):
  - [ ] `Ctrl+W` → cerrar tab activo
  - [ ] `Ctrl+Tab` / `Ctrl+Shift+Tab` → navegar entre tabs
  - [ ] `Ctrl+N` → nuevo documento
  - [ ] `Ctrl+O` → abrir carpeta
- [ ] Tests:
  - [ ] Abrir dos documentos → dos tabs visibles
  - [ ] Click en tab → cambia documento activo
  - [ ] Cerrar tab sin cambios → desaparece directamente
  - [ ] Cerrar tab con cambios → muestra dialog

---

## 6. Archivos recientes

- [ ] `RecentFilesWidget` en la `HomeScreen` (visible cuando no hay carpeta abierta):
  - [ ] Lista los últimos 10 documentos abiertos con:
    - Nombre del archivo
    - Ruta completa (truncada si es larga)
    - Fecha de última apertura
  - [ ] Click → abre el documento directamente (o muestra error si ya no existe)
  - [ ] Botón "Limpiar recientes"
- [ ] Actualizar lista de recientes cada vez que se abre un documento
- [ ] Tests:
  - [ ] Abrir documento lo añade a recientes
  - [ ] Duplicados no se insertan (se mueve al tope)
  - [ ] Archivo eliminado → mostrar estado de error al intentar abrir

---

## 7. Placeholder del editor

> El editor real se implementa en Fase 2. Aquí solo necesitamos un placeholder funcional.

- [ ] `DocumentEditorPlaceholder`:
  - [ ] Muestra el nombre del documento abierto
  - [ ] Muestra el número de bloques que contiene
  - [ ] Botón "Guardar" que hace `DocumentRepository.save()` (sin cambios reales)
- [ ] Asegurarse de que la navegación carga y muestra el documento correcto

---

## Entregable de la Fase 1

Al finalizar esta fase, la app debe:

- [ ] Compilar y ejecutar en Linux (ventana nativa)
- [ ] Permitir abrir una carpeta del sistema y ver su árbol de `.runa`
- [ ] Crear un nuevo documento `.runa` vacío desde la UI
- [ ] Crear subcarpetas desde la UI
- [ ] Abrir múltiples documentos en tabs y navegar entre ellos
- [ ] Mostrar archivos recientes y reabrirlos con un click
- [ ] Cerrar un tab con confirmación si hay cambios pendientes
- [ ] Todos los tests pasando (`flutter test`)

---

## Dependencias nuevas a añadir

| Paquete | Uso |
|---|---|
| `file_picker` | Diálogo nativo para seleccionar carpeta |
| `shared_preferences` | Persistir archivos recientes |

---

## Orden sugerido de implementación

```
1. RecentFilesService + tests
2. FileSystemService (list + watch) + tests
3. WorkspaceState + WorkspaceNotifier + tests
4. DocumentTabBar (UI) + tests de widget
5. FileSidebarWidget (UI) + tests de widget
6. HomeScreen con estado inicial (recientes + botones) + tests
7. Flujos de creación (documento + subcarpeta) + tests
8. Keyboard shortcuts
9. DocumentEditorPlaceholder
10. Smoke test end-to-end manual en Linux
```
