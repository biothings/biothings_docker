################################################################################
# scramble-data.py
################################################################################
# Author: Greg Taylor (greg.k.taylor@gmail.com)
# Description:  The following script randomizes data from various data
# sources preserving the relationships between objects but hiding their
# orignal values.  Without the orignal dataset for reference, the values are
# non-recoverable.
################################################################################

################################################################################
# usage:  python randomize-data.py input-file-name >output-file-name
################################################################################

from random import shuffle
import string
import sys


# Generate dictionary to be used for shuffling
lowercase = list(string.ascii_lowercase)
uppercase = list(string.ascii_uppercase)
digits = list(string.digits)
# Copy the lists by value
permuted_lowercase = lowercase[:]
permuted_uppercase = uppercase[:]
permuted_digits = digits[:]
# Shuffle the new lists
shuffle(permuted_lowercase)
shuffle(permuted_uppercase)
shuffle(permuted_digits)

# Create a dictionary mapping all values to random ones
mapping = {}
for i in range(0, len(lowercase)):
    mapping[lowercase[i]] = permuted_lowercase[i]
    mapping[uppercase[i]] = permuted_uppercase[i]
for i, key in enumerate(string.digits):
    mapping[key] = permuted_digits[i]

# Read in all lines of the sample data
filename = sys.argv[1]
with open(filename) as f:
    for c in f.read():
        # if the character is in the mapping permutation, then change it
        if c in mapping.keys():
            sys.stdout.write(mapping[c])
        # otherwise just write the character
        else:
            sys.stdout.write(c)
