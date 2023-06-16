# no puedo arrancar el script con function
clear all;

#Arma la matriz de coeficientes para las ecuaciones de la viga
#segun la cantidad de nodos, n.
function matriz = generar_matriz_viga(n)
  matriz = zeros(n+1);

  for (i = 1:n+1)
    if(i == 1)
      matriz(i,1) = 1;
    elseif(i == 2)
      matriz(i,1) = -4;
      matriz(i,2) = 5;
      matriz(i,3) = -4;
      matriz(i,4) = 1;
    elseif (i > 2 && i < n)
      matriz(i,i-2) = 1;
      matriz(i,i-1) = -4;
      matriz(i,i) = 6;
      matriz(i,i+1) = -4;
      matriz(i,i+2) = 1;
    elseif (i == n)
      matriz(i,(n+1)-3) = 1;
      matriz(i,(n+1)-2) = -4;
      matriz(i,(n+1)-1) = 5;
      matriz(i,n+1) = -4;
    elseif(i == n+1)
      matriz(i,n+1) = 1;
    endif
  endfor

  matriz = matriz(2:n, 2:n);
endfunction

# Armado del vector b
function b = generar_b(n, L, EI)
  b = zeros(n+1, 1);

  for i=1:n-1
    x = i * (L/n);
    q = 2 + 4 * (x - x^2);
    f = (q/EI) * (L/n)^4;
    b(i+1,1) = f;
  endfor
endfunction

# i fila, j columna, k paso
# mik = aik/akk
# aij(k+1) = aij(k) - mik * akj(k)
# j hasta n
# i hasta n
# Recibe una matriz extendida con b y la dimension de la matriz sin extender
function matriz_triangulada = triangular_matriz(matriz_extendida, n)

  for k = 1:n-1
    for i = k+1:n
      m = matriz_extendida(i, k) / matriz_extendida(k, k);

      matriz_extendida(i, k) = 0;

      for j = k+1:n+1
        matriz_extendida(i, j) = matriz_extendida(i, j) - m * matriz_extendida(k, j);
      endfor

    endfor

  endfor

  matriz_triangulada = matriz_extendida;
endfunction

# xi = (bi - sumatoria(k=i+1, n) uik * xk) / uii
# A es la matrix extendida con b, A|b
# Recibe la matriz triangulada y extendida con b
function solucion = susticion_inversa(A)
  solucion = zeros(rows(A), 1);

  for i = rows(A):-1:1
    sumatoria = 0;

    for k = i+1:columns(A)-1
      sumatoria = sumatoria + A(i, k) * solucion(k, 1);
    endfor

    solucion(i, 1) = (A(i, columns(A)) - sumatoria) / A(i, i);
  endfor

endfunction

function soulcion = eliminacion_gaussiana(A, b, n)
  matriz_extendida = A;
  matriz_extendida(:, n) = b;

  matriz_triangulada = triangular_matriz(matriz_extendida, n-1);
  soulcion = susticion_inversa(matriz_triangulada);
endfunction

# Los errores se corresponden de la siguiente forma:
# e1 -> ek-1, e2 -> ek, e3 -> ek+1
function orden_convergencia = calcular_orden_convergencia(e1, e2, e3)
  orden_convergencia = (log(e3) - log(e2)) / (log(e2) - log(e1));
endfunction

