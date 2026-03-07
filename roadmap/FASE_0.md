# Fase 0 — Fundamentos `v0.1`

> Base técnica antes de features visibles. Sin UI real, solo cimientos sólidos.

---

## 1. Estructura del proyecto Flutter

- [X] Crear proyecto Flutter con soporte multiplataforma (Linux, macOS, Windows)
- [x] Definir arquitectura de capas:
  - `domain/` — modelos de datos puros (sin dependencias de Flutter)
  - `data/` — persistencia, serialización
  - `application/` — lógica de negocio, casos de uso
  - `presentation/` — widgets, providers/blocs
- [x] Configurar `analysis_options.yaml` con reglas estrictas (strict-casts/inference/raw-types + lints adicionales)
- [x] Configurar `pubspec.yaml` con dependencias base:
  - [x] `freezed` + `freezed_annotation` (sealed classes y value objects)
  - [x] `json_serializable` + `json_annotation` (serialización del formato `.runa`)
  - [x] `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` (gestión de estado)
  - [x] `path_provider` (rutas del sistema de archivos)
  - [x] `path` (manipulación de paths)
  - [x] `uuid` (generación de IDs)
- [x] Configurar `build_runner` y scripts de generación de código
- [x] Configurar `flutter_test` y estructura de carpetas para tests (`test/domain/`, `test/data/`, `test/application/`)

---

## 2. Formato `.runa`

- [x] Diseñar schema JSON del formato `.runa`:
  ```json
  {
    "version": "0.1",
    "id": "<uuid>",
    "created_at": "<iso8601>",
    "updated_at": "<iso8601>",
    "blocks": [ ... ]
  }
  ```
- [x] Definir schema de cada tipo de bloque en JSON:
  - [x] `MarkdownBlock`: `{ "type": "markdown", "id": "", "content": "" }`
  - [x] `InkBlock`: `{ "type": "ink", "id": "", "strokes": [], "height": 200.0 }`
- [x] Definir schema de un trazo de tinta (`Stroke`):
  - [x] Lista de puntos `{ "x", "y", "pressure", "timestamp" }`
  - [x] Propiedades del trazo: `color` (#RRGGBBAA), `width`, `tool` (pen/pencil/marker/eraser)
- [x] Documentar el schema con comentarios / JSON Schema formal (`docs/runa.schema.json`)
- [x] Definir política de versionado: campo `version` en el root, migración futura explícita
- [x] Escribir tests de validación del schema con documentos de ejemplo (38 tests, `test/domain/schema_validation_test.dart`)

---

## 3. Modelo de datos

- [x] `Block` — sealed class con discriminador `type` vía `@Freezed(unionKey: 'type')`
  - [x] `MarkdownBlock` — campo `content: String`
  - [x] `InkBlock` — campos `strokes: List<Stroke>`, `height: double`
- [x] `Stroke` — value object con `points`, `color` (#RRGGBBAA), `width`, `tool` (`StrokeTool` enum)
- [x] `StrokePoint` — value object con `x`, `y`, `pressure`, `timestamp`
- [x] `Document` — value object con `id`, `version`, `createdAt`, `updatedAt`, `blocks`
- [x] Generar `copyWith`, `==`, `hashCode`, `toJson`/`fromJson` con `freezed` + `json_serializable`
- [x] Tests unitarios de cada modelo (100 tests pasando):
  - [x] Serialización a JSON y deserialización (round-trip)
  - [x] `copyWith` correcto
  - [x] Igualdad estructural

---

## 4. Persistencia local

- [x] `DocumentRepository` — interfaz abstracta (`abstract interface class`):
  - [x] `Future<Document> load(String path)`
  - [x] `Future<void> save(Document doc, String path)`
  - [x] `Future<List<String>> listDocuments(String directory)`
  - [x] Excepciones selladas: `DocumentNotFoundException`, `DocumentParseException`, `DocumentVersionException`
- [x] `LocalDocumentRepository` — implementación con `dart:io`:
  - [x] Leer archivo `.runa` → parsear JSON → `Document`
  - [x] `Document` → serializar JSON pretty-printed → escribir archivo `.runa`
  - [x] Manejar errores: archivo no encontrado, JSON inválido, versión incompatible
- [x] Tests de integración de persistencia (26 tests):
  - [x] Guardar y releer un documento con múltiples bloques
  - [x] Documento con `InkBlock` con trazos reales
  - [x] Archivo corrupto → error controlado
  - [x] Versión desconocida → `DocumentVersionException` con detalle
  - [x] `listDocuments`: filtrado `.runa`, orden alfabético, paths absolutos

---

## 5. Directorio por defecto `~/Runa/`

- [x] `DefaultDirectoryService`:
  - [x] Resolver `~/Runa/` usando `path` + `Platform.environment` (Linux: `$HOME`, Windows: `%USERPROFILE%`)
  - [x] Crear el directorio si no existe al primer arranque (`dir.create(recursive: true)`)
  - [x] Exponer `Future<Directory> getDefaultDirectory()`
  - [x] `homeOverride` para testabilidad sin tocar el home real
- [x] Tests (10 tests en `test/data/default_directory_service_test.dart`):
  - [x] El directorio se crea si no existía
  - [x] El path devuelto es correcto (`<home>/Runa`, absoluto)
  - [x] Idempotencia (llamar dos veces no lanza)
  - [x] Integración con `LocalDocumentRepository`

---

## Entregable de la Fase 0

Al finalizar esta fase, el proyecto debe:

- [x] Compilar sin errores en Linux (objetivo primario)
- [x] Tener tests unitarios e integración pasando (`flutter test`) — 137 tests
- [x] Ser capaz de crear, guardar y cargar un `.runa` con `MarkdownBlock` e `InkBlock` via código (sin UI)
- [x] Tener un `main.dart` mínimo que ejercite el ciclo completo como smoke test
- [x] Tener `runa.schema.json` documentado en `/docs/`

---

## Orden sugerido de implementación

```
1. Setup proyecto + dependencias + analysis_options
2. Definir schema JSON + runa.schema.json
3. Modelos de datos (freezed) + tests unitarios
4. Serialización JSON (json_serializable) + round-trip tests
5. DefaultDirectoryService
6. LocalDocumentRepository + tests de integración
7. main.dart smoke test
```
