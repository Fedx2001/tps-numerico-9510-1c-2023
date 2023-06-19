clear all;

function datos_balance = iterar_mes(vn, on, dn, h, dia_inicial, dia_final, numero_mes)
  # Datos
  caudales = load("caudales_mensuales.dat"); # m^3/s
  kbd_0 = 0.1; # 1/día
  ka = 0.01; # 1/día
  ko2 = 1.4; # g^2/m^6
  dbo_e = 20; # g/m^3
  od_e = 2; # g/m^3
  od_s = 9; # g/m^3
  # 20 -> 100%
  # 10 -> 50%

  # Obtengo los caudales y les cambio las unidades a m^3/dia

  datos_balance = zeros(dia_final-dia_inicial+1, 3);

  qe1 = 86400 * caudales(numero_mes, 1);
  qs1 = 86400 * caudales(numero_mes, 2);

  qe2 = qe1;
  qs2 = qs1;

  for i = 1:dia_final-dia_inicial+1
    if(i == dia_final-dia_inicial+1 && numero_mes != 12)
      qe2 = 86400 * caudales(numero_mes+1, 1); # qe(tn+1)
      qs2 = 86400 * caudales(numero_mes+1, 2); # qs(tn+1)
    endif

    if(numero_mes == 12 && i == dia_final-dia_inicial+1)
      qe2 = 86400 * caudales(1, 1);
      qs2 = 86400 * caudales(1, 2);
    endif

    q1v = h*(qe1 - qs1);
    q2v = h*(qe2 - qs2);

    kbd1 = kbd_0 * (on.^2 / (on.^2 + ko2));
    g1 = ka * (od_s - on);
    p1 = kbd1 * dn;

    q1o = h*(((qe1 * od_e - qs1 * on)/vn) + g1 - p1);
    q1d = h*(((qe1 * dbo_e - qs1 * dn)/vn) - p1);

    kbd2 = kbd_0 * ((on + q1o).^2 / ((on + q1o).^2 + ko2));
    g2 = ka * (od_s - (on + q1o));
    p2 = kbd2 * (dn + q1d);

    q2o = h*(((qe2 * od_e - qs2 * (on + q1o))/(vn + q1v)) + g2 - p2);
    q2d = h*(((qe2 * od_e - qs2 * (on + q1o))/(vn + q1v)) - p2);

    datos_balance(i, 1) = vn + ((1/2) .* (q1v + q2v));
    datos_balance(i, 2) = on + ((1/2) .* (q1o + q2o));
    datos_balance(i, 3) = dn + ((1/2) .* (q1d + q2d));

    vn = datos_balance(i, 1);
    on = datos_balance(i, 2);
    dn = datos_balance(i, 3);
  endfor
endfunction

