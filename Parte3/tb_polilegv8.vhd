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

entity tb_polilegv8 is
end entity tb_polilegv8;

architecture behavior of tb_polilegv8 is

    --------------------------------------------------------
    -- Sinais do Testbench
    --------------------------------------------------------
    signal clock : bit := '0';
    signal reset : bit := '0';

    constant CLK_PERIOD : time := 10 ns;

    --------------------------------------------------------
    -- Componente sob teste (DUT)
    --------------------------------------------------------
    component polilegv8 is
        port (
            clock : in bit;
            reset : in bit
        );
    end component;

begin

    --------------------------------------------------------
    -- Instância do DUT
    --------------------------------------------------------
    DUT : polilegv8
        port map (
            clock => clock,
            reset => reset
        );

    --------------------------------------------------------
    -- Geração do Clock
    --------------------------------------------------------
    clock_process : process
    begin
        while true loop
            clock <= '0';
            wait for CLK_PERIOD / 2;
            clock <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    --------------------------------------------------------
    -- Processo de Estímulos
    --------------------------------------------------------
    stimulus_process : process
    begin
        ----------------------------------------------------
        -- Reset inicial
        ----------------------------------------------------
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        ----------------------------------------------------
        -- Execução do programa
        ----------------------------------------------------
        -- O processador passa a executar as instruções
        -- carregadas na memória de instruções (.dat)
        ----------------------------------------------------
        wait for 500 ns;

        ----------------------------------------------------
        -- Final da simulação
        ----------------------------------------------------
        assert false
            report "Simulação finalizada com sucesso."
            severity failure;

    end process;

end architecture behavior;
