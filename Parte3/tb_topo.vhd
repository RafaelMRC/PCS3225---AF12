library IEEE;
use IEEE.numeric_bit.all;

entity tb_topo is
end entity;

architecture test of tb_topo is

    ------------------------------------------------------------
    -- COMPONENTE DUT (topo)
    ------------------------------------------------------------
    component topo is
        port(
            clock  : in  bit;
            reset  : in  bit;
            -- nenhuma outra entrada ou saída externa
            -- fluxo de dados e unidade de controle trabalham internamente
            -- instruções e dados vêm das memórias internas
            -- resultados são vistos por meio de registradores e memória
            dummy  : out bit   -- saída fictícia para evitar DUT sem portas
        );
    end component;

    ------------------------------------------------------------
    -- SINAIS DE TESTE
    ------------------------------------------------------------
    signal clk   : bit := '0';
    signal rst   : bit := '0';
    signal dummy : bit;

    constant CLK_PERIOD : time := 10 ns;

begin

    ------------------------------------------------------------
    -- INSTANCIA O TOP LEVEL
    ------------------------------------------------------------
    DUT : topo
        port map(
            clock => clk,
            reset => rst,
            dummy => dummy
        );

    ------------------------------------------------------------
    -- GERADOR DE CLOCK
    ------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;


    ------------------------------------------------------------
    -- PROCESSO PRINCIPAL DE SIMULAÇÃO
    ------------------------------------------------------------
    stim_proc : process
    begin

        --------------------------------------------------------------------
        -- 1. RESET GLOBAL
        --------------------------------------------------------------------
        report "---------------------------------------------";
        report "INICIO DA SIMULACAO DO POLILEGV8";
        report "---------------------------------------------";

        rst <= '1';
        wait for 40 ns;
        rst <= '0';
        wait for 40 ns;

        report "RESET concluido.";

        --------------------------------------------------------------------
        -- 2. EXECUCAO AUTOMATICA DA MEMORIA DE INSTRUCOES
        -- O fluxo de dados vai buscar instrução após instrução
        --------------------------------------------------------------------
        report "Iniciando execucao das instrucoes carregadas...";
        wait for 20 ns;

        --------------------------------------------------------------------
        -- 3. ACOMPANHAMENTO DE RESULTADOS
        --    Este bloco imprime automaticamente o valor dos registradores
        --    e de partes da memória a cada instrução.
        --------------------------------------------------------------------

        report "Monitorando registradores a cada 5 ciclos...";

        for i in 0 to 50 loop

            -- espera 5 ciclos de clock por instrução
            wait for 5 * CLK_PERIOD;

            report "---------------- Ciclo " & integer'image(i) & " ----------------";

            -- Leitura dos registradores X0..X7 (exemplo)
            report "X0 = " & bit_vector'image(DUT.FD.REGFILE_inst.s_regs(0));
            report "X1 = " & bit_vector'image(DUT.FD.REGFILE_inst.s_regs(1));
            report "X2 = " & bit_vector'image(DUT.FD.REGFILE_inst.s_regs(2));
            report "X3 = " & bit_vector'image(DUT.FD.REGFILE_inst.s_regs(3));
            report "X4 = " & bit_vector'image(DUT.FD.REGFILE_inst.s_regs(4));
            report "X5 = " & bit_vector'image(DUT.FD.REGFILE_inst.s_regs(5));
            report "X6 = " & bit_vector'image(DUT.FD.REGFILE_inst.s_regs(6));
            report "X7 = " & bit_vector'image(DUT.FD.REGFILE_inst.s_regs(7));

            -- Exemplo de leitura de memória de dados
            report "Mem[0] = " & bit_vector'image(DUT.FD.DMEM_inst.mem(0));
            report "Mem[1] = " & bit_vector'image(DUT.FD.DMEM_inst.mem(1));

        end loop;


        --------------------------------------------------------------------
        -- 4. TESTES DE ASSERT PARA VALIDAR O FUNCIONAMENTO
        --    Aqui se verifica automaticamente se o conteúdo esperado
        --    foi realmente produzido
        --------------------------------------------------------------------

        report "Iniciando asserts de verificacao final...";

        -- Exemplo: Supondo que a instrução ADD X1, X2, X3 deve produzir X1 = X2+X3
        assert DUT.FD.REGFILE_inst.s_regs(1) = DUT.FD.REGFILE_inst.s_regs(2) + DUT.FD.REGFILE_inst.s_regs(3)
            report "ERRO: ADD falhou!" severity error;

        -- Exemplo: STUR deve ter escrito valor correto na memória
        assert DUT.FD.DMEM_inst.mem(0) = DUT.FD.REGFILE_inst.s_regs(5)
            report "ERRO: STUR falhou!" severity error;

        report "Todos os asserts executados.";

        --------------------------------------------------------------------
        -- FINALIZAÇÃO DA SIMULAÇÃO
        --------------------------------------------------------------------
        report "---------------------------------------------";
        report "FIM DA SIMULACAO";
        report "---------------------------------------------";
        wait;

    end process;

end architecture;
