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

- [ ] Diseñar schema JSON del formato `.runa`:
  ```json
  {
    "version": "0.1",
    "id": "<uuid>",
    "created_at": "<iso8601>",
    "updated_at": "<iso8601>",
    "blocks": [ ... ]
  }
  ```
- [ ] Definir schema de cada tipo de bloque en JSON:
  - [ ] `MarkdownBlock`: `{ "type": "markdown", "id": "", "content": "" }`
  - [ ] `InkBlock`: `{ "type": "ink", "id": "", "strokes": [], "height": 200.0 }`
- [ ] Definir schema de un trazo de tinta (`Stroke`):
  - [ ] Lista de puntos `{ "x", "y", "pressure", "timestamp" }`
  - [ ] Propiedades del trazo: `color`, `width`, `tool`
- [ ] Documentar el schema con comentarios / JSON Schema formal (`runa.schema.json`)
- [ ] Definir política de versionado: campo `version` en el root, migración futura explícita
- [ ] Escribir tests de validación del schema con documentos de ejemplo

---

## 3. Modelo de datos

- [ ] `Block` — sealed class base con `id` y `type`
  - [ ] `MarkdownBlock extends Block` — campo `content: String`
  - [ ] `InkBlock extends Block` — campos `strokes: List<Stroke>`, `height: double`
- [ ] `Stroke` — value object con `points`, `color`, `width`, `tool`
- [ ] `StrokePoint` — value object con `x`, `y`, `pressure`, `timestamp`
- [ ] `Document` — value object con `id`, `version`, `createdAt`, `updatedAt`, `blocks`
- [ ] Generar `copyWith`, `==`, `hashCode`, `toJson`/`fromJson` con `freezed`
- [ ] Tests unitarios de cada modelo:
  - [ ] Serialización a JSON y deserialización (round-trip)
  - [ ] `copyWith` correcto
  - [ ] Igualdad estructural

---

## 4. Persistencia local

- [ ] `DocumentRepository` — interfaz abstracta:
  - [ ] `Future<Document> load(String path)`
  - [ ] `Future<void> save(Document doc, String path)`
  - [ ] `Future<List<String>> listDocuments(String directory)`
- [ ] `LocalDocumentRepository` — implementación con `dart:io`:
  - [ ] Leer archivo `.runa` → parsear JSON → `Document`
  - [ ] `Document` → serializar JSON → escribir archivo `.runa`
  - [ ] Manejar errores: archivo no encontrado, JSON inválido, versión incompatible
- [ ] Tests de integración de persistencia:
  - [ ] Guardar y releer un documento con múltiples bloques
  - [ ] Documento con `InkBlock` con trazos reales
  - [ ] Archivo corrupto → error controlado

---

## 5. Directorio por defecto `~/Runa/`

- [ ] `DefaultDirectoryService`:
  - [ ] Resolver `~/Runa/` usando `path_provider` + `path`
  - [ ] Crear el directorio si no existe al primer arranque
  - [ ] Exponer `Future<Directory> getDefaultDirectory()`
- [ ] Tests:
  - [ ] El directorio se crea si no existía
  - [ ] El path devuelto es correcto en cada plataforma

---

## Entregable de la Fase 0

Al finalizar esta fase, el proyecto debe:

- [ ] Compilar sin errores en Linux (objetivo primario)
- [ ] Tener tests unitarios e integración pasando (`flutter test`)
- [ ] Ser capaz de crear, guardar y cargar un `.runa` con `MarkdownBlock` e `InkBlock` via código (sin UI)
- [ ] Tener un `main.dart` mínimo que ejercite el ciclo completo como smoke test
- [ ] Tener `runa.schema.json` documentado en `/docs/`

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
