-------------------------------------------------------------------
-- Arquivo: tb_ram_generica.vhd
-- Descricao: Testbench para a memoria RAM sincrona de tamanho parametrizável, alocando o tamanho 16x4
--
-- Comportamento do Testbench:
-- 1. Escreve os dados de 15 a 0 nos enderecos de 0 a 15.
-- 2. Le cada um dos enderecos de 0 a 15.
-- 3. Verifica se o dado lido e o mesmo que foi escrito.
-- 4. Indica o sucesso ou a falha para cada caso de teste.
--
-- código ADAPTADO de tb_ram_16x4.vhd 
-------------------------------------------------------------------
-------------------------------------------------------------------
-- Revisoes:
-- Data       Versao Autor               Descricao
-- 07/10/2025 1.0    Pedro H. F. Mendes  Versão inicial para PCS3225
-------------------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;


entity tb_memoriaDados is
end entity tb_memoriaDados;

architecture test_cases of tb_memoriaDados is

    -- Componente a ser testado (DUT - Device Under Test)
    component memoriaDados is
        generic (
            addressSize : natural := 8; -- vai ser 8
            dataSize  : natural := 8 -- vai ser 8
        );
        port (
            clock       : in  bit;
            we          : in  bit;
            addr        : in  bit_vector(addressSize-1 downto 0);
            dIn         : in  bit_vector(dataSize-1 downto 0);
            dOut  : out bit_vector(dataSize-1 downto 0)
        );
    end component memoriaDados;

    -- Sinais de entrada para o DUT
    signal s_clk          : bit := '0';
    signal s_we           : bit := '1';
    signal s_endereco     : bit_vector(7 downto 0) := (others => '0');
    signal s_dado_entrada : bit_vector(7 downto 0) := (others => '0');

    -- Sinal de saida do DUT
    signal s_dado_saida : bit_vector(7 downto 0);

    -- Constante para o periodo do clock
    constant CLK_PERIOD : time := 10 us;
    
    -- Sinal de controle de fim de simulação
    signal keep_simulating : bit := '0';    

begin

    -- Geração do clock
    clock_process : process
    begin
        wait until keep_simulating = '1';
        
        while keep_simulating = '1' loop
            s_clk <= '0';
            wait for CLK_PERIOD/2;
            s_clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Instanciacao do DUT
    dut_ram : memoriaDados
        generic map (
            addressSize => 8,
            dataSize  => 8
        )
        port map (
            clock   => s_clk,
            we      => s_we,
            addr    => s_endereco,
            dIn     => s_dado_entrada,
            dOut    => s_dado_saida
        );

    -- Geração de estímulos e verificação
    gera_estimulos : process
        variable expected_data : bit_vector(7 downto 0);
        variable actual_data   : bit_vector(7 downto 0);
    begin
        -- === Inicio do Teste ===
        keep_simulating <= '1';
        wait for CLK_PERIOD;
        report "Inicio do Testbench para a RAM Generica 16x4." severity note;

        -- ==========================================================
        -- FASE 1: Escrita dos dados na memoria
        -- ==========================================================
        report "Fase de Escrita: Escrevendo valores de 15 a 0 nos enderecos de 0 a 15." severity note;
        s_we <= '1'; -- Ativa a escrita 
        wait until (s_clk'event and s_clk = '1');

        for i in 0 to 15 loop
            s_endereco     <= bit_vector(to_unsigned(i, 8));
            s_dado_entrada <= bit_vector(to_unsigned(15 - i, 8));
            wait until (s_clk'event and s_clk = '1');

        end loop;

        -- ==========================================================
        -- FASE 2: Leitura e Verificacao dos dados
        -- ==========================================================
        report "Fase de Leitura e Verificacao." severity note;
        s_we <= '0'; -- Ativa modo de leitura
        wait until (s_clk'event and s_clk = '1');

        for i in 0 to 15 loop
            -- Seleciona Endereço
            s_endereco <= bit_vector(to_unsigned(i, 8));

            -- Espera até que o dado seja lido e propagado para a saida
            wait for CLK_PERIOD*3;

            expected_data := bit_vector(to_unsigned(15 - i, 8));
            actual_data := s_dado_saida;

            assert actual_data = expected_data
                report "Caso de Teste " & integer'image(i) & 
                       " NOK: esperado " & integer'image(to_integer(unsigned(expected_data))) & 
                       " mas foi lido " & integer'image(to_integer(unsigned(actual_data)))
                severity error; 
        end loop;
        
        -- === Fim do Teste ===
        keep_simulating <= '0';
        report "Fim do Testbench." severity note;
        wait;
    end process gera_estimulos;

end architecture test_cases;