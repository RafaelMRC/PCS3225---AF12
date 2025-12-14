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
use std.textio.all;

entity memoriaInstrucoes is
    generic (
        addressSize : natural := 8; -- Quantas posições a memória aguenta
        dataSize    : natural := 8; -- Qual a largura de cada posição da memória
        datFileName : string  := "memInstr_conteudo.dat" -- De qual arquivo a memória vai ler os dados
    );
    port (
        addr : in  bit_vector (addressSize-1 downto 0); -- indice de posição de endereço do arquivo
        data : out bit_vector (dataSize-1 downto 0) -- conteúdo da posição de endereço
    );
end entity memoriaInstrucoes;


architecture memoriaInstrucoes_arch of memoriaInstrucoes is
    type mem_tipo is array (0 to (2**addressSize - 1)) -- Altura da memória, quantas posições ela possui
    of bit_vector (dataSize-1 downto 0); -- Largura de cada posição da memória

    impure function init_mem (nome_do_arquivo : in string) return mem_tipo is
        file arquivo : text open read_mode is nome_do_arquivo;
        variable linha : line;
        variable temp_bv  : bit_vector (dataSize-1 downto 0);
        variable temp_mem   : mem_tipo;
        variable i : natural := 0;
    begin
        while not endfile (arquivo) loop
            readline (arquivo, linha);
            read (linha, temp_bv);
            temp_mem(i) := temp_bv;
            i := i + 1;
        end loop;
        return temp_mem;
    end;

    signal mem : mem_tipo := init_mem (datFileName);

    begin
        data <= mem(to_integer(unsigned(addr))); -- data pega os dados encontrados na posição addr
end architecture memoriaInstrucoes_arch;