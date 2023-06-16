clear all;

volumen_cota = load("volumen_y_cota.dat");

# (f_0, f_0) (f_0, f_1) (f_0, f_2) | (f_0, Y)
# (f_1, f_0) (f_1, f_1) (f_1, f_2) | (f_1, Y)
# (f_2, f_0) (f_2, f_1) (f_2, f_2) | (f_2, Y)
# f = a*x^2 + b*x + 1*c

f_2 = [1; 1; 1; 1];

f_1 = zeros(4, 1);
for i = 1:4
  f_1(i, 1) = volumen_cota(i, 2);
endfor

f_0 = zeros(4, 1);
for i = 1:4
  f_0(i, 1) = (volumen_cota(i, 2))^2;
endfor

function resultado = producto_interno(vect1, vect2)
  resultado = transpose(vect2) * vect1;
endfunction

aux = [f_0, f_1, f_2];

ec_normales = zeros(3, 4);

b = [
producto_interno(f_0, volumen_cota(:, 1));
producto_interno(f_1, volumen_cota(:, 1));
producto_interno(f_2, volumen_cota(:, 1));
];

for i = 1:3
  f_actual = aux(:, i);

  for j = 1:3
    ec_normales(i, j) = producto_interno(f_actual, aux(:, j));
  endfor
endfor

ec_normales(:, 4) = b;

A = ec_normales(:, 1:3);

solucion = linsolve(A, b);

cota0 = 77 + 1/10;

## Funcion de ajuste y valores de x para el ajuste
x = 74:1:80;
a = solucion(1, 1);
b = solucion(2, 1);
c = solucion(3, 1);

# Funcion de ajuste
y = a*(x.^2) + b*x + c;
v0 = a * ((cota0).^2) + b * cota0 + c;

## Interpolacion
x0 = 74;
x1 = 76;
x2 = 78;

a0 = 0;
a1 = 33;
a2 = 349/8;
a3 = -99/16;

# funcion interpolante
v0_i = a0 + a1 .* (cota0 - x0) + a2 .* (cota0 - x0) .* (cota0 - x1) + a3 .* (cota0 - x0) .* (cota0 - x1) .* (cota0 - x2);
y2 = a0 + a1 .* (x - x0) + a2 .* (x - x0) .* (x - x1) + a3 .* (x - x0) .* (x - x1) .* (x - x2);

# graficos
plot(x, y);
hold on;
plot(x, y2);
legend("Ajuste", "Interpolacion");
title("Aproximación de volumen en funcion de cota0");
xlabel ("Cota");
ylabel ("Volumen");
hold off;

print -djpeg ajuste_interpolacion.jpg;
