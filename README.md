
# 📱 Listora

## 🎯 Objetivo de la App

**Listora** es una aplicación móvil diseñada para facilitar la organización de compras. Permite crear listas, agregar ingredientes o productos con nombre, cantidad, unidad, precio y marcarlos como comprados. Además, ofrece funcionalidades para visualizar resúmenes de gasto, historial de compras y exportación a Excel, así como la opción de que el usuario guarde sus recetas de cocina.

## 🧩 Descripción del Logo

El logo de Listora está conformado por una lista, que representa la organización de compras, acompañada de una bolsa que simboliza el acto de adquirir productos. En conjunto, el diseño comunica de forma visual y directa la finalidad principal de la aplicación: gestionar compras de manera eficiente.

## 💡 Justificación Técnica

- **Tipo de dispositivo**: La app está pensada para iPhone, ya que es un dispositivo que el usuario lleva consigo constantemente, permitiendo acceder a la aplicación en cualquier momento.
- **Versión mínima del sistema operativo**: iOS 15.0 o superior. Esta elección asegura compatibilidad con dispositivos modernos y permite el uso de funcionalidades como Core Data, notificaciones locales y Swift Charts.
- **Orientaciones soportadas**: Solo se soporta **orientación vertical (portrait)**, con el objetivo de mantener una experiencia centrada, sencilla y cómoda para el usuario.

## 🔐 Credenciales de Acceso

Actualmente, la app **no requiere credenciales de acceso**. Todas las funcionalidades están disponibles de manera local sin autenticación, lo que permite comenzar a usar la app de forma inmediata tras su instalación.

## 🧱 Dependencias y Frameworks Utilizados

El proyecto está desarrollado en **Swift** utilizando **UIKit** y **Core Data**. Las principales dependencias y frameworks utilizados incluyen:

- **Core Data** – Para almacenamiento local de listas, ingredientes, historial y recetas.
- **Swift Charts** – Para visualización de estadísticas y datos en forma de gráficas.
- **ExcelExport / Codable** – Para generar archivos exportables con la información registrada (usando formatos como CSV o Excel).
- **UIKit** – Para la construcción de la interfaz de usuario con Storyboards y programación manual.
