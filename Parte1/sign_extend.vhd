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


entity sign_extend is
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
end entity sign_extend;


architecture sign_extend_arch of sign_extend is
begin
    process(inData, inDataStart, inDataEnd)
        variable start_i  : integer;
        variable end_i    : integer;
        variable size_i   : integer;
        variable sign_bit : bit;
        variable temp     : bit_vector(dataOSize-1 downto 0);
    begin
        -- Converte os vetores de posicao para inteiro
        start_i := to_integer(unsigned(inDataStart));
        end_i   := to_integer(unsigned(inDataEnd));

        -- Quantidade de bits uteis
        size_i := start_i - end_i + 1;

        -- Bit de sinal (MSB do campo útil)
        sign_bit := inData(start_i);

        -- Inicializa tudo com o bit de sinal (ja faz a extensao)
        temp := (others => sign_bit);

        -- Copia o valor util para os bits menos significativos da saída
        temp(size_i-1 downto 0) := inData(start_i downto end_i);

        -- Liga na saida
        outData <= temp;
    end process;
end architecture sign_extend_arch;
