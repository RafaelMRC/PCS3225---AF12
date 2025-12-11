-----------------Sistemas Digitais II-------------------------------------
-- Arquivo   : reg.vhd
-- Projeto   : AF12 Parte 1 SDII 2025 - biblioteca de componentes para construção de um processador
-------------------------------------------------------------------------
-- Autores:     Grupo T2G07     
--      15637418 Guilherme Jun Gondo (Turma 1)
--      15487892 Samuel Henrique de Jesus da Silva (Turma 2)
--      15485340 Rafael Moreno Rachel Carvalho (Turma 1)
--      12684531 Antonio Torres Rocha (Turma 3)
-------------------------------------------------------------------------

entity reg is
    generic (dataSize: natural := 64); -- dataSize vai definir a largura de dados do registrador
    port (
        clock  : in  bit;
        reset  : in  bit;
        enable : in  bit;
        d      : in  bit_vector (dataSize-1 downto 0);
        q      : out bit_vector (dataSize-1 downto 0)
    );
end entity reg;


architecture arch_reg of reg is
    signal dado: bit_vector (dataSize-1 downto 0); -- bit_vector temporario, vai guardar valor D e depois jogar pra Q
begin
    process (clock, reset)
    begin
        if reset = '1' then 
            dado <= (others => '0'); -- Se reset = '1', todos os bits de valores vao ser iguais a '0'
        elsif (clock'event and clock = '1') then -- borda de subida
            if enable = '1' then -- habilita escrita, pro valor de entrada d chegar na saida q
                dado <= d;
            end if;
        end if;
    end process;
    q <= dado;
end architecture;
