# Fase 1 — Home & navegación `v0.2`

> La pantalla de inicio, el explorador de archivos y la navegación entre documentos.
> Primer código de UI real. Toda la lógica de estado va en Riverpod.

---

## 1. Infraestructura de estado (Application layer) ✅

- [X] `WorkspaceState` — estado global del workspace:
  - [X] `openedDirectory: Directory?` — carpeta activa en el sidebar
  - [X] `openedDocuments: List<OpenedDocument>` — documentos en tabs
  - [X] `activeDocumentId: String?` — tab activo
  - [X] `recentPaths: List<String>` — historial de rutas recientes
- [X] `WorkspaceNotifier` (Riverpod `Notifier`):
  - [X] `openDirectory(String path)` — carga árbol de archivos
  - [X] `openDocument(String path)` — abre un `.runa` y lo añade a tabs
  - [X] `closeDocument(String id)` — cierra un tab
  - [X] `setActiveDocument(String id)`
  - [X] `createDocument(String directory, String name)` — crea `.runa` en blanco y lo abre
  - [X] `createSubdirectory(String parent, String name)`
- [X] `RecentFilesService`:
  - [X] Persistir `recentPaths` en JSON local (`runa_recents.json`)
  - [X] Limitar a 20 entradas; deduplicar
- [X] `FileSystemService`:
  - [X] `listRunaFiles(String directory)` — lista `.runa` recursivamente
  - [X] `watchDirectory(String directory)` — stream de cambios con `dart:io`
  - [X] `createDirectory(String path)`
- [X] Tests unitarios de `WorkspaceNotifier` con fakes del repositorio (45 tests)
- [X] Tests de `RecentFilesService` (añadir, deduplicar, cap 20, persistencia) (12 tests)
- [X] Tests de `FileSystemService` (listar, crear, watch) (10 tests)

---

## 2. Pantalla de inicio (`HomeScreen`) ✅

- [X] Layout principal: sidebar izquierdo + área central
- [X] Estado inicial (sin carpeta abierta):
  - [X] Botón "Abrir carpeta" → `FilePicker.platform.getDirectoryPath()`
  - [X] Botón "Nuevo documento" → crea `.runa` en `~/Runa/` (`sin_titulo_<timestamp>.runa`)
  - [X] Sección "Recientes" con lista de rutas recientes clicables
  - [X] Ruta inexistente → indicador visual en rojo + botón de eliminar
- [X] Estado con carpeta abierta:
  - [X] Sidebar placeholder: header con nombre de carpeta + lista de archivos
  - [X] Área central: `DocumentEditorPlaceholder` o mensaje de "selecciona un documento"
- [X] `DocumentEditorPlaceholder`: nombre, count de bloques, botón Guardar
- [X] `WorkspaceNotifier.removeRecentPath()` añadido
- [X] `main.dart` con `ProviderScope` + `HomeScreen` + tema Material 3
- [X] `file_picker ^8.1.7` añadido
- [X] Tests de widget (10): welcome state, recents, folder open, editor placeholder

---

## 3. Sidebar — árbol de archivos ✅

- [X] `FileSidebarWidget`:
  - [X] Muestra nombre de la carpeta raíz abierta en el header
  - [X] Lista archivos `.runa` y subcarpetas en árbol expandible (flat-list con depth)
  - [X] Icono diferenciado: `folder`/`folder_open` para carpetas, `description_outlined` para archivos
  - [X] Resalta el archivo del tab activo (`ListTile.selected`)
  - [X] Click en archivo → `WorkspaceNotifier.openDocument(path)`
  - [X] Ordenar: carpetas primero, luego archivos; ambos alfabéticamente
- [X] Menú contextual (click derecho con `onSecondaryTapDown`):
  - [X] Sobre archivo: "Abrir", "Renombrar", "Eliminar"
  - [X] Sobre carpeta: "Nuevo documento aquí", "Nueva subcarpeta", "Renombrar", "Eliminar"
