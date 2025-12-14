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
use IEEE.numeric_bit.all;

entity adder_n is
    generic (
        dataSize : natural := 64
    );
    port (
        in0    : in  bit_vector (dataSize-1 downto 0); -- primeira parcela
        in1    : in  bit_vector (dataSize-1 downto 0); -- segunda parcela
        sum    : out bit_vector (dataSize-1 downto 0); -- soma
        cOut : out bit
    );
end entity adder_n;

architecture adder_n_arch of adder_n is
    signal temp : unsigned(dataSize downto 0); -- cria vetor com 1 bit a mais pra esquerda (datasize em vez de datasize-1)
begin
    temp <= (unsigned("0" & in0)) + (unsigned("0" & in1)); -- acrescenta 1 bit a esquerda e executa soma
    sum  <= bit_vector(temp(dataSize-1 downto 0)); -- so o resultado da soma
    cOut <= temp(dataSize); -- pega apenas carryout
end architecture;
