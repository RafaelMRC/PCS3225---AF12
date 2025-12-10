library IEEE;
use IEEE.std_logic_1164.all;

entity tb_two_left_shifts is
end entity;

architecture testbench of tb_two_left_shifts is

    -- Componente em teste
    component two_left_shifts is
        generic (
            dataSize : natural := 64
        );
        port (
            input  : in  bit_vector(dataSize-1 downto 0);
            output : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    -- ===== Sinais de teste =====
    constant dataSize : natural := 8;

    signal input_tb  : bit_vector(dataSize-1 downto 0);
    signal output_tb : bit_vector(dataSize-1 downto 0);

begin

    -- ===== Instância do DUT =====
    UUT: two_left_shifts
        generic map (dataSize => dataSize)
        port map (
            input  => input_tb,
            output => output_tb
        );

    -- ===== Processo de estímulos =====
    process
    begin
        report "Iniciando testes do two_left_shifts...";

        -- Teste 1
        input_tb <= "00000001";
        wait for 10 ns;
        assert output_tb = "00000100"
        report "Erro no Teste 1" severity error;

        -- Teste 2
        input_tb <= "00000010";
        wait for 10 ns;
        assert output_tb = "00001000"
        report "Erro no Teste 2" severity error;

        -- Teste 3
        input_tb <= "11110000";
        wait for 10 ns;
        assert output_tb = "11000000"
        report "Erro no Teste 3" severity error;

        -- Teste 4
        input_tb <= "10101010";
        wait for 10 ns;
        assert output_tb = "10101000"
        report "Erro no Teste 4" severity error;

        -- Teste 5 - Todos 1
        input_tb <= "11111111";
        wait for 10 ns;
        assert output_tb = "11111100"
        report "Erro no Teste 5" severity error;

        report "✅ Todos os testes passaram!";
        wait;
    end process;

end architecture testbench;
