#!/usr/bin/env python3
import os

print(os.getcwd())

file_to_open = 'dream-chasers.txt'

with open(file_to_open, "r") as a_file:
	counter = 0
	addresses = []
	for line in a_file:
		stripped_line = line.strip()
		if stripped_line not in addresses:
			# addresses.append(stripped_line)
			print(stripped_line)
			counter += 1

