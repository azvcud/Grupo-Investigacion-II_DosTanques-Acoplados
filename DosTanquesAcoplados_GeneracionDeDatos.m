% ------------------------------------------------------------
% Simulación no lineal de dos tanques acoplados
% Generación de data_SISO con TODOS los datos (SIN DIVISIÓN)
% Datos listos para System Identification Toolbox (IDENT)
% Modificado para un único intervalo [V_min, V_max]
% ------------------------------------------------------------
clear; clc; close all;
%% Parámetros físicos del sistema (SI)
A  = 28e-4;       % Área del tanque [m^2]
a1 = 0.071e-4;    % Área del orificio del tanque 1 [m^2]
a2 = a1;          % Área del orificio del tanque 2 [m^2]
g  = 9.81;        % Gravedad [m/s^2]
eta = 0.5e-5;     % Eficiencia de la bomba [m^3/(s·V)]
%% Tiempo de simulación y condiciones iniciales
dt = 0.05;           % paso de tiempo [s]
t = 0:dt:600;       % vector temporal (600 segundos)
n = numel(t);
h0 = [0.0; 0.0];    % niveles iniciales [m]
noise_input_std = 0;   % Desviación estándar del ruido en la entrada [V]
noise_output_std = 0; % Desviación estándar del ruido en la salida [m] 
%% Parámetros para la Generación de Señales de Variación (ÚNICO INTERVALO)
t_cambio = 20; % Tiempo cada cuánto cambia el escalón (en segundos)
V_min = 0;   % Voltaje mínimo permitido
V_max = 2;   % Voltaje máximo permitido
% El rango de variación será V_max - V_min.
% Para que la señal sea un buen 'Multistep', V_min debe ser > 0 o V_max > V_min.

%% Definición del sistema ODE
odefun = @(t, h, ufun) [
    -(a1/A)*sqrt(2*g*max(h(1),0)) + (eta * ufun(t)) / A;
     (a1/A)*sqrt(2*g*max(h(1),0)) - (a2/A)*sqrt(2*g*max(h(2),0))
];
opts = odeset('RelTol',1e-6, 'AbsTol',1e-8);
% 
%% Bucle de Simulación y Creación de iddata (SIMPLIFICADO)

% --- Generación de la Señal de Entrada de Pasos Aleatorios ---
t_cambio_indices = 1 : round(t_cambio / dt) : n;

% Establecer la semilla del generador de números aleatorios
rng(100, 'twister');

% Generar valores aleatorios uniformemente distribuidos entre [0, 1]
% y luego escalarlos al rango [V_min, V_max]
rango_V = V_max - V_min;
valores_escalones = V_min + rango_V * rand(1, numel(t_cambio_indices)); 

u_ideal = zeros(size(t));
for i = 1:numel(t_cambio_indices)
    idx_start = t_cambio_indices(i);
    if i == numel(t_cambio_indices)
        idx_end = n;
    else
        idx_end = t_cambio_indices(i+1) - 1;
    end
    u_ideal(idx_start:idx_end) = valores_escalones(i);
end

% Adición de ruido a la entrada y saturación
ruido_input = noise_input_std * randn(size(t)); 

u_ruidosa = u_ideal + ruido_input;
u_ruidosa = max(min(u_ruidosa, V_max), V_min);

u_fun = @(tt) interp1(t, u_ruidosa, tt, 'linear', 'extrap');

% --- Integración Numérica (Datos Totales) ---
% Se usa t como vector de tiempo de muestreo, ode45 lo discretiza internamente.
[t_out, h_out] = ode45(@(tt, hh) odefun(tt, hh, u_fun), t, h0, opts);
h1_sim = h_out(:,1);
h2_sim = h_out(:,2);

% Muestrear la entrada ruidosa a los instantes de tiempo de la salida
u_sampled = interp1(t, u_ruidosa, t_out, 'linear', 'extrap');

% --- ADICIÓN DE RUIDO EN LA SALIDA ---
ruido_h1 = noise_output_std * randn(size(h1_sim));
ruido_h2 = noise_output_std * randn(size(h2_sim));

% Se asegura que la altura sea >= 0 (V_min aquí actúa como 0 para la altura)
h1_ruidosa = max(h1_sim + ruido_h1, 0); 
h2_ruidosa = max(h2_sim + ruido_h2, 0);

% =======================================================
% --- CREACIÓN DE OBJETOS iddata CON DATOS TOTALES ---
% =======================================================

% 1. h1 - Datos Totales
data_y1_full = iddata(h1_ruidosa, u_sampled, dt);
data_y1_full.OutputName = {'h1'}; data_y1_full.OutputUnit = {'m'};
data_y1_full.InputName  = {'Voltaje'}; data_y1_full.InputUnit  = {'V'};
data_y1_full.Tstart = 0;
data_y1_full.Name = ['FullData_h1_VRange_', strrep(num2str(V_min), '.', 'p'), 'to', strrep(num2str(V_max), '.', 'p')];

% 2. h2 - Datos Totales
data_y2_full = iddata(h2_ruidosa, u_sampled, dt);
data_y2_full.OutputName = {'h2'}; data_y2_full.OutputUnit = {'m'};
data_y2_full.InputName  = {'Voltaje'}; data_y2_full.InputUnit  = {'V'};
data_y2_full.Tstart = 0;
data_y2_full.Name = ['FullData_h2_VRange_', strrep(num2str(V_min), '.', 'p'), 'to', strrep(num2str(V_max), '.', 'p')];

% --- Visualización ---
figure('Name', ['Simulación: Rango V = [', num2str(V_min), ', ', num2str(V_max), '] V | Datos Totales']);

subplot(3,1,1);
plot(t_out, u_sampled, 'b', 'LineWidth', 1.3); 
xlabel('Tiempo [s]'); ylabel('Voltaje [V]');
title(['Entrada (u): Pasos Aleatorios en [', num2str(V_min), ', ', num2str(V_max), ']']); grid on;

subplot(3,1,2);
plot(t_out, h1_ruidosa*100, 'r', 'LineWidth', 1.5, 'DisplayName', 'h1'); 
xlabel('Tiempo [s]'); ylabel('Altura h1 [cm]');
title('Salida h1: Datos Totales'); legend('show'); grid on;

subplot(3,1,3);
plot(t_out, h2_ruidosa*100, 'r', 'LineWidth', 1.5, 'DisplayName', 'h2'); 
xlabel('Tiempo [s]'); ylabel('Altura h2 [cm]');
title('Salida h2: Datos Totales'); legend('show'); grid on;

disp('---');
disp('Simulación y conversión a iddata con DATOS TOTALES completadas.');
disp(['h1 Datos Totales creados: ', data_y1_full.Name]);
disp(['h2 Datos Totales creados: ', data_y2_full.Name]);