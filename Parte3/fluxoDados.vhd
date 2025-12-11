

entity fluxoDados is
    port (
        clock         : in bit;                       -- entrada de clock
        reset         : in bit;                       -- clear assincrono
        extendMSB     : in bit_vector(4 downto 0);    -- sinal de controle sign-extend
        extendLSB     : in bit_vector(4 downto 0);    -- sinal de controle sign-extend
        reg2loc       : in bit;                       -- sinal de controle MUX Read Register 2
        regWrite      : in bit;                       -- sinal de controle Write Register
        aluSrc        : in bit;                       -- sinal de controle MUX entrada B ULA
        alu_control   : in bit_vector(3 downto 0);    -- sinal de controle da ULA
        branch        : in bit;                       -- sinal de controle desvio condicional
        uncondBranch  : in bit;                       -- sinal de controle desvio incondicional
        memRead       : in bit;                       -- sinal de controle leitura RAM dados
        memWrite      : in bit;                       -- sinal de controle escrita RAM dados
        memToReg      : in bit;                       -- sinal de controle MUX Write Data
        opcode        : out bit_vector(10 downto 0)   -- sinal de condicao codigo da instrucao
    );
end entity fluxoDados;

architecture fluxoDados_arch of fluxoDados is --REGFILE, ALU, SIGNEXTEND, SHIFTLEFT2

    --REGISTER / PROGRAM COUNTER
    component reg is
        generic (dataSize: natural := 64);
        port (
            clock  : in  bit;
            reset  : in  bit;
            enable : in  bit;
            d      : in  bit_vector (dataSize-1 downto 0);
            q      : out bit_vector (dataSize-1 downto 0)
        );
    end component reg;


    -- componente two_left_shifts
    component two_left_shifts is
        generic (
            dataSize : natural := 64
        );
        port (
            input  : in  bit_vector(dataSize-1 downto 0);
            output : out bit_vector(dataSize-1 downto 0)
        );
    end component two_left_shifts;


    -- componente ula
    component ula is
        port(
            A: in bit_vector(63 downto 0); -- entrada A
            B: in bit_vector(63 downto 0); -- entrada B
            S: in bit_vector(3 downto 0); -- seleciona operacao
            F: out bit_vector(63 downto 0); -- saida
            Z: out bit;                     -- flag zero
            Ov: out bit;                    -- flag overflow
            Co: out bit                     -- flag carry out
    );
    end component ula;


    --SIGNEXTEND
    component sign_extend is 
        generic (
            dataISize   : natural := 32;
            dataOSize   : natural := 64;
            dataMaxPosition : natural := 5 -- sempre fazer log2(dataISize)
        );
        port (
            inData      : in  bit_vector(dataISize-1 downto 0); -- dado de entrada
                -- com tamanho dataISize
            inDataStart : in bit_vector(dataMaxPosition-1 downto 0); -- posicao do bit
                -- mais significativo do valor util na entrada (bit de sinal)
            inDataEnd   : in bit_vector(dataMaxPosition-1 downto 0); -- posicao do bit
                -- menos significativo do valor util na entrada
            outData     : out bit_vector(dataOSize-1 downto 0) -- dado de saida
                -- com tamanho dataOsize e sinal estendido
        );
    end component sign_extend;


    --REGFILE 
    component regfile is 
    port (
        clock     : in  bit;                    --! entrada de clock
        reset     : in  bit;                    --! entrada de reset
        regWrite  : in  bit;                    --! entrada de carga do registrador wr
        rr1       : in  bit_vector(4 downto 0); --! entrada define registrador 1
        rr2       : in  bit_vector(4 downto 0); --! entrada define registrador 2
        wr        : in  bit_vector(4 downto 0); --! entrada define registrador de escrita
        d         : in  bit_vector(63 downto 0);--! entrada de dado para carga paralela
        q1        : out bit_vector(63 downto 0);--! saida do registrador rr1
        q2        : out bit_vector(63 downto 0) --! saida do registrador rr2
    );
    end component regfile;


    --PC
    signal instruction_int: bit_vector(31 downto 0);
    signal instructionAddress: bit_vector(63 downto 0);
    signal nextAddress: bit_vector(63 downto 0);
    signal addressPlus4: bit_vector(63 downto 0);
    signal addressBranch: bit_vector(63 downto 0);


    --REGFILE 
    signal regMux: bit_vector(4 downto 0);
    signal readData1: bit_vector(63 downto 0);
    signal readData2: bit_vector(63 downto 0);
    signal memToRegMux: bit_vector(63 downto 0);


    --ALU
    signal ALUSrcMux: bit_vector(63 downto 0);
    signal ALUResult: bit_vector(63 downto 0);


    --SIGNEXTEND
    signal signExtToALU: bit_vector(63 downto 0);


    --SHIFTLEFT2
    signal shiftToPC: bit_vector(63 downto 0);


    begin
        --OUT SIGNALS
        instruction_int <= imOut;
        opcode <= imOut(31 downto 21);
        imAddr <= instructionAddress;
        --PROGRAM COUNTER
        PC: reg
        generic map(64)
        port map (
            clock, 
            reset, 
            '1', 
            nextAddress, 
            instructionAddress
        );

        ALU4: alu
        generic map(64)
        port map (
            instructionAddress,
            "0000000000000000000000000000000000000000000000000000000000000100",
            addressPlus4,
            "0010",
            open,
            open
        );

        ALUB: alu
        generic map(64)
        port map (
            instructionAddress, 
            shiftToPC, 
            addressBranch, 
            "0010", 
            open, 
            open
        );
        nextAddress <= addressPlus4 when (pcsrc = '0') 
            else addressBranch;

        --REGFILE
        REGBANK: regfile
        generic map(32, 64)
        port map (
            clock, 
            reset, 
            regWrite, 
            instruction_int (9 downto 5), 
            regMux, 
            instruction_int (4 downto 0), 
            memToRegMux, 
            readData1, 
            readData2
        );
        regMux <= instruction_int(20 downto 16) when (reg2loc = '0') 
            else instruction_int(4 downto 0);

        memToRegMux <= ALUResult when (memToReg = '0') 
            else dmOut;

        dmIn <= readData2;

        --ULA
        ALUMAIN: alu
        generic map(64)
        port map (
            readData1, 
            ALUSrcMux, 
            ALUResult, 
            aluCtrl, 
            zero, 
            open, 
            open
        );
        ALUSrcMux <= readData2 when (aluSrc = '0') 
        else signExtToALU;

        dmAddr <= ALUResult;

        --SIGNEXTEND
        SIGNEXT: signExtend
        port map (
            instruction_int, 
            signExtToALU
        );

        --SHIFTLEFT2
        SHIFTLEFT: Shiftleft2
        port map (
            signExtToALU, 
            clock, 
            shiftToPC
        );

end architecture fluxoDados_arch;
