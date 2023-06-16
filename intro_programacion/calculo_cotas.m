## TP1
clear all;

datos_primarias = load("primarias_estatales.dat");
datos_esquinas = load("cotas_esquinas.dat");
p = 2;
INDICE_COTAS = columns(datos_primarias)+1;
INDICE_X = 3;
INDICE_Y = 4;

# Calculo de cotas de cada escuela
function peso = factor_de_peso(posicion_escuela, posicion_esquina_actual, p)
  aux = posicion_esquina_actual - posicion_escuela;
  distancia = (aux(1,1)^2 + aux(1,2)^2)^(1/2);
  peso = 1/distancia^p;
endfunction

function cota_estimada = idw(posicion_escuela, esquinas_relevamiento, p)
  cota_estimada = 0;
  sumatoria_pesos_esquinas = 0;
  sumatoria_superior = 0;

  for j = 1:rows(esquinas_relevamiento)
    pos_esquina_actual = esquinas_relevamiento(j, 2:3);
    peso_esquina = factor_de_peso(posicion_escuela, pos_esquina_actual, p);

    sumatoria_pesos_esquinas = sumatoria_pesos_esquinas + peso_esquina;

    sumatoria_superior = sumatoria_superior + peso_esquina * esquinas_relevamiento(j, 1);
  endfor

  cota_estimada = sumatoria_superior / sumatoria_pesos_esquinas;
endfunction

for i = 1:rows(datos_primarias)
  pos_escuela_actual = datos_primarias(i, INDICE_X:INDICE_Y);

  cota_estimada = idw(pos_escuela_actual, datos_esquinas, 2);

  datos_primarias(i, INDICE_COTAS) = cota_estimada;
endfor

save cotas_primarias.dat datos_primarias -ascii;

###################
# Partidos
# 1 - Berazategui
# 2 - Florencio Varela
# 3 - Quilmes
clear datos_primarias datos_esquinas;

BERAZATEGUI = 1;
FLORENCIO_VARELA = 2;
QUILMES = 3;

datos_primarias = load("cotas_primarias.dat");
datos_esquinas = load("cotas_esquinas.dat");


# Escuela más alta y más baja
escuela_mas_baja = 0;
escuela_mas_alta = 0;
partido_escuela_baja = 0;
partido_escuela_alta = 0;
cota_mayor = 0;
cota_menor = 0;

for i = 1:rows(datos_primarias)
  cota_actual = datos_primarias(i, INDICE_COTAS);
  if(cota_actual > cota_mayor)
    cota_mayor = cota_actual;
    escuela_mas_alta = datos_primarias(i, 1);
    partido_escuela_alta = datos_primarias(i,2);
  else if((cota_menor == 0) || (cota_actual < cota_menor))
    cota_menor = cota_actual;
    escuela_mas_baja = datos_primarias(i, 1);
    partido_escuela_baja = datos_primarias(i,2);
  endif
  endif
endfor


disp("---- La escuela mas alta de la cuenca con su cota: ----");
disp(num2str(escuela_mas_alta));
disp(num2str(cota_mayor));
disp(num2str(partido_escuela_alta));disp("");
disp("---- La escuela mas baja de la cuenca con su cota: ----");
disp(num2str(escuela_mas_baja));
disp(num2str(cota_menor));
disp(num2str(partido_escuela_baja));disp("");


# 2 Escuelas mas altas y mas bajas de c/partido con su cota
escuelas_berazategui = zeros(4, columns(datos_primarias));
escuelas_varela = zeros(4, columns(datos_primarias));
escuelas_quilmes = zeros(4, columns(datos_primarias));

for i = 1:rows(datos_primarias)
  cota_actual = datos_primarias(i, INDICE_COTAS);

  switch(datos_primarias(i, 2))
  case BERAZATEGUI
    for j = 1:2
      if(cota_actual > escuelas_berazategui(j, INDICE_COTAS))
        if(j==1)
          escuelas_berazategui(2, :) = escuelas_berazategui(1, :);
        endif
        escuelas_berazategui(j, :) = datos_primarias(i, :);
        break;
      endif
    endfor
  case FLORENCIO_VARELA
    for j = 1:2
      if(cota_actual > escuelas_varela(j, INDICE_COTAS))
        if(j==1)
          escuelas_varela(2, :) = escuelas_varela(1, :);
        endif
        escuelas_varela(j, :) = datos_primarias(i, :);
        break;
      endif
    endfor
  case QUILMES
    for j = 1:2
      if(cota_actual > escuelas_quilmes(j, INDICE_COTAS))
        if(j==1)
          escuelas_quilmes(2, :) = escuelas_quilmes(1, :);
        endif
        escuelas_quilmes(j, :) = datos_primarias(i, :);
        break;
      endif
    endfor
  endswitch
