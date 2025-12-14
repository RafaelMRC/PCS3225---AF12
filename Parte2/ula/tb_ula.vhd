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

entity tb_ula is
end entity;

architecture testbench of tb_ula is
    component ula
        port(
            A  : in  bit_vector(63 downto 0);
            B  : in  bit_vector(63 downto 0);
            S  : in  bit_vector(3 downto 0);
            F  : out bit_vector(63 downto 0);
            Z  : out bit;
            Ov : out bit;
            Co : out bit
        );
    end component;

    -- Sinais de teste
    signal A, B, F : bit_vector(63 downto 0);
    signal S       : bit_vector(3 downto 0);
    signal Z, Ov, Co : bit;

begin
    -- instância da ula
    DUT: ula
        port map (
            A  => A,
            B  => B,
            S  => S,
            F  => F,
            Z  => Z,
            Ov => Ov,
            Co => Co
        );

    ----------------------------------------------------------------
    -- Processo de estímulos
    ----------------------------------------------------------------
    stimulus : process
    begin
        report "=== INÍCIO DOS TESTES DA ULA 64 BITS ===";

        ----------------------------------------------------------------
        -- TESTE 1 – SOMA NORMAL (5 + 3 = 8)
        ----------------------------------------------------------------
        A <= (others => '0'); A(3 downto 0) <= "0101";
        B <= (others => '0'); B(3 downto 0) <= "0011";
        S <= "0000"; -- ADD
        wait for 20 ns;

        assert F(3 downto 0) = "1000"
            report "FAIL: Soma 5 + 3 deveria ser 8"
            severity error;

        ----------------------------------------------------------------
        -- TESTE 2 – SUBTRAÇÃO (32 - 5 = 27)
        ----------------------------------------------------------------
        A <= (others => '0'); A(7 downto 0) <= x"20";
        B <= (others => '0'); B(7 downto 0) <= x"05";
        S <= "0110"; -- SUB (binvert = 1, operação = ADD)
        wait for 20 ns;

        assert F(7 downto 0) = x"1B"
            report "FAIL: SUB 32 - 5 deveria ser 27"
            severity error;

        ----------------------------------------------------------------
        -- TESTE 3 – OPERAÇÃO OR
        ----------------------------------------------------------------
        A <= (others => '0'); A(7 downto 0) <= "10101010";
        B <= (others => '0'); B(7 downto 0) <= "01010101";
        S <= "0001"; -- OR
        wait for 20 ns;

        assert F(7 downto 0) = "11111111"
            report "FAIL: OR deveria resultar em 11111111"
            severity error;

        ----------------------------------------------------------------
        -- TESTE 4 – OPERAÇÃO AND
        ----------------------------------------------------------------
        A <= (others => '0'); A(7 downto 0) <= "11110000";
        B <= (others => '0'); B(7 downto 0) <= "10101010";
        S <= "0010"; -- AND
        wait for 20 ns;

        assert F(7 downto 0) = "10100000"
            report "FAIL: AND errado, esperado 10100000"
            severity error;

        ----------------------------------------------------------------
        -- TESTE 5 – OVERFLOW (2^62 + 2^62)
        ----------------------------------------------------------------
        A <= (others => '0'); A(62) <= '1';
        B <= (others => '0'); B(62) <= '1';
        S <= "0000"; -- ADD
        wait for 20 ns;

        assert Ov = '1'
            report "FAIL: Overflow deveria ser ativado"
            severity error;

        ----------------------------------------------------------------
        -- TESTE 6 – UNDERFLOW (-2^62 - 1)
        ----------------------------------------------------------------
        A <= (others => '0'); A(63) <= '1'; A(62) <= '1';
        B <= (others => '0'); B(0) <= '1';
        S <= "0110"; -- SUB
        wait for 20 ns;

        assert Ov = '1'
            report "FAIL: Underflow deveria ativar overflow"
            severity error;

        ----------------------------------------------------------------
        -- TESTE 7 – UNDERFLOW (-4 - 8)
        ----------------------------------------------------------------
        A <= (others => '0'); A(63) <= '1'; A(2) <= '1'; -- -4
        B <= (others => '0'); B(3) <= '1';               -- 8
        S <= "0110"; -- SUB
        wait for 20 ns;

        assert Ov = '1'
            report "FAIL: Underflow esperado em -4 - 8"
            severity error;

        ----------------------------------------------------------------
        -- TESTE 8 – RESULTADO ZERO
        ----------------------------------------------------------------
        A <= (others => '0');
        B <= (others => '0');
        S <= "0000"; -- ADD
        wait for 20 ns;

        assert Z = '1'
            report "FAIL: Flag Z deveria estar ativa"
            severity error;
        ----------------------------------------------------------------
        report "=== TODOS OS TESTES DA ULA FORAM EXECUTADOS ===";
        wait;
    end process;

end architecture;
