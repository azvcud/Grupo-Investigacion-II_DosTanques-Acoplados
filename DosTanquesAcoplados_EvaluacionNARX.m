%% ------------------------------------------------------------
% Evaluación de Modelos idnlarx (nlarx_h1 y nlarx_h2)
% ------------------------------------------------------------
clc;
close all;

% NOTA: Asegúrate de que las variables nlarx_h1, nlarx_h2, data_y1_full, 
% y data_y2_full estén cargadas en el Workspace de MATLAB.
% El archivo de sesión del System Identification tiene por nombre:
% sesion_NARX_h1_h2.sid

disp('---');
disp('Calculando y graficando el Error Absoluto de la predicción (en cm)...');

%% 1. Tanque h1: Cálculo y Gráfica del Error Absoluto
[h_compare_h1, fit_h1] = compare(data_y1_full, nlarx_h1);

% Obtener los valores de la salida real y la salida predicha
y_real_h1 = data_y1_full.OutputData;
y_pred_h1 = h_compare_h1.OutputData;
error_h1 = (y_real_h1 - y_pred_h1) * 100;

% 1. Multiplicar por 100 para convertir a cm
error_abs_h1 = abs(y_real_h1 - y_pred_h1) * 100; 

% Generar la gráfica del Error
figure('Name', 'Error de Predicción para h1');
plot(data_y1_full.SamplingInstants, error_h1, 'r', 'LineWidth', 1);
title(['Error Absoluto (h1) | Fit: ', num2str(fit_h1, '%.2f'), ' %']);
xlabel('Tiempo [s]');
ylabel('Error Absoluto [cm]'); 
grid on;
ax1 = gca; 
ax1.YAxis.Exponent = 0;

disp(['Modelo nlarx_h1 (Tanque h1) - Ajuste (Fit): ', num2str(fit_h1, '%.2f'), ' %']);

% -------------------------------------------------------------------------

%% 2. Tanque h2: Cálculo y Gráfica del Error Absoluto
[h_compare_h2, fit_h2] = compare(data_y2_full, nlarx_h2);

% Obtener los valores de la salida real y la salida predicha
y_real_h2 = data_y2_full.OutputData;
y_pred_h2 = h_compare_h2.OutputData;
error_h2 = (y_real_h2 - y_pred_h2) * 100;

error_abs_h2 = abs(y_real_h2 - y_pred_h2) * 100;

% Generar la gráfica del Error Absoluto
figure('Name', 'Error de Predicción para h2');
plot(data_y2_full.SamplingInstants, error_h2, 'b', 'LineWidth', 1);
title(['Error Absoluto (h2) | Fit: ', num2str(fit_h2, '%.2f'), ' %']);
xlabel('Tiempo [s]');
ylabel('Error Absoluto [cm]');
grid on;
ax2 = gca;
ax2.YAxis.Exponent = 0;

disp(['Modelo nlarx_h2 (Tanque h2) - Ajuste (Fit): ', num2str(fit_h2, '%.2f'), ' %']);
disp('---');
disp('Dos nuevas figuras con las gráficas de Error Absoluto (en cm) han sido generadas.');

% Concatenación de todos los errores (para métricas globales)
error_full = [error_h1; error_h2];
error_full = error_full / 100;
n_total = numel(error_full);

% Concatenación de todas las salidas reales (para NRMSE)
h_full_concat = [y_real_h1; y_real_h2];

% -----------------------------------------------------------
% 2. Cálculo de Métricas de Error
% -----------------------------------------------------------

% a) MSE (Error Cuadrático Medio)
MSE = sum(error_full.^2) / n_total;

% b) RMSE (Raíz del Error Cuadrático Medio)
RMSE = sqrt(MSE);

% c) MAE (Error Absoluto Medio)
MAE = sum(abs(error_full)) / n_total;

% d) SSE (Suma del Error Cuadrático)
SSE = sum(error_full.^2);

% e) NRMSE (Error Cuadrático Medio Normalizado)
range_h = max(h_full_concat) - min(h_full_concat);

if range_h ~= 0
    NRMSE = RMSE / range_h;
else
    NRMSE = 0.0;
end

% -----------------------------------------------------------
% 3. Presentación de Resultados
% -----------------------------------------------------------
fprintf('\n--------------------------- Métricas de Error de Aproximación -------------------------------\n');
fprintf('MÉTRICAS (Sistema Global: h1 + h2)\n');
fprintf('---------------------------------------------------------------------------------------------\n');

% Mostrar valores en m y cm
fprintf('MSE (Error Cuadrático Medio global)\t\t: %f m^2 \t|(%f cm^2)\n', MSE, MSE * 100); % m^2 a cm^2: x 100^2 = x 10000
fprintf('RMSE (Raíz del Error Cuadrático Medio global)\t: %f m \t|(%f cm)\n', RMSE, RMSE * 100);
fprintf('MAE (Error Absoluto Medio global)\t\t: %f m \t|(%f cm)\n', MAE, MAE * 100);
fprintf('SSE (Suma del Error Cuadrático global)\t\t: %f m^2  |(%f cm^2)\n', SSE, SSE * 100);
fprintf('NRMSE (Error Normalizado global)\t\t: %f \t|(Adimensional)\n', NRMSE);
fprintf('---------------------------------------------------------------------------------------------\n');

% Asumiendo que 'data_y1_full' contiene el tiempo:
t_instants = data_y1_full.SamplingInstants;

% Crear una matriz de datos: [Tiempo, Error H1 (cm), Error H2 (cm)]
datos_csv = [t_instants, error_h1, error_h2];

% Guardar en CSV
writematrix(datos_csv, 'errores_narx.csv');

disp('---');
disp('Datos de Error Absoluto guardados en: errores_narx.csv');