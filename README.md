## Captura de dinámica no lineal de un sistema de dos tanques acoplados: Evaluación comparativa entre linealización, NLARX y PINN

**Autor:** Vanegas Cárdenas, Amir Zoleyt

---

### Descripción breve del Proyecto

Este repositorio contiene los códigos y resultados asociados con la evaluación comparativa de tres modelos diferentes utilizados para capturar la **dinámica no lineal de un sistema de dos tanques acoplados**.

El sistema de tanques acoplados es un caso de estudio fundamental en la Ingeniería de Control debido a su dinámica no lineal intrínseca, dictada por la ley de Torricelli (relación cuadrática entre el nivel del fluido y el caudal de salida)

Se comparan tres técnicas representativas de modelado de sistemas dinámicos no lineales:
1.  **Linealización en espacio de estados**.
2.  **Autorregresores exógenos no lineales (NLARX)**.
3.  **Redes neuronales informadas por la física (PINN)**.

---

### Archivos del proyecto

## Directorios

| Nombre del Directorio | Propósito |
| :--- | :--- |
| **`Imagenes del paper`** | Contiene figuras, gráficos y visualizaciones generadas a partir de las simulaciones y la evaluación de modelos, destinadas a ser incluidas en el documento de investigación (paper). |

---

## Archivos de Código Fuente y Scripts

| Archivo | Tipo | Función Principal |
| :--- | :--- | :--- |
| **`DosTanquesAcoplados_EvaluacionNARX.m`** | MATLAB Script | Script para cargar los modelos **Nonlinear ARX (NARX)** y evaluarlos contra los datos de simulación completos. |
| **`DosTanquesAcoplados_GeneracionDeDatos.m`** | MATLAB Script | Script fundamental para la simulación no lineal del sistema físico y la generación de los datos de entrada/salida (`iddata`) para la identificación. |
| **`DosTanquesAcoplados_Linealizacion.ipynb`** | Jupyter Notebook | Contiene el código Python/NumPy para la **linealización** del modelo de los tanques y la generación de sus predicciones. |
| **`DosTanquesAcoplados_PINN.ipynb`** | Jupyter Notebook | Implementación del modelo de **Physics-Informed Neural Networks (PINNs)** para la identificación no lineal del sistema. |


## Archivos de Resultados, Datos y Sesiones

| Archivo | Tipo | Contenido |
| :--- | :--- | :--- |
| **`errores_lineal.csv`** | CSV (Datos) | Vector de **errores** generados por el modelo Linealizado. |
| **`errores_narx.csv`** | CSV (Datos) | Vector de **errores** generados por el modelo NLARX. |
| **`errores_pinn.csv`** | CSV (Datos) | Vector de **errores** generados por el modelo PINN. |
| **`sesion_NARX_h1_h2.sid`** | MATLAB Session | Archivo de sesión de la **System Identification Toolbox**. Almacena los modelos identificados (`nlarx_h1`, `nlarx_h2`) y los parámetros de entrenamiento. |