# La matriz es la matriz reducida, tolerancia 0,01
function x_solucion = jacobi(matriz, tolerancia, x_inicial, b)
  x_actual = x_inicial; #xk
  x_solucion = zeros(rows(matriz), 1); #xk+1
  k = 1;

  #Calculo D (matriz que contiene la diagonal de A)
  D=diag(diag(matriz));
  #Calculo L (matríz diagonal inferior, sin la diagonal)
  L=-tril(matriz, -1); %La opc -1 elimina la diagonal
  #Calculo U (matríz diagonal superior, sin la diagonal)
  U=-triu(matriz, 1);
  #Calculo T (matriz de iteracion de Jacobi)
  T=inv(D)*(L+U);

  radio_espectral = max(abs(eig(T)));

  if(radio_espectral > 1)
    disp('Jacobi Diverge');
    disp(['Radio espectral: ' mat2str(radio_espectral)]);
    return;
  endif

  error_relativo = 0; # error entre soluciones sucesivas
  error_anterior = 0; # error abs de xk-1
  error_actual = 0; # error abs de xk
  error_siguiente = 0; # error abs de xk+1

  while(error_relativo > tolerancia || k == 1)
    k = k + 1;

    x_actual = x_solucion;

    for i = 1:rows(matriz)
    sumatoria = 0;

    for j = 1:columns(matriz)
      if(j != i)
        sumatoria = sumatoria + matriz(i, j) * x_actual(j, 1); #aij * xj(k)
      endif
    endfor

    # xi(k+1) = (-sumatoria + bi) / aii
    x_solucion(i, 1) = (b(i, 1) - sumatoria) / matriz(i, i);

    endfor

    error_relativo = norm(x_actual - x_solucion) / norm(x_actual);
    error_anterior = error_actual; # error abs de xk-1
    error_actual = error_siguiente; # error abs de xk
    error_siguiente = norm(x_actual - x_solucion); # error abs de xk+1
  endwhile

endfunction


function x_solucion = gauss_seidel(matriz, tolerancia, x_inicial, b)

  x_actual = x_inicial; #xk
  x_solucion = zeros(rows(matriz), 1); #xk+1
  k = 1;

  error_relativo = 0; # error entre soluciones sucesivas
  error_anterior = 0; # error abs de xk-1
  error_actual = 0; # error abs de xk
  error_siguiente = 0; # error abs de xk+1

  while(error_relativo > tolerancia || k == 1)
    k = k + 1;

    for i = 1:rows(matriz)
      sumatoria = 0;

      for j = 1:i
        if(j != i)
          sumatoria = sumatoria + matriz(i, j) * x_solucion(j, 1); # aij * xj(k+1)
        endif
      endfor

      for j = i+1:columns(matriz)
        if(j != i)
          sumatoria = sumatoria + matriz(i, j) * x_actual(j, 1); # aij * xj(k)
        endif
      endfor

      # xi(k+1) = (-sumatoria + bi) / aii
      x_solucion(i, 1) = (b(i, 1) - sumatoria) / matriz(i, i);
    endfor

    error_relativo = norm(x_actual - x_solucion) / norm(x_actual);
    error_anterior = error_actual; # error abs de xk-1
    error_actual = error_siguiente; # error abs de xk
    error_siguiente = norm(x_actual - x_solucion); # error abs de xk+1
    x_actual = x_solucion;
  endwhile

  disp('-- Método de Gauss-Seidel --');
  disp(['Orden de convergencia: ' mat2str(calcular_orden_convergencia(error_anterior, error_actual, error_siguiente))]);
  disp(['Iteraciones: ' mat2str(k)]);

endfunction

# Parametros para la viga
N = 100;
L = 1;
EI = 1;

# Tolerancia de metodos indirectos
tolerancia = 0.00001;

matriz_reducida = generar_matriz_viga(N);
b = generar_b(N, L, EI);

solucion_elim_gauss = zeros(N+1, 1);

#disp('---- Ejecucion de Eliminacion Gaussiana ----');
#tic;
#solucion_elim_gauss(2:N, 1) = eliminacion_gaussiana(matriz_reducida, b(2:N, 1), N);
#toc;

solucion_gs = zeros(N+1, 1);
solucion_jacobi = zeros(N+1, 1);

for i = 2:N
  solucion_gs(i, 1) = 0.03;
endfor

disp('---- Ejecucion de Jacobi ----');
tic;
solucion_jacobi(2:N, 1) = jacobi(matriz_reducida, tolerancia, solucion_jacobi(2:N, 1), b(2:N, 1));
toc;

disp('---- Ejecucion de Gauss-Seidel ----');
tic;
solucion_gs(2:N, 1) = gauss_seidel(matriz_reducida, tolerancia, solucion_gs(2:N, 1), b(2:N, 1));
toc;

