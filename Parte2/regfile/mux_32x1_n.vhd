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

entity mux_32x1_n is
    generic (
        constant BITS: integer := 64
    );
    port (
        D0    : in  bit_vector (BITS-1 downto 0);
        D1    : in  bit_vector (BITS-1 downto 0);
        D2    : in  bit_vector (BITS-1 downto 0);
        D3    : in  bit_vector (BITS-1 downto 0);
        D4    : in  bit_vector (BITS-1 downto 0);
        D5    : in  bit_vector (BITS-1 downto 0);
        D6    : in  bit_vector (BITS-1 downto 0);
        D7    : in  bit_vector (BITS-1 downto 0);
        D8    : in  bit_vector (BITS-1 downto 0);
        D9    : in  bit_vector (BITS-1 downto 0);
        D10    : in  bit_vector (BITS-1 downto 0);
        D11    : in  bit_vector (BITS-1 downto 0);
        D12    : in  bit_vector (BITS-1 downto 0);
        D13    : in  bit_vector (BITS-1 downto 0);
        D14    : in  bit_vector (BITS-1 downto 0);
        D15    : in  bit_vector (BITS-1 downto 0);
        D16    : in  bit_vector (BITS-1 downto 0);
        D17    : in  bit_vector (BITS-1 downto 0);
        D18    : in  bit_vector (BITS-1 downto 0);
        D19    : in  bit_vector (BITS-1 downto 0);
        D20    : in  bit_vector (BITS-1 downto 0);
        D21    : in  bit_vector (BITS-1 downto 0);
        D22    : in  bit_vector (BITS-1 downto 0);
        D23    : in  bit_vector (BITS-1 downto 0);
        D24    : in  bit_vector (BITS-1 downto 0);
        D25    : in  bit_vector (BITS-1 downto 0);
        D26    : in  bit_vector (BITS-1 downto 0);
        D27    : in  bit_vector (BITS-1 downto 0);
        D28    : in  bit_vector (BITS-1 downto 0);
        D29    : in  bit_vector (BITS-1 downto 0);
        D30    : in  bit_vector (BITS-1 downto 0);
        D31    : in  bit_vector (BITS-1 downto 0);

        SEL   : in  bit_vector (4 downto 0);
        SAIDA : out bit_vector (BITS-1 downto 0)
    );
end entity;

architecture comportamental of mux_32x1_n is
begin
    SAIDA <= D31 when (SEL = "11111") else
             D30 when (SEL = "11110") else
             D29 when (SEL = "11101") else
             D28 when (SEL = "11100") else
             D27 when (SEL = "11011") else
             D26 when (SEL = "11010") else
             D25 when (SEL = "11001") else
             D24 when (SEL = "11000") else
             D23 when (SEL = "10111") else
             D22 when (SEL = "10110") else
             D21 when (SEL = "10101") else
             D20 when (SEL = "10100") else
             D19 when (SEL = "10011") else
             D18 when (SEL = "10010") else
             D17 when (SEL = "10001") else
             D16 when (SEL = "10000") else
             D15 when (SEL = "01111") else
             D14 when (SEL = "01110") else
             D13 when (SEL = "01101") else
             D12 when (SEL = "01100") else
             D11 when (SEL = "01011") else
             D10 when (SEL = "01010") else
             D9 when (SEL = "01001") else
             D8 when (SEL = "01000") else
             D7 when (SEL = "00111") else
             D6 when (SEL = "00110") else
             D5 when (SEL = "00101") else
             D4 when (SEL = "00100") else
             D3 when (SEL = "00011") else
             D2 when (SEL = "00010") else
             D1 when (SEL = "00001") else
             D0 when (SEL = "00000") else
             (others => '0');
end architecture comportamental;

