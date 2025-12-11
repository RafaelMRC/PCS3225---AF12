library ieee;
use ieee.numeric_bit.all;

entity tb_regfile is
end entity;

architecture testbench of tb_regfile is

  component regfile
    port (
      clock     : in  bit;
      reset     : in  bit;
      regWrite  : in  bit;
      rr1       : in  bit_vector(4 downto 0);
      rr2       : in  bit_vector(4 downto 0);
      wr        : in  bit_vector(4 downto 0);
      d         : in  bit_vector(63 downto 0);
      q1        : out bit_vector(63 downto 0);
      q2        : out bit_vector(63 downto 0)
    );
  end component;

  constant clkPeriod : time := 10 ns;

  signal clk       : bit := '0';
  signal reset     : bit := '0';
  signal regWrite  : bit := '0';
  signal rr1, rr2  : bit_vector(4 downto 0);
  signal wr        : bit_vector(4 downto 0);
  signal d, q1, q2 : bit_vector(63 downto 0);

  -- padrões de teste 64 bits
  type test_array is array (natural range <>) of bit_vector(63 downto 0);
  constant patterns : test_array :=
  (
    X"0000000000000000",
    X"FFFFFFFFFFFFFFFF",
    X"0F0F0F0F0F0F0F0F",
    X"AAAAAAAAAAAAAAAA"
  );

begin

  -- clock
  clk <= not clk after clkPeriod/2;

  -- DUT
  DUT: regfile
    port map (
      clock     => clk,
      reset     => reset,
      regWrite  => regWrite,
      rr1       => rr1,
      rr2       => rr2,
      wr        => wr,
      d         => d,
      q1        => q1,
      q2        => q2
    );

  stimulus: process
  begin
    report "=== INICIO DO TESTE DO REGFILE 32x64 ===";

    ----------------------------------------------------
    -- TESTE 1: RESET
    ----------------------------------------------------
    reset <= '1';
    regWrite <= '0';
    wait for 20 ns;
    reset <= '0';

    for i in 0 to 31 loop
      rr1 <= bit_vector(to_unsigned(i,5));
      rr2 <= bit_vector(to_unsigned(i,5));
      wait for 10 ns;

      assert (q1 = X"0000000000000000")
        report "ERRO: Reset falhou no registrador " & integer'image(i)
        severity error;
    end loop;

    report "OK: Reset funcionando";

    ----------------------------------------------------
    -- TESTE 2: ESCRITA E LEITURA
    ----------------------------------------------------
    for p in patterns'range loop
      d <= patterns(p);

      for i in 0 to 31 loop
        wr  <= bit_vector(to_unsigned(i,5));
        rr1 <= bit_vector(to_unsigned(i,5));
        rr2 <= bit_vector(to_unsigned(i,5));

        regWrite <= '1';
        wait until rising_edge(clk);
        regWrite <= '0';
        wait for 5 ns;

        if i = 0 then
          -- X0 deve continuar zero
          assert q1 = X"0000000000000000"
            report "ERRO: X0 foi alterado!"
            severity error;
        else
          assert q1 = patterns(p)
            report "ERRO: Escrita falhou no registrador " & integer'image(i)
            severity error;
        end if;
      end loop;
    end loop;

    report "OK: Escrita e leitura funcionando";

    ----------------------------------------------------
    -- TESTE 3: LEITURA DUPLA SIMULTÂNEA
    ----------------------------------------------------
    rr1 <= bit_vector(to_unsigned(5,5));
    rr2 <= bit_vector(to_unsigned(10,5));
    wait for 10 ns;

    assert (q1 = patterns(patterns'high))
      report "ERRO: Leitura rr1 falhou"
      severity error;

    assert (q2 = patterns(patterns'high))
      report "ERRO: Leitura rr2 falhou"
      severity error;

    report "OK: Leitura dupla funcionando";

    ----------------------------------------------------
    report "=== TODOS OS TESTES FINALIZADOS COM SUCESSO ===";
    wait;
  end process;

end architecture;