plot(1:N+1, solucion_elim_gauss(1:N+1, 1));
hold on;
plot(1:N+1, solucion_gs(1:N+1, 1));
title('Deformación de la viga con N = 10', 'fontsize', 12);
xlabel('Nodo xi', 'fontsize', 12);
ylabel('Deformación', 'fontsize', 12);
legend('Eliminacion de Gauss', 'Gauss-Seidel');

print -djpeg soluciones_n.jpg;

hold off;

# Ensayos de sensibilidad
tolerancia = 0.0001;

# EI 1.0
EI = 1;
matriz_reducida = generar_matriz_viga(N);
b = generar_b(N, L, EI);

solucion_elim_gauss = zeros(N+1, 1);

disp('---- Elim Gauss EI 1.0 ----');
tic;
solucion_elim_gauss(2:N, 1) = eliminacion_gaussiana(matriz_reducida, b(2:N, 1), N);
toc;

solucion_gs_n = zeros(N+1, 1);
solucion_jacobi = zeros(N+1, 1);

for i = 2:N
  solucion_gs_n(i, 1) = 0.03;
endfor

disp('---- Ejecucion de Gauss-Seidel 1.0 ----');
tic;
solucion_gs_n(2:N, 1) = gauss_seidel(matriz_reducida, tolerancia, solucion_gs_n(2:N, 1), b(2:N, 1));
toc;

plot(1:N+1, solucion_elim_gauss(1:N+1, 1));
hold on;
plot(1:N+1, solucion_gs_n(1:N+1, 1));
hold on;

#EI 1.1
EI = 1.1;
matriz_reducida = generar_matriz_viga(N);
b = generar_b(N, L, EI);

solucion_elim_gauss = zeros(N+1, 1);

disp('---- Elim Gauss EI 1.1 ----');
tic;
solucion_elim_gauss(2:N, 1) = eliminacion_gaussiana(matriz_reducida, b(2:N, 1), N);
toc;

solucion_gs_ar = zeros(N+1, 1);
solucion_jacobi = zeros(N+1, 1);

for i = 2:N
  solucion_gs_ar(i, 1) = 0.03;
endfor


disp('---- Ejecucion de Gauss-Seidel 1.1 ----');
tic;
solucion_gs_ar(2:N, 1) = gauss_seidel(matriz_reducida, tolerancia, solucion_gs_ar(2:N, 1), b(2:N, 1));
toc;
plot(1:N+1, solucion_elim_gauss(1:N+1, 1));
hold on;
plot(1:N+1, solucion_gs_ar(1:N+1, 1));
hold on;

# EI 0.9
EI = 0.9;
matriz_reducida = generar_matriz_viga(N);
b = generar_b(N, L, EI);

solucion_elim_gauss = zeros(N+1, 1);

disp('---- Elim Gauss EI 0.9 ----');
tic;
solucion_elim_gauss(2:N, 1) = eliminacion_gaussiana(matriz_reducida, b(2:N, 1), N);
toc;

solucion_gs_ab = zeros(N+1, 1);
solucion_jacobi = zeros(N+1, 1);

for i = 2:N
  solucion_gs_ab(i, 1) = 0.03;
endfor

disp('---- Ejecucion de Gauss-Seidel 0.9 ----');
tic;
solucion_gs_ab(2:N, 1) = gauss_seidel(matriz_reducida, tolerancia, solucion_gs_ab(2:N, 1), b(2:N, 1));
toc;

plot(1:N+1, solucion_elim_gauss(1:N+1, 1));
hold on;
plot(1:N+1, solucion_gs_ab(1:N+1, 1));
hold on;
title('Deformación de la viga con N = 100', 'fontsize', 12);
xlabel('Nodo xi', 'fontsize', 12);
ylabel('Deformación', 'fontsize', 12);
legend('Gauss con EI 1', 'Gauss-Seidel con EI 1', 'Gauss con EI 1.1', 'Gauss-Seidel con EI 1.1', 'Gauss con EI 0.9', 'Gauss-Seidel con EI 0.9');

print -djpeg ensayos_sensibilidad_EI.jpg;

hold off;

