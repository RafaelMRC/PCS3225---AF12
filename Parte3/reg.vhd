entity reg is
    generic (dataSize: natural := 64);
    port (
        clock  : in  bit;
        reset  : in  bit;
        enable : in  bit;
        d      : in  bit_vector (dataSize-1 downto 0);
        q      : out bit_vector (dataSize-1 downto 0)
    );
end entity reg;


architecture arch_reg of reg is
    signal dado: bit_vector (dataSize-1 downto 0);
begin
    process (clock, reset)
    begin
        if reset = '1' then
            dado <= (others => '0');
            -- q <= (others => '0');
        elsif rising_edge (clock) then
            if enable = '1' then
                dado <= d;
                -- q <= d;
            end if;
        end if;
    end process;
    q <= dado;
end architecture;
