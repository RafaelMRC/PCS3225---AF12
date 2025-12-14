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

library IEEE;
use IEEE.numeric_bit.all;

entity fluxoDados is
    port (
        clock         : in  bit;                       -- entrada de clock
        reset         : in  bit;                       -- clear assincrono
        extendMSB     : in  bit_vector(4 downto 0);    -- sinal de controle sign-extend
        extendLSB     : in  bit_vector(4 downto 0);    -- sinal de controle sign-extend
        reg2Loc       : in  bit;                       -- sinal de controle MUX Read Register 2
        regWrite      : in  bit;                       -- sinal de controle Write Register
        aluSrc        : in  bit;                       -- sinal de controle MUX entrada B ULA
        alu_control   : in  bit_vector(3 downto 0);    -- sinal de controle da ULA
        branch        : in  bit;                       -- sinal de controle desvio condicional
        uncondBranch  : in  bit;                       -- sinal de controle desvio incondicional
        memRead       : in  bit;                       -- sinal de controle leitura RAM dados
        memWrite      : in  bit;                       -- sinal de controle escrita RAM dados
        memToReg      : in  bit;                       -- sinal de controle MUX Write Data
        opcode        : out bit_vector(10 downto 0)    -- sinal de condicao codigo da instrucao
    );
end entity fluxoDados;

