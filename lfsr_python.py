import filecmp

start_state = 0b0000101011000110 #0b01100011010000
lfsr = start_state
period = 0

print("----------------------------------------------------------")
print("{:016b}".format(lfsr), end="    ")
print("BIT (XOR)        OUTPUT STREAM")
print("----------------------------------------------------------")

with open("output.txt", "w") as f:
    while True:
        #taps: 16 14 13 11; feedback polynomial: x^16 + x^14 + x^13 + x^11 + 1
        bit = (lfsr ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1
        lfsr = (lfsr >> 1) | (bit << 15)
        period += 1

        prova = lfsr & 1

        print("{:016b}".format(lfsr), end="        ")
        print(bit, end="                  ")
        print("{:b}".format(prova), end="\n")

        if (period == 15):
            break

        f.write(str(bit) + "\n")
        
        if (lfsr == start_state):
            print(period)
            break

#print(filecmp.cmp('output.txt', 'shift_reg_out.tv'))