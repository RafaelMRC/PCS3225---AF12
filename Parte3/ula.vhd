
library IEEE;
use IEEE.numeric_bit.all;

entity ula is
    port(
        A: in bit_vector(63 downto 0); -- entrada A
        B: in bit_vector(63 downto 0); -- entrada B
        S: in bit_vector(3 downto 0); -- seleciona operacao
        F: out bit_vector(63 downto 0); -- saida
        Z: out bit;                     -- flag zero
        Ov: out bit;                    -- flag overflow
        Co: out bit                     -- flag carry out
    );
end entity ula;

architecture ula_arch of ula is

    -- componente ula1bit
    component ula1bit is
        port(
            a           : in  bit;
            b           : in  bit;
            cin         : in bit;
            ainvert     : in bit;
            binvert     : in bit;
            operation   : in bit_vector (1 downto 0);
            result      : out bit;
            cout        : out bit;
            overflow    : out bit
        );
    end component ula1bit;
    
    type cables is array (0 to 63) of bit;
    signal carryCable: cables; --FIOS CONECTANDO OS COUT'S DA ALUi AOS CIN'S DA ALUi+1
    signal zeroCheck: cables; --VERIFICACAO DE ZERO
    signal ovfCheck: cables; --VERIFICACAO DE OVERFLOW
    
    signal check: bit_vector(63 downto 0); --AUXILIAR
    signal zeroComp: bit_vector(63 downto 0); --AUXILIAR

    signal subtraction: bit; --COLOCA CIN EM '1' NA PRIMEIRA ALU CASO A SUBTRACAO A-B ESTEJA SELECIONADA

    begin 

        ALU_GEN: for i in 0 to 63 generate

            LOWERBIT: if i = 0 generate
                ALU0: alu1bit 
                port map (
                    A(0),
                    B(0),
                    zeroCheck(63),
                    subtraction,
                    check(0),
                    carryCable(0),
                    zeroCheck(0),
                    ovfCheck(0),
                    S(3),
                    S(2),
                    S(1 downto 0)
                );
            end generate LOWERBIT;

            MIDBITS: if (i /= 0 and i /= (63)) generate
                ALUX: alu1bit 
                port map (
                    A(i),
                    B(i),
                    '0',
                    carryCable(i-1),
                    check(i),
                    carryCable(i),
                    zeroCheck(i),
                    ovfCheck(i),
                    S(3),
                    S(2),
                    S(1 downto 0)
                );
            end generate MIDBITS;

            ENDBIT: if (i /= 0 and i = (63)) generate
                ALUF: alu1bit 
                port map (
                    A(63),
                    B(63),
                    '0',
                    carryCable(62),
                    check(63),
                    carryCable(63),
                    zeroCheck(63),
                    ovfCheck(63),
                    S(3),
                    S(2),
                    S(1 downto 0)
                );
            end generate ENDBIT;

        end generate ALU_GEN;

        Ov <= ovfCheck(63);
        Co <= carryCable(63);

        F <= check; 

        zeroComp <= (others => '0');

        Z <= '1' when (check = zeroComp) else
            '0'; 

        subtraction <= (S(2) and S(1)) or (S(3) and S(2)) ; --CIN = 1 PARA SLT, SUB OU AND
end architecture ula_arch;

