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

entity unidadeControle is
    port (
        opcode        : in  bit_vector (10 downto 0); -- sinal de condicao codigo da instrucao
        extendMSB     : out bit_vector (4 downto 0);  -- sinal de controle sign-extend
        extendLSB     : out bit_vector (4 downto 0);  -- sinal de controle sign-extend
        reg2loc       : out bit;                      -- sinal de controle MUX Read Register 2
        regWrite      : out bit;                      -- sinal de controle Write Register
        aluSrc        : out bit;                      -- sinal de controle MUX entrada B ULA
        alu_control   : out bit_vector (3 downto 0);  -- sinal de controle da ULA
        branch        : out bit;                      -- sinal de controle desvio condicional
        uncondBranch  : out bit;                      -- sinal de controle desvio incondicional
        memRead       : out bit;                      -- sinal de controle leitura RAM dados
        memWrite      : out bit;                      -- sinal de controle leitura RAM dados
        memToReg      : out bit                       -- sinal de controle MUX Write Data
    );
end entity unidadeControle;


architecture unidadeControle_arch of unidadeControle is
    begin
        --SINAIS DE CONTROLE 
        reg2loc <= '1' when (opcode = "11111000000") -- Soma (Operacao STUR)
            or (opcode(10 downto 3) = "10110100") -- Pass B (CBZ)
            or (opcode(10 downto 5) = "000101") -- B
            else '0'; --DONT CARE PARA LDUR

        uncondbranch <= '1' when (opcode(10 downto 5) = "000101") -- B
            else '0';

        branch <= '1' when (opcode(10 downto 3) = "10110100") -- CBZ
            else '0';

        memRead <= '1' when (opcode = "11111000010") -- LDUR
            else '0';

        memToReg <= '1' when (opcode = "11111000010") -- LDUR
            or (opcode(10 downto 3) = "101101100") -- CBZ
            else '0';
        
        aluOp <= "00" when (opcode = "11111000010") -- LDUR
            or (opcode = "11111000000") -- STUR
            --DONT CARE PARA INSTRUCOES BRANCH
            else "01" when (opcode(10 downto 3) = "10110100") -- CBZ
            else "10";
        
        memWrite <= '1' when (opcode = "11111000000") -- STUR
            else '0';
        
        aluSrc <= '1' when (opcode = "11111000000") -- STUR
            or (opcode = "11111000010") 
            else '0';

        regWrite <= '1' when (opcode = "11111000010") -- LDUR
            or (opcode = "10001011000") -- ADD
            or (opcode = "11001011000") -- SUB
            or (opcode = "10001010000") -- AND
            or (opcode = "10101010000") -- ORR
            else '0';
         
end architecture unidadeControle_arch;