- [X] Botón "+" en el header con `MenuAnchor`: "Nuevo documento" y "Nueva subcarpeta"
- [X] Watch del directorio (`watchDirectory` recursive) → recarga automática
- [X] `FileSystemService` extendido: `listDirectory`, `renameEntry`, `deleteFile`, `deleteDirectory`
- [X] `WorkspaceNotifier` extendido: `renameDocument`, `deleteDocument`, `deleteDirectory`
- [X] Tests de widget (12): listing, icons, tapping, expand/collapse, highlighting, nested indent
- [X] Tests unitarios notifier (13 nuevos): removeRecentPath, renameDocument, deleteDocument, deleteDirectory

---

## 4. Crear nuevo documento

- [X] Flujo "Nuevo documento":
  - [X] Si hay carpeta abierta → preguntar nombre (dialog inline o text field en sidebar)
  - [X] Si no hay carpeta abierta → guardar en `~/Runa/` con nombre por defecto
  - [X] Validación: nombre no vacío, no contiene caracteres inválidos, no existe ya un archivo con ese nombre
  - [X] Crear documento vacío (sin bloques) con `DocumentRepository.save()`
  - [X] Abrir el documento recién creado en un nuevo tab
- [X] Flujo "Nueva subcarpeta":
  - [X] Dialog inline con text field para el nombre
  - [X] Validación equivalente a la de documentos
  - [X] Crear directorio con `dart:io`
- [X] Tests:
  - [X] Creación exitosa → documento aparece en sidebar y tab activo
  - [X] Nombre duplicado → error mostrado sin crear el archivo
  - [X] Nombre vacío → botón de confirmar deshabilitado

---

## 5. Navegación entre documentos (tabs)

- [X] `DocumentTabBar`:
  - [X] Muestra un tab por documento abierto con nombre del archivo
  - [X] Tab activo resaltado visualmente
  - [X] Botón "×" en cada tab para cerrarlo
  - [X] Si hay cambios sin guardar → indicador (punto o asterisco en el nombre)
  - [X] Scroll horizontal si hay muchos tabs
- [X] Comportamiento al cerrar tab:
  - [X] Sin cambios → cierra directamente
  - [X] Con cambios → dialog de confirmación: "Guardar", "Descartar", "Cancelar"
- [X] Keyboard shortcuts (registrar con `Shortcuts` + `Actions`):
  - [X] `Ctrl+W` → cerrar tab activo
  - [X] `Ctrl+Tab` / `Ctrl+Shift+Tab` → navegar entre tabs
  - [X] `Ctrl+N` → nuevo documento
  - [X] `Ctrl+O` → abrir carpeTests:
    - [X] Abrir dos documentos → dos tabs visibles
    - [X] Click en tab → cambia documento activo
    - [X] Cerrar tab sin cambios → desaparece directamente
    - [X] Cerrar tab con cambios → muestra dialog

---

## 6. Archivos recientes

- [X] `RecentFilesWidget` en la `HomeScreen` (visible cuando no hay carpeta abierta):
  - [X] Lista los últimos 10 documentos abiertos con:
    - Nombre del archivo
    - Ruta completa (truncada si es larga)
    - Fecha de última apertura
  - [X] Click → abre el documento directamente (o muestra error si ya no existe)
  - [X] Botón "Limpiar recientes"
- [X] Actualizar lista de recientes cada vez que se abre un documento
- [X] Tests:
  - [X] Abrir documento lo añade a recientes
  - [X] Duplicados no se insertan (se mueve al tope)
  - [X] Archivo eliminado → mostrar estado de error al intentar abrir

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

| Paquete                | Uso                                      |
| ---------------------- | ---------------------------------------- |
| `file_picker`        | Diálogo nativo para seleccionar carpeta |
| `shared_preferences` | Persistir archivos recientes             |

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
