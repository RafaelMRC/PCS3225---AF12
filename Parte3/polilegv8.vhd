-----------------Sistemas Digitais II-------------------------------------
-- Arquivo   : polilegv8.vhd
-- Projeto   : AF12 Parte 3 SDII 2025 - Projeto Integrado do Processador PoliLEGv8 Monociclo
-------------------------------------------------------------------------
-- Autores:     Grupo T2G07     
--      12684531 Antonio Torres Rocha (Turma 3)
--      15637418 Guilherme Jun Gondo (Turma 1)
--      15485340 Rafael Moreno Rachel Carvalho (Turma 1)
--      15487892 Samuel Henrique de Jesus da Silva (Turma 2)
-------------------------------------------------------------------------

entity polilegv8 is
    port (
        clock : in bit;
        reset : in bit
    );
end entity polilegv8;


architecture estrutural of polilegv8 is

    --------------------------------------------------------------------
    -- Declaração dos componentes 
    --------------------------------------------------------------------
    component fluxoDados is
        port(
            clock        : in  bit;
            reset        : in  bit;
            extendMSB    : in  bit_vector(4 downto 0);
            extendLSB    : in  bit_vector(4 downto 0);
            reg2Loc      : in  bit;
            regWrite     : in  bit;
            aluSrc       : in  bit;
            alu_control  : in  bit_vector(3 downto 0);
            branch       : in  bit;
            uncondBranch : in  bit;
            memRead      : in  bit;
            memWrite     : in  bit;
            memToReg     : in  bit;
            opcode       : out bit_vector(10 downto 0)
        );
    end component;

    component unidadeControle is
        port(
            opcode       : in  bit_vector(10 downto 0);
            extendMSB    : out bit_vector(4 downto 0);
            extendLSB    : out bit_vector(4 downto 0);
            reg2Loc      : out bit;
            regWrite     : out bit;
            aluSrc       : out bit;
            alu_control  : out bit_vector(3 downto 0);
            branch       : out bit;
            uncondBranch : out bit;
            memRead      : out bit;
            memWrite     : out bit;
            memToReg     : out bit
        );
    end component;


    --------------------------------------------------------------------
    -- Sinais internos
    --------------------------------------------------------------------
    signal s_opcode       : bit_vector(10 downto 0);

    signal s_extendMSB    : bit_vector(4 downto 0);
    signal s_extendLSB    : bit_vector(4 downto 0);
    signal s_reg2Loc      : bit;
    signal s_regWrite     : bit;
    signal s_aluSrc       : bit;
    signal s_alu_control  : bit_vector(3 downto 0);
    signal s_branch       : bit;
    signal s_uncondBranch : bit;
    signal s_memRead      : bit;
    signal s_memWrite     : bit;
    signal s_memToReg     : bit;

begin

    --------------------------------------------------------------------
    -- Instância do Fluxo de Dados
    --------------------------------------------------------------------
    FD: fluxoDados
        port map(
            clock        => clock,
            reset        => reset,
            extendMSB    => s_extendMSB,
            extendLSB    => s_extendLSB,
            reg2Loc      => s_reg2Loc,
            regWrite     => s_regWrite,
            aluSrc       => s_aluSrc,
            alu_control  => s_alu_control,
            branch       => s_branch,
            uncondBranch => s_uncondBranch,
            memRead      => s_memRead,
            memWrite     => s_memWrite,
            memToReg     => s_memToReg,
            opcode       => s_opcode
        );

    --------------------------------------------------------------------
    -- Instância da Unidade de Controle
    --------------------------------------------------------------------
    UC: unidadeControle
        port map(
            opcode       => s_opcode,
            extendMSB    => s_extendMSB,
            extendLSB    => s_extendLSB,
            reg2Loc      => s_reg2Loc,
            regWrite     => s_regWrite,
            aluSrc       => s_aluSrc,
            alu_control  => s_alu_control,
            branch       => s_branch,
            uncondBranch => s_uncondBranch,
            memRead      => s_memRead,
            memWrite     => s_memWrite,
            memToReg     => s_memToReg
        );

end architecture estrutural;