function bal_anual = iterar_12_meses(v0, o0, d0, h)
  cantidad_datos = round(365.*(1/h));
  bal_anual = [zeros(cantidad_datos, 1), zeros(cantidad_datos, 1), zeros(cantidad_datos, 1)];

  for i = 1:12
    switch(i)
    case 1
      bal_anual(1:round(31.*1/h), :) = iterar_mes(v0, o0, d0, h, 1, round(31 .* 1/h), i);
    case 2
      bal_anual(round(31*1/h)+1:round(59.*1/h), :) = iterar_mes(bal_anual(round(31.*1/h), 1), bal_anual(round(31.*1/h), 2), bal_anual(round(31.*1/h), 3), h, round(31.*1/h)+1, round(59.*1/h), i);
    case 3
      bal_anual(round(59.*1/h)+1:round(90.*1/h), :) = iterar_mes(bal_anual(round(59.*1/h), 1), bal_anual(round(59.*1/h), 2), bal_anual(round(59.*1/h), 3), h, round(59.*1/h)+1, round(90.*1/h), i);
    case 4
      bal_anual(round(90*1/h)+1:round(112.*1/h), :) = iterar_mes(bal_anual(round(90.*1/h), 1), bal_anual(round(90.*1/h), 2), bal_anual(round(90.*1/h), 3), h, round(90*1/h)+1, round(112.*1/h), i);
    case 5
      bal_anual(round(112*1/h)+1:round(144.*1/h), :) = iterar_mes(bal_anual(round(112.*1/h), 1), bal_anual(round(112.*1/h), 2), bal_anual(round(112.*1/h), 3), h, round(112*1/h)+1, round(144.*1/h), i);
    case 6
      bal_anual(round(144*1/h)+1:round(175.*1/h), :) = iterar_mes(bal_anual(round(144.*1/h), 1), bal_anual(round(144.*1/h), 2), bal_anual(round(144.*1/h), 3), h, round(144*1/h)+1, round(175.*1/h), i);
    case 7
      bal_anual(round(175*1/h)+1:round(207.*1/h), :) = iterar_mes(bal_anual(round(175.*1/h), 1), bal_anual(round(175.*1/h), 2), bal_anual(round(175.*1/h), 3), h, round(175*1/h)+1, round(207.*1/h), i);
    case 8
      bal_anual(round(207*1/h)+1:round(239.*1/h), :) = iterar_mes(bal_anual(round(207.*1/h), 1), bal_anual(round(207.*1/h), 2), bal_anual(round(207.*1/h), 3), h, round(207*1/h)+1, round(239.*1/h), i);
    case 9
      bal_anual(round(239*1/h)+1:round(270.*1/h), :) = iterar_mes(bal_anual(round(239.*1/h), 1), bal_anual(round(239.*1/h), 2), bal_anual(round(239.*1/h), 3), h, round(239*1/h)+1, round(270.*1/h), i);
    case 10
      bal_anual(round(270*1/h)+1:round(302.*1/h), :) = iterar_mes(bal_anual(round(270.*1/h), 1), bal_anual(round(270.*1/h), 2), bal_anual(round(270.*1/h), 3), h, round(270*1/h)+1, round(302.*1/h), i);
    case 11
      bal_anual(round(302*1/h)+1:round(333.*1/h), :) = iterar_mes(bal_anual(round(302.*1/h), 1), bal_anual(round(302.*1/h), 2), bal_anual(round(302.*1/h), 3), h, round(302*1/h)+1, round(333.*1/h), i);
    case 12
      bal_anual(round(333*1/h)+1:round(365.*(1/h)), :) = iterar_mes(bal_anual(round(333.*1/h), 1), bal_anual(round(333.*1/h), 2), bal_anual(round(333.*1/h), 3), h, round(333*1/h)+1, round(365.*(1/h)), i);
    endswitch
  endfor
endfunction

h = 1; #en dias
v0 = 264.98 * (10.^6); # V0 obtenido por ajuste, y expresado en (m^3)
o0 = 0; # OD0 = OD0
d0 = 0; # DBO0 = DBO0

rungekutta_paso_diario = iterar_12_meses(v0, o0, d0, h);

h = 0.5;

rungekutta_paso_medio_dia = iterar_12_meses(v0, o0, d0, h);

h = 7;

rungekutta_paso_semanal = iterar_12_meses(v0, o0, d0, h);
et_rungekutta_semanal = abs(rungekutta_paso_semanal(:, 2:3) - rungekutta_paso_medio_dia(14:14:730, 2:3));
et_rungekutta_diario = abs(rungekutta_paso_diario(:, 2:3) - rungekutta_paso_medio_dia(2:2:730, 2:3));

rungekutta_paso_diario(2:366, :) = rungekutta_paso_diario(1:365, :); # desplazo los datos calculados
rungekutta_paso_diario(1, :) = [v0, o0, d0]; # coloco las condiciones iniciales en la matriz


# Graficos de concentracion con paso Diario
plot(0:365, rungekutta_paso_diario(:, 2));
hold on;
plot(0:365, rungekutta_paso_diario(:, 3));
legend("OD", "DBO");
title("Concentración de OD y DBO simulado en un año");
xlabel ("t (dias)");
ylabel ("C(t)");
hold off;

print -djpeg rungekutta_od_minimo_4.jpg;

# Grafico con paso semanal
plot(1:52, rungekutta_paso_semanal(:, 2)); # grafico et OD
hold on;
plot(1:52, rungekutta_paso_semanal(:, 3)); # grafico et DBO
legend("OD", "DBO");
title("Concentración de OD y DBO estimada con paso semanal");
xlabel ("t (semanas)");
ylabel ("C(t)");
hold off;

print -djpeg rungekutta_anual_semanal.jpg;


