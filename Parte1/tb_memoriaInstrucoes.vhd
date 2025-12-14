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
use IEEE.numeric_bit.all;
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

        -- Teste do endereço 0
        addr <= "00000000";
        wait for 10 ns;

        assert data = "11111000"
        report "Erro no endereco 0"
        severity error;


        -- Teste do endereço 1
        addr <= "00000001";
        wait for 10 ns;

        assert data = "01000000"
            report "Erro no endereco 1"
            severity error;

        -- Teste do endereço 2
        addr <= "00000010";
        wait for 10 ns;

        assert data = "00000011"
            report "Erro no endereco 2"
            severity error;

        -- Teste do endereço 3
        addr <= "00000011";
        wait for 10 ns;

        assert data = "11100001"
            report "Erro no endereco 3"
            severity error;

        report "Teste finalizado";
        wait;

        -- Teste do endereço 48 (ultimo byte que não possui bits zerados)
        addr <= "00110000";
        wait for 10 ns;

        assert data = "00010100" 
            report "Erro no endereco 48"
            severity error;

        report "Teste finalizado";
        wait;


        -- Teste do endereço 63 (ultimo do arquivo fornecido)
        addr <= "00111111";
        wait for 10 ns;

        assert data = "00000000"
            report "Erro no endereco 63 final"
            severity error;

        report "Teste finalizado";
        wait;


    end process;

end architecture;
