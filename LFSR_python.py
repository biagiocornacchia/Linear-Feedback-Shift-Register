import filecmp

seed = 0b1100101011000110
lfsr = seed
period = 0
outputstream = 0

#print("----------------------------------------------------------")
#print("{:016b}".format(lfsr), end="    ")
#print("BIT (XOR)        OUTPUT STREAM")
#print("----------------------------------------------------------")
print("+------------------------------------------------------+")
print("|                     LFSR PYTHON                      |")
print("+------------------------------------------------------+")
print("\n[!] INITIAL SEED: {:016b}".format(seed))

with open("LFSR_OUTPUT_STREAM_PYTHON.txt", "w") as f:

    f.write(str(lfsr & 1) + "\n")

    while True:
        # feedback: x^16 + x^14 + x^13 + x^11 + 1
        bit = (lfsr ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1
        lfsr = (lfsr >> 1) | (bit << 15)
        period += 1

        output_bit = lfsr & 1
        
        if (lfsr == seed):
            print("[!] OUTPUT PERIOD: " + str(period))
            break
        
        #print("{:016b}".format(lfsr), end="        ")
        #print(bit, end="                  ")
        #print(output_bit)

        f.write(str(output_bit) + "\n")
        outputstream = str(outputstream) + str(output_bit)

print("\nFirst 512 bits of the output stream:")
print(outputstream[0:512])

if(filecmp.cmp('LFSR_OUTPUT_STREAM_PYTHON.txt', 'modelsim/LFSR_OUTPUT_STREAM.txt')):
    print("\n[+] OUTPUT STREAM IS CORRECT")
else: 
    print("\n[-] OUTPUT STREAM IS WRONG!")