endfor

for i = 1:rows(datos_primarias)
  cota_actual = datos_primarias(i, INDICE_COTAS);

  switch(datos_primarias(i, 2))
  case BERAZATEGUI
    for j = 3:4
      if((escuelas_berazategui(j, INDICE_COTAS) == 0) || (cota_actual < escuelas_berazategui(j, INDICE_COTAS)))
        if(j == 3)
          escuelas_berazategui(j+1, :) = escuelas_berazategui(j, :);
        endif

        escuelas_berazategui(j, :) = datos_primarias(i, :);
        break;
      endif
    endfor
  case FLORENCIO_VARELA
    for j = 3:4
      if((escuelas_varela(j, INDICE_COTAS) == 0) || (cota_actual < escuelas_varela(j, INDICE_COTAS)))
        if(j == 3)
          escuelas_varela(j+1, :) = escuelas_varela(j, :);
        endif

        escuelas_varela(j, :) = datos_primarias(i, :);
        break;
      endif
    endfor
  case QUILMES
    for j = 3:4
      if((escuelas_quilmes(j, INDICE_COTAS) == 0) || (cota_actual < escuelas_quilmes(j, INDICE_COTAS)))
        if(j == 3)
          escuelas_quilmes(j+1, :) = escuelas_quilmes(j, :);
        endif

        escuelas_quilmes(j, :) = datos_primarias(i, :);
        break;
      endif
    endfor
  endswitch
endfor

save escuelas_berazategui.txt escuelas_berazategui;
save escuelas_quilmes.txt escuelas_quilmes;
save escuelas_florencio_varela.txt escuelas_varela;

# cantidad escuelas por partido
cant_escuelas_por_partido = [BERAZATEGUI, 0; FLORENCIO_VARELA, 0; QUILMES, 0];
for i = 1:rows(datos_primarias)
  switch(datos_primarias(i, 2))
  case BERAZATEGUI
    cant_escuelas_por_partido(1, 2) = cant_escuelas_por_partido(1, 2) + 1;
  case FLORENCIO_VARELA
    cant_escuelas_por_partido(2, 2) = cant_escuelas_por_partido(2, 2) + 1;
  case QUILMES
    cant_escuelas_por_partido(3, 2) = cant_escuelas_por_partido(3, 2) + 1;
  endswitch
endfor

disp("---- Cantidad de escuelas por partido ----");
disp("En Berazategui:");
disp(num2str(cant_escuelas_por_partido(1,2)));disp("");
disp("En Florencio Varela:");
disp(num2str(cant_escuelas_por_partido(2,2)));disp("");
disp("En Quilmes");
disp(num2str(cant_escuelas_por_partido(3,2)));disp("");

# Grafico de dispersion
scatter(datos_esquinas(:, 2), datos_esquinas(:, 3), 1, datos_esquinas(:, 1), 'fill');
daspect([1 1]);
hold on;
scatter(datos_primarias(:, 3), datos_primarias(:, 4), 20, datos_primarias(:, INDICE_COTAS), 'r');
daspect([1 1]);
colorbar('title', 'Valor de la cota', 'fontsize', 6);
colormap(rainbow);
set(gca, 'YTickLabel', []);
set(gca, 'XTickLabel', []);
title('Cotas de esquinas y escuelas', 'fontsize', 6);
legend('Esquinas', 'Escuelas');

print -djpeg figura1.jpg;

# Recalcular cotas de escuelas altas y bajas por partido
cotas_escuelas_recalculadas = [escuelas_berazategui; escuelas_varela; escuelas_quilmes];
INDICE_X = 3;
INDICE_Y = 4;

for i=1:rows(cotas_escuelas_recalculadas)
  cotas_escuelas_recalculadas(i, INDICE_COTAS) = idw(cotas_escuelas_recalculadas(i, INDICE_X:INDICE_Y), datos_esquinas, 3);
endfor

save cotas_recalculadas.txt cotas_escuelas_recalculadas;


