-----------------Sistemas Digitais II-------------------------------------
-- Arquivo   : reg.vhd
-- Projeto   : AF12 Parte 1 SDII 2025 - biblioteca de componentes para construção de um processador
-------------------------------------------------------------------------
-- Autores:     Grupo T2G07     
--      12684531 Antonio Torres Rocha (Turma 3)
--      15637418 Guilherme Jun Gondo (Turma 1)
--      15485340 Rafael Moreno Rachel Carvalho (Turma 1)
--      15487892 Samuel Henrique de Jesus da Silva (Turma 2)
-------------------------------------------------------------------------

entity fulladder is
  port (
    a, b, cin: in bit;
    s, cout: out bit
  );
 end entity;
-------------------------------------------------------
architecture structural of fulladder is
  signal axorb: bit;
begin
  axorb <= a xor b;
  s <= axorb xor cin;
  cout <= (axorb and cin) or (a and b);
 end architecture;
