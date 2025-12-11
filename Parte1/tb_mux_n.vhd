-----------------Sistemas Digitais II-------------------------------------
-- Arquivo   : tb_mux_n.vhd
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

entity tb_mux_n is 
end entity;

architecture dut of tb_mux_n is

    -- componente mux
    component mux_n is
        generic (
            dataSize : natural := 64
        );
        port(
            in0    : in bit_vector(dataSize-1 downto 0);
            in1    : in bit_vector(dataSize-1 downto 0);
            sel    : in bit;
            dOut    : out bit_vector(dataSize-1 downto 0)
        );
    end component mux_n;


    -- Sinais de teste
    constant DATA_SIZE : natural := 4; -- definindo quantos bits terá dentro de cada reg

    signal input0   : bit_vector(DATA_SIZE-1 downto 0);
    signal input1   : bit_vector(DATA_SIZE-1 downto 0);
    signal dataOut  : bit_vector(DATA_SIZE-1 downto 0);

    signal seletor : bit;

begin

    DUT: mux_n
    generic map (
        dataSize => DATA_SIZE
    )
    port map (
        in0 => input0,
        in1 => input1,
        sel => seletor,
        dOut => dataOut
    );

    process
    begin
        --
        report "Iniciando testes do mux_n";

        input0 <= "0000"; input1 <= "1111";
        seletor <= '0';
        wait for 1 ns;
        assert (dataOut = "0000") report "Falha 1" severity error;

        input0 <= "0000"; input1 <= "1111";
        seletor <= '1';
        wait for 1 ns;
        assert (dataOut = "1111") report "Falha 2" severity error;

        input0 <= "0101"; input1 <= "1010";
        seletor <= '0';
        wait for 1 ns;
        assert (dataOut = "0101") report "Falha 3" severity error;

        input0 <= "0101"; input1 <= "1010";
        seletor <= '1';
        wait for 1 ns;
        assert (dataOut = "1010") report "Falha 4" severity error;

        input0 <= "1100"; input1 <= "0011";
        seletor <= '0';
        wait for 1 ns;
        assert (dataOut = "1100") report "Falha 5" severity error;

        input0 <= "1100"; input1 <= "0011";
        seletor <= '1';
        wait for 1 ns;
        assert (dataOut = "0011") report "Falha 6" severity error;

        input0 <= "1001"; input1 <= "0110"; 
        seletor <= '0'; 
        wait for 1 ns;
        assert (dataOut = "1001") report "Falha 7" severity error;

        input0 <= "1001"; input1 <= "0110"; 
        seletor <= '1'; 
        wait for 1 ns;
        assert (dataOut = "0110") report "Falha 8" severity error;

        --Teste de borda: 1 bit diferente
        input0 <= "0000"; input1 <= "0001";
        seletor <= '0';
        wait for 1 ns;
        assert (dataOut = "0000") report "Falha 9" severity error;

        input0 <= "0000"; input1 <= "0001"; 
        seletor <= '1'; 
        wait for 1 ns;
        assert (dataOut = "0001") report "Falha 10" severity error;

        report "Todos os testes do mux_n passaram com sucesso";
        wait;

    end process;

end architecture;