architecture estrutural of fluxoDados is

    --------------------------------------------------------------------
    -- COMPONENTES
    --------------------------------------------------------------------

    component reg
        generic (dataSize : natural);
        port (
            clock  : in  bit;
            reset  : in  bit;
            enable : in  bit;
            d      : in  bit_vector(dataSize-1 downto 0);
            q      : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    component memoriaInstrucoes
        generic (
            addressSize : natural;
            dataSize    : natural;
            datFileName : string
        );
        port (
            addr : in  bit_vector(addressSize-1 downto 0);
            data : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    component memoriaDados
        generic (
            addressSize : natural;
            dataSize    : natural
        );
        port (
            clock : in  bit;
            we    : in  bit;
            addr  : in  bit_vector(addressSize-1 downto 0);
            dIn   : in  bit_vector(dataSize-1 downto 0);
            dOut  : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    component regfile
        port (
            clock    : in  bit;
            reset    : in  bit;
            regWrite : in  bit;
            rr1      : in  bit_vector(4 downto 0);
            rr2      : in  bit_vector(4 downto 0);
            wr       : in  bit_vector(4 downto 0);
            d        : in  bit_vector(63 downto 0);
            q1       : out bit_vector(63 downto 0);
            q2       : out bit_vector(63 downto 0)
        );
    end component;

    component ula
        port (
            A  : in  bit_vector(63 downto 0);
            B  : in  bit_vector(63 downto 0);
            S  : in  bit_vector(3 downto 0);
            F  : out bit_vector(63 downto 0);
            Z  : out bit;
            Ov : out bit;
            Co : out bit
        );
    end component;

    component adder_n
        generic (dataSize : natural);
        port (
            in0  : in  bit_vector(dataSize-1 downto 0);
            in1  : in  bit_vector(dataSize-1 downto 0);
            sum  : out bit_vector(dataSize-1 downto 0);
            cOut : out bit
        );
    end component;

    component mux_n
        generic (dataSize : natural);
        port (
            d0  : in  bit_vector(dataSize-1 downto 0);
            d1  : in  bit_vector(dataSize-1 downto 0);
            sel : in  bit;
            y   : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    component sign_extend
        generic (
            dataISize : natural;
            dataOSize : natural;
            dataMaxPosition : natural
        );
        port (
            inData      : in  bit_vector(dataISize-1 downto 0);
            inDataStart : in  bit_vector(dataMaxPosition-1 downto 0);
            inDataEnd   : in  bit_vector(dataMaxPosition-1 downto 0);
            outData     : out bit_vector(dataOSize-1 downto 0)
        );
    end component;

    component two_left_shifts
        generic (dataSize : natural);
        port (
            input  : in  bit_vector(dataSize-1 downto 0);
            output : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    --------------------------------------------------------------------
    -- SINAIS INTERNOS
    --------------------------------------------------------------------

    signal pc, pc_next       : bit_vector(6 downto 0);
    signal pc_plus4_64       : bit_vector(63 downto 0);
    signal pc_branch_64      : bit_vector(63 downto 0);

    signal instr_byte0,
           instr_byte1,
           instr_byte2,
           instr_byte3       : bit_vector(7 downto 0);

    signal instr             : bit_vector(31 downto 0);

    signal rr2_mux           : bit_vector(4 downto 0);

    signal regA, regB        : bit_vector(63 downto 0);
    signal aluB              : bit_vector(63 downto 0);
    signal aluResult         : bit_vector(63 downto 0);
    signal zero              : bit;

    signal imm_ext           : bit_vector(63 downto 0);
    signal imm_shifted       : bit_vector(63 downto 0);

    signal memOut            : bit_vector(7 downto 0);
    signal writeBack         : bit_vector(63 downto 0);

    signal pcSrc             : bit;

begin

    --------------------------------------------------------------------
    -- PROGRAM COUNTER
    --------------------------------------------------------------------

    PC_REG : reg
        generic map (dataSize => 7)
        port map (
            clock  => clock,
            reset  => reset,
            enable => '1',
            d      => pc_next,
            q      => pc
        );

    --------------------------------------------------------------------
    -- MEMÓRIA DE INSTRUÇÕES (4 bytes)
    --------------------------------------------------------------------

    IM0 : memoriaInstrucoes
        generic map (7, 8, "memInstrPolilegv8.dat")
        port map (pc, instr_byte0);

    IM1 : memoriaInstrucoes
        generic map (7, 8, "memInstrPolilegv8.dat")
        port map (bit_vector(unsigned(pc)+1), instr_byte1);

    IM2 : memoriaInstrucoes
        generic map (7, 8, "memInstrPolilegv8.dat")
        port map (bit_vector(unsigned(pc)+2), instr_byte2);

    IM3 : memoriaInstrucoes
        generic map (7, 8, "memInstrPolilegv8.dat")
        port map (bit_vector(unsigned(pc)+3), instr_byte3);

    instr <= instr_byte0 & instr_byte1 & instr_byte2 & instr_byte3;
    opcode <= instr(31 downto 21);

    --------------------------------------------------------------------
    -- BANCO DE REGISTRADORES
    --------------------------------------------------------------------

    rr2_mux <= instr(20 downto 16) when reg2Loc = '0'
               else instr(4 downto 0);

    REGFILE : regfile
        port map (
            clock    => clock,
            reset    => reset,
            regWrite => regWrite,
            rr1      => instr(9 downto 5),
            rr2      => rr2_mux,
            wr       => instr(4 downto 0),
            d        => writeBack,
            q1       => regA,
            q2       => regB
        );

    --------------------------------------------------------------------
    -- SIGN EXTEND + SHIFT LEFT 2
    --------------------------------------------------------------------

    SIGNEXT : sign_extend
        generic map (32, 64, 5)
        port map (
            instr,
            extendMSB,
            extendLSB,
            imm_ext
        );

    SHIFT2 : two_left_shifts
        generic map (64)
        port map (
            imm_ext,
            imm_shifted
        );

    --------------------------------------------------------------------
    -- ULA
    --------------------------------------------------------------------

    ALU_B_MUX : mux_n
        generic map (64)
        port map (
            regB,
            imm_ext,
            aluSrc,
            aluB
        );

    ALU_MAIN : ula
        port map (
            regA,
            aluB,
            alu_control,
            aluResult,
            zero,
            open,
            open
        );

    --------------------------------------------------------------------
    -- MEMÓRIA DE DADOS
    --------------------------------------------------------------------

    DM : memoriaDados
        generic map (7, 8)
        port map (
            clock,
            memWrite,
            aluResult(6 downto 0),
            regB(7 downto 0),
            memOut
        );

    --------------------------------------------------------------------
    -- WRITE BACK
    --------------------------------------------------------------------

    writeBack <= aluResult when memToReg = '0'
                 else (63 downto 8 => '0') & memOut;

    --------------------------------------------------------------------
    -- PC + 4 e BRANCH
    --------------------------------------------------------------------

    ADD_PC4 : adder_n
        generic map (64)
        port map (
            (63 downto 7 => '0') & pc,
            x"0000000000000004",
            pc_plus4_64,
            open
        );

    ADD_BRANCH : adder_n
        generic map (64)
        port map (
            pc_plus4_64,
            imm_shifted,
            pc_branch_64,
            open
        );

    pcSrc <= uncondBranch or (branch and zero);

    pc_next <= pc_plus4_64(6 downto 0) when pcSrc = '0'
               else pc_branch_64(6 downto 0);

end architecture estrutural;
