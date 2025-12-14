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
use ieee.numeric_bit.all;

entity tb_adder_n is
end entity tb_adder_n;

architecture testbench of tb_adder_n is
    component adder_n is
        generic (
            dataSize : natural
        );
        port (
            in0  : in  bit_vector(dataSize-1 downto 0);
            in1  : in  bit_vector(dataSize-1 downto 0);
            sum  : out bit_vector(dataSize-1 downto 0);
            cOut : out bit
        );
    end component;

    -- DUT 16 bits
    signal in0_16, in1_16, sum_16 : bit_vector(15 downto 0);
    signal cOut_16                : bit;

    -- DUT 32 bits
    signal in0_32, in1_32, sum_32 : bit_vector(31 downto 0);
    signal cOut_32                : bit;

    -- DUT 64 bits
    signal in0_64, in1_64, sum_64 : bit_vector(63 downto 0);
    signal cOut_64                : bit;

begin
    -- UUTs (ou DUTs)
    DUT_16 : adder_n
        generic map (dataSize => 16)
        port map (
            in0  => in0_16,
            in1  => in1_16,
            sum  => sum_16,
            cOut => cOut_16
        );

    DUT_32 : adder_n
        generic map (dataSize => 32)
        port map (
            in0  => in0_32,
            in1  => in1_32,
            sum  => sum_32,
            cOut => cOut_32
        );

    DUT_64 : adder_n
        generic map (dataSize => 64)
        port map (
            in0  => in0_64,
            in1  => in1_64,
            sum  => sum_64,
            cOut => cOut_64
        );

    -- Processo de testes
    stim_proc : process
    begin
        report "Inicio do Testbench do Somador Binario" severity note;

        -- CASO 1: Apenas zeros
        in0_16 <= (others => '0'); in1_16 <= (others => '0');
        in0_32 <= (others => '0'); in1_32 <= (others => '0');
        in0_64 <= (others => '0'); in1_64 <= (others => '0');
        wait for 10 ns;

        assert (sum_16 = (others => '0') and cOut_16 = '0')
            report "Erro caso minimo - 16 bits" severity error;
        assert (sum_32 = (others => '0') and cOut_32 = '0')
            report "Erro caso minimo - 32 bits" severity error;
        assert (sum_64 = (others => '0') and cOut_64 = '0')
            report "Erro caso minimo - 64 bits" severity error;

        -- CASO 2: Apenas uns
        in0_16 <= (others => '1'); in1_16 <= (others => '1');
        in0_32 <= (others => '1'); in1_32 <= (others => '1');
        in0_64 <= (others => '1'); in1_64 <= (others => '1');
        wait for 10 ns;

        assert (sum_16 = (others => '0') and cOut_16 = '1')
            report "Erro caso maximo - 16 bits" severity error;
        assert (sum_32 = (others => '0') and cOut_32 = '1')
            report "Erro caso maximo - 32 bits" severity error;
        assert (sum_64 = (others => '0') and cOut_64 = '1')
            report "Erro caso maximo - 64 bits" severity error;

        -- CASO 3: Intermediario sem carry
        in0_16 <= "0000000000001111"; in1_16 <= "0000000000001111";
        in0_32 <= (31 downto 4 => '0') & "1111";
        in1_32 <= (31 downto 4 => '0') & "1111";
        in0_64 <= (63 downto 4 => '0') & "1111";
        in1_64 <= (63 downto 4 => '0') & "1111";
        wait for 10 ns;

        assert (sum_16 = "0000000000011110" and cOut_16 = '0')
            report "Erro intermediario sem carry - 16 bits" severity error;
        assert (sum_32(4 downto 0) = "11110" and cOut_32 = '0')
            report "Erro intermediario sem carry - 32 bits" severity error;
        assert (sum_64(4 downto 0) = "11110" and cOut_64 = '0')
            report "Erro intermediario sem carry - 64 bits" severity error;

        -- CASO 4: Intermediario com carry
        in0_16 <= (others => '1'); in1_16 <= "0000000000000001";
        in0_32 <= (others => '1'); in1_32 <= (31 downto 1 => '0') & '1';
        in0_64 <= (others => '1'); in1_64 <= (63 downto 1 => '0') & '1';
        wait for 10 ns;

        assert (sum_16 = (others => '0') and cOut_16 = '1')
            report "Erro intermediario com carry - 16 bits" severity error;
        assert (sum_32 = (others => '0') and cOut_32 = '1')
            report "Erro intermediario com carry - 32 bits" severity error;
        assert (sum_64 = (others => '0') and cOut_64 = '1')
            report "Erro intermediario com carry - 64 bits" severity error;

        report "Fim do Testbench do Somador Binario - Todos os testes passaram"
            severity note;
        wait;
    end process;

end architecture testbench;
