--verificar depois

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity tb_adder_n is
end entity;

architecture testbench of tb_adder_n is

    -- Componente a ser testado
    component adder_n is
        generic (
            dataSize : natural := 64
        );
        port (
            in0  : in  bit_vector (dataSize-1 downto 0);
            in1  : in  bit_vector (dataSize-1 downto 0);
            sum  : out bit_vector (dataSize-1 downto 0);
            cOut : out bit
        );
    end component;

    -- Sinais de teste (vamos testar com 8 bits)
    constant DATA_SIZE : natural := 8;

    signal in0  : bit_vector(DATA_SIZE-1 downto 0);
    signal in1  : bit_vector(DATA_SIZE-1 downto 0);
    signal sum  : bit_vector(DATA_SIZE-1 downto 0);
    signal cOut : bit;

begin

    -- Instância do somador
    UUT : adder_n
        generic map (
            dataSize => DATA_SIZE
        )
        port map (
            in0  => in0,
            in1  => in1,
            sum  => sum,
            cOut => cOut
        );

    -- Processo de testes
    process
    begin
        report "Iniciando testes do adder_n";

        -- =========================
        -- Teste 1: 0 + 0 = 0
        -- =========================
        in0 <= "00000000";
        in1 <= "00000000";
        wait for 10 ns;

        assert sum = "00000000" and cOut = '0'
            report "ERRO: 0 + 0 falhou"
            severity error;

        -- =========================
        -- Teste 2: 5 + 3 = 8
        -- =========================
        in0 <= "00000101"; -- 5
        in1 <= "00000011"; -- 3
        wait for 10 ns;

        assert sum = "00001000" and cOut = '0'
            report "ERRO: 5 + 3 falhou"
            severity error;

        -- =========================
        -- Teste 3: 255 + 1 = 0, carry = 1 (overflow)
        -- =========================
        in0 <= "11111111"; -- 255
        in1 <= "00000001"; -- 1
        wait for 10 ns;

        assert sum = "00000000" and cOut = '1'
            report "ERRO: overflow 255 + 1 falhou"
            severity error;

        -- =========================
        -- Teste 4: 128 + 128 = 0, carry = 1
        -- =========================
        in0 <= "10000000"; -- 128
        in1 <= "10000000"; -- 128
        wait for 10 ns;

        assert sum = "00000000" and cOut = '1'
            report "ERRO: overflow 128 + 128 falhou"
            severity error;

        -- =========================
        -- Teste 5: 200 + 55 = 255, carry = 0
        -- =========================
        in0 <= "11001000"; -- 200
        in1 <= "00110111"; -- 55
        wait for 10 ns;

        assert sum = "11111111" and cOut = '0'
            report "ERRO: 200 + 55 falhou"
            severity error;

        report "Todos os testes do adder_n passaram com sucesso!";
        wait;
    end process;

end architecture;
