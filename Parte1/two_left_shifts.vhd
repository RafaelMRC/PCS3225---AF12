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

library IEEE;
use ieee.numeric_bit.all;

entity two_left_shifts is
    generic (
        dataSize : natural := 64
    );
    port (
        input  : in  bit_vector(dataSize-1 downto 0);
        output : out bit_vector(dataSize-1 downto 0)
    );
end entity two_left_shifts;

architecture two_left_shifts_arch of two_left_shifts is
begin
    output <= input(dataSize-3 downto 0) & "00";
end architecture two_left_shifts_arch;
