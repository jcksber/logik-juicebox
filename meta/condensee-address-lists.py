#!/usr/bin/env python3
import os

print(os.getcwd())

#get first snapshot
file_to_open = dream-chasers1.txt
with open(file_to_open, "r") as a_file:
	counter1 = 0
	addresses1 = []
	for line in a_file:
		stripped_line = line.strip()
		if stripped_line not in addresses1:
			addresses1.append(stripped_line)
			# print(stripped_line)
			counter1 += 1

#get next snapshot
next_file_to_open = "dream-chasers2.txt"

with open(next_file_to_open, "r") as a_file:
	counter2 = 0
	addresses2 = []
	for line in a_file:
		stripped_line = line.strip()
		if stripped_line not in addresses2:
			addresses2.append(stripped_line)
			# print(stripped_line)
			counter2 += 1


#compare snapshots for duplicates
condensed_snap_shot = []
new_address_counter = 0
#if the address isnt in the the previous snapshot then its new
for addy2 in addresses2:
	if addy2 not in addresses1:
		condensed_snap_shot.append(addy2)
		new_address_counter += 1

print("Count")
print(new_address_counter)
print("\n\nAddresses")
print(condensed_snap_shot)

'''
Condensensed snapshots as of 1.14.22

Count
8

Addresses 
condensened_snap_shot = [0xb6936f5790cabC64772bc3b15ba9F7Ef73cCbf29, 0x7e824e1BA47eAE465fa9BC50b4b48E8E78eD8700, 0xF363D487CAeE0e8D92a6670A755e534F0ff8f109, 0xdCe8b8C7260AFd32C258B9fEfF832234ac589bcC, 0x7A283F1F302A0285BC9D7E8bD26C83979fE3F075, 0xa075Da3F8c25018792366e4F4b3029a7083DB718, 0x1cE73DaC8B6128d0d2e34A3289BEf234368bC5F0, 0x97acef8388579e8641EA82258044E8996337ABEb]
'''










