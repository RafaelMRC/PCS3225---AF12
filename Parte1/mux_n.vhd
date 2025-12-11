-----------------Sistemas Digitais II-------------------------------------
-- Arquivo   : mux_n.vhd
-- Projeto   : AF12 Parte 1 SDII 2025 - biblioteca de componentes para construção de um processador
-------------------------------------------------------------------------
-- Autores:     Grupo T2G07     
--      15637418 Guilherme Jun Gondo (Turma 1)
--      15487892 Samuel Henrique de Jesus da Silva (Turma 2)
--      15485340 Rafael Moreno Rachel Carvalho (Turma 1)
--      12684531 Antonio Torres Rocha (Turma 3)
-------------------------------------------------------------------------

entity mux_n is
    generic ( dataSize : natural := 64);
    port (
        in0    :   in bit_vector (dataSize-1 downto 0); -- entrada de dados 0
        in1    :   in bit_vector (dataSize-1 downto 0); -- entrada de dados 1
        sel    :   in bit ;
        dOut    :   out bit_vector (dataSize-1 downto 0) -- saida de dados
    );
end entity mux_n;

architecture with_select of mux_n is
begin
    with sel select
    dOut <= in0 when '0', -- quando select 0, saida de dados pega entrada 0
            in1 when '1', -- quando select 1, saida de dados pega entrada 1
            (others => '0') when others;
end architecture with_select;