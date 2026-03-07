# Runa — Roadmap

Runa es un editor de documentos por bloques multiplataforma.
Cada documento es un archivo `.runa` compuesto de bloques de Markdown, escritura a mano, imágenes, PDF y código.

---

## Fase 0 — Fundamentos `v0.1`

> Base técnica antes de features visibles.

- [ ] Estructura del proyecto Flutter + arquitectura de bloques
- [ ] Definir formato `.runa` (JSON con schema versionado)
- [ ] Modelo de datos: `Document`, `Block` (sealed class), `InkBlock`, `MarkdownBlock`
- [ ] Persistencia local básica (leer/escribir `.runa`)
- [ ] Directorio por defecto: `~/Runa/`

---

## Fase 1 — Home & navegación `v0.2`

> La pantalla de inicio y el sistema de archivos.

- [ ] Pantalla de inicio
  - [ ] Abrir carpeta del sistema → listar `.runa` en sidebar
  - [ ] Crear nuevo archivo `.runa` en carpeta abierta o ruta por defecto
  - [ ] Crear subcarpetas en ruta por defecto
  - [ ] Archivos recientes
- [ ] Sidebar con árbol de archivos
- [ ] Navegación entre documentos abiertos (tabs)

---

## Fase 2 — Editor de bloques core `v0.3 – v0.4`

> El corazón del producto.

- [ ] Documento como lista vertical de bloques
- [ ] **MarkdownBlock**
  - [ ] Editor raw + preview toggle (o side-by-side)
  - [ ] Auto-crecimiento del bloque al escribir
- [ ] **InkBlock** (canvas de escritura a mano)
  - [ ] Trazos con suavizado Catmull-Rom / Bézier
  - [ ] Soporte de `pressure` si el dispositivo lo permite
  - [ ] Altura fija configurable o libre
- [ ] Insertar bloque entre bloques existentes
- [ ] Reordenar bloques (drag & drop)
- [ ] Redimensionar bloques manualmente
- [ ] Seleccionar y borrar bloques

---

## Fase 3 — Imágenes y PDF `v0.5`

> Bloques de contenido externo anotable.

- [ ] **ImageBlock**: abrir imagen y dibujar/anotar encima (capa de tinta sobre la imagen)
- [ ] **PDFBlock**: cada página del PDF es un bloque
  - [ ] Renderizar páginas del PDF
  - [ ] Capa de tinta sobre cada página
  - [ ] Scroll entre páginas como bloques consecutivos
- [ ] Importar PDF e imágenes desde el filesystem

---

## Fase 4 — Markdown avanzado `v0.6`

> Potenciar el bloque de texto.

- [ ] Soporte matemático: LaTeX inline (`$...$`) y bloque (`$$...$$`) con `flutter_math_fork`
- [ ] Syntax highlighting en bloques de código
- [ ] Soporte completo de GFM: tablas, checkboxes, footnotes
- [ ] Exportar documento a PDF (Markdown renderizado + trazos)

---

## Fase 5 — Rust core `v0.7`

> Cuando Flutter puro ya no alcanza.

- [ ] Integrar `flutter_rust_bridge`
- [ ] Serialización/deserialización eficiente del `.runa` en Rust
- [ ] Compresión de trazos (delta encoding de puntos)
- [ ] OCR básico offline de InkBlocks (`tract` + modelo ONNX)
- [ ] Exportación a PDF de alta calidad desde Rust

---

## Fase 6 — Plugins `v1.0`

> Extensibilidad del editor.

- [ ] Definir API de plugins (nuevo tipo de bloque, comandos, sidebar panels)
- [ ] Sistema de carga dinámica (Dart isolates o WASM plugins)
- [ ] Plugin manager en settings
- [ ] Primeros plugins oficiales: diagramas (Mermaid), tabla avanzada

---

## Fase 7 — Typst `v1.x`

> El compilador de Typst está escrito en Rust, por lo que la integración via `flutter_rust_bridge` es viable.

- [ ] **TypstBlock**: editor raw + render en tiempo real via Rust
- [ ] Soporte de math, figuras y bibliografía
- [ ] Exportar bloque o documento completo a PDF via Typst

---

## Fase 8 — Jupyter & código `v1.x`

> Notebooks híbridos con ejecución de código.

- [ ] **CodeBlock**: editor con syntax highlighting
- [ ] Protocolo Jupyter kernel (conexión a kernel local: Python, Julia, etc.)
  - [ ] Ejecutar bloque y mostrar output (texto, imágenes, plots)
- [ ] Output renderizado inline bajo el bloque
- [ ] Gestión de kernels en sidebar

---

## Fase 9 — LLM Autocomplete `v1.x`

> Asistencia inteligente integrada en el editor.

- [ ] Protocolo LSP custom para Runa (o extensión del LSP estándar)
- [ ] Autocompletado en MarkdownBlock y TypstBlock via LLM local (Ollama) o API
- [ ] Comandos inline: `/mejorar`, `/resumir`, `/continuar`
- [ ] OCR → Markdown de InkBlock via LLM multimodal
- [ ] Sugerencias contextuales según el contenido del documento

---

## Resumen de versiones

| Versión | Contenido                          |
|---------|------------------------------------|
| `v0.1`  | Fundamentos y formato `.runa`      |
| `v0.2`  | Home + navegación de archivos      |
| `v0.3`  | Editor: MarkdownBlock + InkBlock   |
| `v0.4`  | Reordenar, insertar, redimensionar |
| `v0.5`  | PDF e imágenes anotables           |
| `v0.6`  | Math, GFM completo, export PDF     |
| `v0.7`  | Rust core + OCR                    |
| `v1.0`  | Sistema de plugins                 |
| `v1.x`  | Typst, Jupyter, LLM                |
