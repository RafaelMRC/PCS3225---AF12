library ieee;
use IEEE.numeric_bit.all;
use ieee.std_logic_1164.all;
use std.textio.all;

entity tb_memoriaInstrucoes is
end entity;

architecture testbench of tb_memoriaInstrucoes is

    -- Componente da memória
    component memoriaInstrucoes is
        generic (
            addressSize : natural := 8;
            dataSize    : natural := 8;
            datFileName : string  := "memInstr_conteudo.dat"
        );
        port (
            addr : in  bit_vector (addressSize-1 downto 0);
            data : out bit_vector (dataSize-1 downto 0)
        );
    end component;

    -- Sinais de teste
    signal addr : bit_vector(7 downto 0);
    signal data : bit_vector(7 downto 0);

begin

    -- Instância da ROM
    UUT : memoriaInstrucoes
        generic map (
            addressSize => 8,
            dataSize    => 8,
            datFileName => "memInstr_conteudo.dat"
        )
        port map (
            addr => addr,
            data => data
        );

    -- Processo de estímulos
    process
    begin
        report "Iniciando teste da Memoria de Instrucoes";

        addr <= "00000000"; wait for 10 ns;
        addr <= "00000001"; wait for 10 ns;
        addr <= "00000010"; wait for 10 ns;
        addr <= "00000011"; wait for 10 ns;
        addr <= "00000100"; wait for 10 ns;

        report "Teste finalizado";
        wait;
    end process;

end architecture;
