import os

seed_list = [0b1100101011000110 , 0b1101110010110101, 0b0001110010000101]

def check_correctnes(start_index, period):
    match_output = 1

    with open('LFSR_OUTPUT_STREAM_PYTHON.txt', "r") as output_python:
        with open('modelsim/LFSR_OUTPUT_STREAM.txt', "r") as file_modelsim:

            file_modelsim.seek(start_index*2) # Mult 2 is needed because files contain also the "\n"
            data_modelsim = file_modelsim.read(65535*2).splitlines()

            output_python.seek(start_index*2)
            data_python = output_python.read(65535*2).splitlines()
            
            for i in range(0, period):
                if(data_modelsim[i] != data_python[i]):
                    match_output = 0
                    break

            if(match_output == 0):
                print("[-] WRONG")
            else:
                print("[+] CORRECT")

            print("\n                             PHYTON                      MODELSIM")
            print("FIRST 5 OUTPUT BIT   " + str(data_python[0:5])+ "    " + str(data_modelsim[0:5]))
            print("LAST 5 OUTPUT BIT    " + str(data_python[period -5 : period]) + "    " + str(data_modelsim[period -5 : period]))   

##############################################################################################

def create_testbench():

    n_seed = len(seed_list)

    with open('modelsim/LFSR_SEED.txt', "w") as file_seed:
        for seed in seed_list:
            file_seed.write("{:016b}\n".format(seed).replace("0b", ""))

    with open('tb/LFSR_GEN_BY_PHYTON_tb.vhd', "w") as tb:
        tb.write(f"library IEEE;\nuse IEEE.std_logic_1164.all;\nuse IEEE.std_logic_textio.all;\nuse STD.textio.all;\n\nentity LFSR_PYTHON_tb is\nend LFSR_PYTHON_tb;\n\narchitecture rtl of LFSR_PYTHON_tb is	\n\n    file LFSR_OUTPUT : text is out \"LFSR_OUTPUT_STREAM.txt\";\n    file LFSR_INPUT : text is in \"LFSR_SEED.txt\";\n\n    -- Testbench Constants\n    constant T_CLK    : time      := 10 ns;\n    constant T_RESET  : time      := 20 ns;\n    constant Nbit     : positive  := 16;\n\n    -- Testbench Signals\n    signal output_bit_tb   : std_logic;\n    signal seed_tb         : std_logic_vector(0 to Nbit-1);\n    signal seed_load_tb    : std_logic := '0';\n    signal state_tb        : std_logic_vector(0 to Nbit-1);\n    signal clk_tb          : std_logic := '0'; \n    signal reset_n_tb      : std_logic := '0';\n    signal end_sim         : std_logic := '1';\n\n    -- Top level component declaration\n    component LFSR\n        generic (\n            Nbit    : positive  := 16\n        );\n        port (\n            clk         : in std_logic;\n            reset_n     : in std_logic;\n            seed        : in std_logic_vector(0 to Nbit-1);  \n            seed_load   : in std_logic;\n            state       : out std_logic_vector(0 to Nbit-1);\n            output_bit  : out std_logic\n        );\n    end component;\n\n    begin\n    clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2; \n    --reset_n_tb <= '1' after T_RESET;\n\n    -- LFSR instance\n    dut: LFSR\n    generic map(\n        Nbit    => Nbit\n    )\n    port map (\n        clk        => clk_tb,\n        reset_n    => reset_n_tb,\n        seed       => seed_tb, \n        seed_load  => seed_load_tb,\n        state      => state_tb,\n        output_bit => output_bit_tb\n    );\n\n    stimuli: process(clk_tb, reset_n_tb) \n\n    variable bit_to_write : line;\n    variable new_seed : line;\n    variable initial_value : std_logic_vector(0 to Nbit-1);\n    variable number_of_seeds : natural := 0;\n    \n    begin\n\n        if(reset_n_tb = '0') then\n\n            -- Reading a seed from the file\n            readline(LFSR_INPUT, new_seed);\n            read(new_seed, initial_value);\n\n            seed_tb <= initial_value;\n            reset_n_tb <= '1';\n            seed_load_tb <= '1';\n\n        elsif(rising_edge(clk_tb)) then\n            seed_load_tb <= '0';\n\n            -- When the current state is equal to the initial status (seed) it means that the LFSR will start generating the same output bits\n            if(state_tb = seed_tb and seed_load_tb = '0') then\n                number_of_seeds := number_of_seeds + 1;\n                reset_n_tb <= '0';\n            end if;\n\n            if(number_of_seeds = {n_seed}) then\n                end_sim <= '0';\n            end if;\n\n            if(seed_load_tb = '0') then\n                WRITE(bit_to_write, output_bit_tb);\n                WRITEline(LFSR_OUTPUT, bit_to_write);  \n            end if;\n        end if;\n\n    end process;       \n\nend rtl;")

    print("[+] New file for testbench create successfully!")

##############################################################################################

print("+------------------------------------------------------+")
print("|                     LFSR PYTHON                      |")
print("+------------------------------------------------------+")

if (os.path.exists("LFSR_OUTPUT_STREAM_PYTHON.txt")):
    print("[!] Deleting old file...")
    os.remove("LFSR_OUTPUT_STREAM_PYTHON.txt")

set_seed = input("[] Do you want to create the new testbench for ModelSim? [Y/N]: ")

if (set_seed == 'Y'):
    create_testbench()
    print("[] Add the new file 'tb/LFSR_GEN_BY_PHYTON_tb.vhd' into your project on ModelSim, compile it and run the testbench. After that you can continue the test.")
    
    continue_test = input("Continue? [Y/N] ")

if (set_seed == 'Y' and continue_test !='Y'):
    print("[+] Exiting...")
    exit() 

start_index = 0
end_index = 65535 # maximum period for this LFSR (should remain always the same)

for seed in seed_list:
    output_python = open("LFSR_OUTPUT_STREAM_PYTHON.txt", "a")
    print("\n[!] INITIAL SEED: {:016b}".format(seed))
    lfsr = seed
    period = 0
    outputstream = 0

    output_python.write(str(lfsr & 1) + "\n")

    while True:
        # feedback: x^16 + x^14 + x^13 + x^11 + 1
        bit = (lfsr ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1
        lfsr = (lfsr >> 1) | (bit << 15)
        period += 1

        output_bit = lfsr & 1
        
        if (lfsr == seed):
            output_python.close()
            
            #print("[!] START INDEX: " + str(start_index) + " | END INDEX: " + str(end_index) + " | PERIOD: " + str(period))
            check_correctnes(start_index, period)
            start_index = end_index
            end_index = end_index + period
            break

        output_python.write(str(output_bit) + "\n")
        outputstream = str(outputstream) + str(output_bit)

output_python.close()