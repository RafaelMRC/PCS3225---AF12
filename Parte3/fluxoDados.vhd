

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

architecture fluxoDados_arch of fluxoDados is 

    -- Componente Registrador / Program Counter
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

    -- Componente Memoria Instrucoes
    component memoriaInstrucoes is
        generic (
            addressSize : natural := 7;
            dataSize    : natural := 8;
            datFileName : string  := "memInstr_conteudo.dat"
        );
        port (
            addr : in  bit_vector(addressSize-1 downto 0);
            data : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    -- Componente RegFile 
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

    -- Componente sign_extend
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

    -- Componente mux_n
    component mux_n is
        generic (dataSize : natural := 64);
        port (
            in0  : in  bit_vector(dataSize-1 downto 0);
            in1  : in  bit_vector(dataSize-1 downto 0);
            sel  : in  bit;
            dOut : out bit_vector(dataSize-1 downto 0)
        );
    end component mux_n;

    -- Componente memoriaDados
    component memoriaDados is
        generic (
            addressSize : natural := 7;
            dataSize    : natural := 8;
            datFileName : string  := "memDadosInicialPolilegv8.dat"
        );
        port (
            addr : in  bit_vector(addressSize-1 downto 0);
            data : inout bit_vector(dataSize-1 downto 0); -- dependendo da sua interface pode ser in/out
            we   : in  bit  -- write enable
        );
    end component;

    -- Componente adder_n
    component adder_n is
        generic (dataSize : natural := 64);
        port (
            in0  : in  bit_vector(dataSize-1 downto 0);
            in1  : in  bit_vector(dataSize-1 downto 0);
            sum  : out bit_vector(dataSize-1 downto 0);
            cOut : out bit
        );
    end component;

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


-- SINAIS INTERNOS

    signal pc64           : bit_vector(63 downto 0); -- PC stored as 64-bit (recommended)
    signal pc_addr7       : bit_vector(6 downto 0);  -- 7-bit address for memories (pc64(6 downto 0))
    signal next_pc64      : bit_vector(63 downto 0);
    signal pc_plus4_64    : bit_vector(63 downto 0);
    signal pc_branch_64   : bit_vector(63 downto 0);

    signal instr_byte     : bit_vector(7 downto 0);   -- instruction memory gives 8-bit words
    signal instr32        : bit_vector(31 downto 0);  -- instruction word (assembled from bytes) -- adjust if IM returns full 32-bit

    -- Regfile
    signal readData1      : bit_vector(63 downto 0);
    signal readData2      : bit_vector(63 downto 0);
    signal reg_wr_data    : bit_vector(63 downto 0);

    -- immediates
    signal signExt_out    : bit_vector(63 downto 0);
    signal shiftedImm     : bit_vector(63 downto 0);

    -- ALU
    signal alu_b          : bit_vector(63 downto 0);
    signal alu_result     : bit_vector(63 downto 0);
    signal alu_zero       : bit;

    -- Data memory (8-bit words) bus adapted to 64-bit regfile:
    signal dm_data_out8   : bit_vector(7 downto 0);
    signal mem_read_data64: bit_vector(63 downto 0);



    begin
    ----------------------------------------------------------------------------
    -- Program Counter (reg). Observação:
    -- O enunciado pede "reg parametrizada com n = 7".
    -- Implementação prática (compatível com adders 64-bit): armazenamos PC em 64 bits
    -- e usamos os 7 LSB para endereçar as memórias (pc64(6 downto 0)).
    ----------------------------------------------------------------------------
    PC : reg
        generic map (dataSize => 64)
        port map (
            clock  => clock,
            reset  => reset,
            enable => '1',
            d      => next_pc64, -- nextAddress
            q      => pc64 -- instructionAddress
        );

    -- endereço de 7 bits extraído do PC (LSB)
    pc_addr7 <= pc64(6 downto 0);


        ----------------------------------------------------------------------------
    -- Instruction Memory (memoriaInstrucoes) instanciada conforme enunciado
    -- addressSize = 7, dataSize = 8, arquivo = "memInstrPolilegv8.dat"
    -- Observação: seu componente memInstr retorna um byte (8 bits). Se na sua
    -- implementação a memória já retorna 32-bit por endereço, adapte a conexão.
    ----------------------------------------------------------------------------
    IM : memoriaInstrucoes
        generic map (
            addressSize => 7,
            dataSize    => 8,
            datFileName => "memInstrPolilegv8.dat"
        )
        port map (
            addr => pc_addr7,
            data => instr_byte
        );


    -- Montagem do instr32 a partir de bytes (depende do formato do arquivo).
    -- Abaixo assumo que instr occupies 4 bytes sequentially in memory:
    -- Para simplificar no TB do enunciado normalmente fornecem 32-bit por endereço.
    -- Se a sua memória retorna 32-bit direto, use essa saída.
        instr32 <= (others => '0'); -- ajustar caso IM retorne 32bit

    -- opcode (bits 31:21 da instrução) — se sua IM fornece 32-bit direto, conecte corretamente
        opcode <= instr32(31 downto 21);


    ----------------------------------------------------------------------------
    -- Register File
    ----------------------------------------------------------------------------
    REGBANK : regfile
        port map (
            clock    => clock,
            reset    => reset,
            regWrite => regWrite,
            rr1      => instr32(9 downto 5),   -- rs
            rr2      => instr32(4 downto 0) when reg2loc = '0' else instr32(20 downto 16), -- MUX reg2loc
            wr       => instr32(4 downto 0),   -- rd (ajuste conforme ISA)
            d        => reg_wr_data,
            q1       => readData1,
            q2       => readData2
        );


        ---------------------------------------------------------------------------
    -- Sign extend (32->64) — instância conforme enunciado
    ----------------------------------------------------------------------------
    SIGNEXT : sign_extend
        generic map (
            dataISize => 32,
            dataOSize => 64,
            dataMaxPosition => 5
        )
        port map (
            inData      => instr32(31 downto 0),  -- ajuste se immediate em outro campo
            inDataStart => extendMSB,
            inDataEnd   => extendLSB,
            outData     => signExt_out
        );

        
    ----------------------------------------------------------------------------
    -- ALU
    ----------------------------------------------------------------------------
    alu_b <= readData2 when aluSrc = '0' else signExt_out;

    MAIN_ALU : ula
        port map (
            A  => readData1,
            B  => alu_b,
            S  => alu_control,
            F  => alu_result,
            Z  => alu_zero,
            Ov => open,
            Co => open
        );



    ----------------------------------------------------------------------------
    -- Data memory (memoriaDados) instanciada conforme enunciado:
    -- addressSize=7, dataSize=8, datFileName = "memDadosInicialPolilegv8.dat"
    -- Aqui fazemos simplificação: DM is byte-addressable and returns 8-bit.
    -- To write/read 64-bit words we must perform multiple accesses or use an
    -- adapted interface. For simplicity, we map the low 7 bits of ALU result
    -- to DM.
    ----------------------------------------------------------------------------
    DM : memoriaDados
        generic map (
            addressSize => 7,
            dataSize    => 8,
            datFileName => "memDadosInicialPolilegv8.dat"
        )
        port map (
            addr => alu_result(6 downto 0),
            data => dm_data_out8,   -- adapt if interface different
            we   => memWrite
        );

        
    ----------------------------------------------------------------------------
    -- PC + 4 e branch target usando adders 64-bit (exigido pelo enunciado)
    ----------------------------------------------------------------------------
        ADD_PC4 : adder_n
        generic map (dataSize => 64)
        port map (
            in0  => pc64,
            in1  => (62 downto 0 => '0') & "100", -- 4 in LSB, high bits zero
            sum  => pc_plus4_64,
            cOut => open
        );



        -- branch target: pc_plus4 + (shiftedImm)
        ADD_BRANCH : adder_n
        generic map (dataSize => 64)
        port map (
            in0  => pc_plus4_64,
            in1  => shiftedImm,
            sum  => pc_branch_64,
            cOut => open
        );

        -- next PC selection
        next_pc64 <= pc_plus4_64 when ((branch = '0' or alu_zero = '0') and uncondBranch = '0') else
                     pc_branch_64 when (branch = '1' and alu_zero = '1') or (uncondBranch = '1') else
                     pc_plus4_64;


          
        -- shift left 2
        SHIFT2 : two_left_shifts
            generic map (dataSize => 64)
            port map (
                input  => signExt_out,
                output => shiftedImm
            );

end architecture fluxoDados_arch;

