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
use IEEE.std_logic_1164.all;
---------------------------------------
entity ula1bit is
  port (
    a           : in  bit;
    b           : in  bit;
    cin         : in bit;
    ainvert     : in bit;
    binvert     : in bit;
    operation   : in bit_vector (1 downto 0);
    result      : out bit;
    cout        : out bit;
    overflow    : out bit
    );
end entity;

-------------------------------------------------------
architecture ula1bit_arch of ula1bit is
    signal a_int, b_int : bit;
    signal and_result, or_result : bit;
    signal sum_result : bit;

     -- Carry interno (substitui leitura do cout)
    signal cout_i : bit;

    component fulladder is
        port (
            a, b, cin : in bit;
            s, cout   : out bit
        );
    end component;

    begin
        -- Inversão condicional
        a_int <= not a when ainvert = '1' else a;
        b_int <= not b when binvert = '1' else b;

        -- Operações lógicas
        and_result <= a_int and b_int;
        or_result  <= a_int or  b_int;

        -- Soma com FULL ADDER
        FA: fulladder
            port map (
                a    => a_int,
                b    => b_int,
                cin  => cin,
                s    => sum_result,
                cout => cout_i
            );

        -- Saída final do carry
        cout <= cout_i;    
        
        -- MUX FINAL (seleciona operação)
        with operation select
            result <= and_result when "00",
                or_result  when "01",
                sum_result when "10",
                b   when "11",
                '0'     when others;
    
        -- Overflow
        overflow <= cin xor cout_i;
end architecture ula1bit_arch;