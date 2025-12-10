--
--
--

entity mux_n is
    generic ( dataSize : natural := 64);
    port (
        in0    :   in bit_vector (dataSize-1 downto 0); -- entrada de dados 0
        in1    :   in bit_vector (dataSize-1 downto 0); -- entrada de dados 1
        sel    :   in bit ;
        dOut    :   out bit_vector (dataSize-1 downto 0) -- saida de dados
    );
end entity mux_n;

architecture with_select of mux_n is
begin
    with sel select
    dOut <= in0 when '0',
            in1 when '1',
            (others => '0') when others;
end architecture with_select;