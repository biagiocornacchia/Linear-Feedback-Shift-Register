import filecmp

start_state = 0b1100101011000110
lfsr = start_state
period = 0

print("----------------------------------------------------------")
print("{:016b}".format(lfsr), end="    ")
print("BIT (XOR)        OUTPUT STREAM")
print("----------------------------------------------------------")

with open("output.txt", "w") as f:

    f.write(str(lfsr & 1) + "\n")

    while True:
        #taps: 16 14 13 11; feedback polynomial: x^16 + x^14 + x^13 + x^11 + 1
        bit = (lfsr ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1
        lfsr = (lfsr >> 1) | (bit << 15)
        period += 1

        output_bit = lfsr & 1

        #if (period == 15):
        #    break
        
        if (lfsr == start_state):
            print(period)
            break

        print("{:016b}".format(lfsr), end="        ")
        print(bit, end="                  ")
        print(output_bit)

        f.write(str(output_bit) + "\n")

print(filecmp.cmp('output.txt', 'LFSR_OUT.tv'))