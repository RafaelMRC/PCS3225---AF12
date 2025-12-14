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

entity ula is
    port(
        A: in bit_vector(63 downto 0); -- entrada A
        B: in bit_vector(63 downto 0); -- entrada B
        S: in bit_vector(3 downto 0);
-- seleciona operacao
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
    
    -- Sinais internos
    signal carry       : bit_vector(64 downto 0); -- ripple carry
    signal result_int  : bit_vector(63 downto 0); -- resultado interno

    signal ainvert_s   : bit;
    signal binvert_s   : bit;
    signal operation_s: bit_vector(1 downto 0);

begin

    ----------------------------------------------------------------
    -- Decodificação dos sinais de controle
    --
    -- Convenção adotada (compatível com ULA clássica):
    -- S(3) = Ainvert
    -- S(2) = Binvert
    -- S(1 downto 0) = operação
    ----------------------------------------------------------------
    ainvert_s    <= S(3);
    binvert_s    <= S(2);
    operation_s <= S(1 downto 0);

    ----------------------------------------------------------------
    -- Carry inicial
    -- Para subtração (A + ~B + 1), binvert = 1 e cin inicial = 1
    ----------------------------------------------------------------
    carry(0) <= binvert_s;

    ----------------------------------------------------------------
    -- Geração das 64 ULAs de 1 bit (ripple-carry)
    ----------------------------------------------------------------
    GEN_ALU : for i in 0 to 63 generate
        ALU_i : ula1bit
            port map (
                a         => A(i),
                b         => B(i),
                cin       => carry(i),
                ainvert   => ainvert_s,
                binvert   => binvert_s,
                operation => operation_s,
                result    => result_int(i),
                cout      => carry(i+1),
                overflow  => open
            );
    end generate GEN_ALU;

    F <= result_int; -- Saída principal

    Co <= carry(64); -- Flag Carry Out (carry do bit mais significativo)

    -- Flag Overflow (carry into MSB XOR carry out MSB)
    -- Válido para operações aritméticas
    Ov <= carry(63) xor carry(64);

      Z <= '1' when result_int = (result_int'range => '0') else '0';


end architecture ula_arch;
