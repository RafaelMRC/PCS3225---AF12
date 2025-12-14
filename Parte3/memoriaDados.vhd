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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity memoriaDados is
    generic (
        addressSize : natural := 8;
        dataSize    : natural := 8
    );
    port (
        clock   : in  bit;
        we      : in  bit;  -- write enable
        addr    : in  bit_vector(addressSize-1 downto 0);
        dIn     : in  bit_vector(dataSize-1 downto 0);
        dOut    : out bit_vector(dataSize-1 downto 0)
    );
end entity memoriaDados;


architecture memoriaDados_arch of memoriaDados is
    type mem_tipo is array (0 to (2**addressSize - 1))
        of bit_vector(dataSize-1 downto 0);

    signal mem : mem_tipo;

    begin
    process (clock)
    begin 
        if (clock'event and clock = '1') then -- rising_edge
            if (we = '1') then
                mem(to_integer(unsigned(addr))) <= dIn;
            end if;
        end if;
    end process;

    dOut <= mem (to_integer(unsigned(addr)));
end architecture;
