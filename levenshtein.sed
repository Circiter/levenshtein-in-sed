#!/bin/sed -Enf

# The Levenshtein distance in sed.
# Usage: echo -e 'string_1\nstring_2' | ./levenshtein.sed

# Stored at https://github.com/Circiter/levenshtenin-in-sed

# (C) Implemented by Circiter (mailto:xcirciter@gmail.com)
# License: MIT.

# Issues: very slow.

# Definition of the Levenshtein distance between two strings A
# and B (N.B., strings are indexed from 1):
#
# distance(A, B)=D(|A|, |B|)
#
# D(i, j) = 0, if i=0, j=0
#         = i, if j=0, i>0
#         = j, if i=0, j>0
#         = min(D(i, j-1)+1, D(i-1, j)+1, D(i-1, j-1)+m(A_i, B_j)), if j>0, i>0
#
# m(a, b) = 0, if a=b
#         = 1, if a!=b
#
# min(x, y, z) = min(min(x, y), z)

# Examples:
#  distance("polynomial", "exponential")=6 # Performance issues.
#  distance("s", "a")=1
#  distance("s", "tttt")=4
#  distance("s", "s")=0
#  distance("pol", "pop")=1
#  distance("xx", "xy")=1
#  distance("slow", "fast")=4

:r $!{N; br}; s/\n$//

# Push the lengths of the given string onto the [emulated] stack
# (calculate the lengths by replacing each character by 1).
h; x
:to_unary
    s/^(1*)[^\n1]/\11/
    s/[^\n1](1*)$/1\1/
    /^1*\n1*$/! bto_unary
x; G

s/$/\nreturn_0/; bdistance

# N.B., it uses the memoization technique [in attempt] to speed things up.
:distance
    # Try to reuse the value already calculated.
    /^[^\n]*\n[^\n]*\n.*<(1*),(1*)=1*>.*\n\1\n\2\n[^\n]*$/ {
        s/^([^\n]*\n[^\n]*\n.*<)(1*),(1*)=(1*)(>.*\n)\2\n\3(\n[^\n]*)$/\1\2,\3=\4\5\4\6/
        breturn
    }

    # The TOS contains a return address; bring
    # the i, j arguments before current TOS and
    # duplicate this arguments..
    s/(\n1*\n1*)(\n[^\n]*)$/\2\1\1/
    # [ ... return i j i j ] # <-- Current structure of the stack.

    /\n11*\n11*$/ bmore_interesting
    s/\n(\n11*)$/\1/ # D(i=0, j>0)=j.
    s/\n$// # D(i>0, j=0)=i or D(i=0, j=0)=0.
    bend
    :more_interesting

    # If i>0 and j>0 then...

    # Duplicate two top element in the stack.
    s/\n1*\n1*$/&&/
    # Stack: [ ... return i j i j i j ]

    # Calculate D(i, j-1)+1.
    s/1$// # Decrement j.
    s/$/\nreturn_1/; bdistance; :return_1 # Make a recursive call.
    s/$/1/ # Increment the TOS.
    # [ return i j i j value1 ]

    # Bring the i, j arguments before current TOS and duplicate this pair.
    s/(\n1*\n1*)(\n1*)$/\2\1\1/
    # [ return i j value1 i j i j ]

    # Calculate D(i-1, j)+1.
    s/\n1(1*\n1*)$/\n\1/ # Decrement i.
    s/$/\nreturn_2/; bdistance; :return_2
    s/$/1/ # Increment the TOS.
    # [ return i j value1 i j value2 ]

    # "Rotate" the stack again (put the i and j before the TOS).
    s/(\n1*\n1*)(\n1*)$/\2\1/
    # [ return i j i j value1 value2 i j ]

    # Duplicate the pair of top values in the stack.
    s/\n1*\n1*$/&&/
    # [ return i j value1 value2 i j i j ]

    # Calculate D(i-1, j-1)+m(S_1[i], S_2[j]).
    s/(\n1*)1(\n1*)1$/\1\2/ # Decrement both i and j.
    s/$/\nreturn_3/; bdistance; :return_3
    # [ return i j value1 value2 i j value3 ]

    # Calculate m(S_1[i], S_2[j]).

    h # Backup the strings.
    :scan
        s/\n1(1*\n1*\n1*)$/\n\1/ # Decrement i.
        /\n11*\n1*\n1*$/ {
            s/^[^\n]([^\n])/\1/ # Consume one symbol of the first string.
            bscan
        }
        s/\n1(1*\n1*)$/\n\1/ # Decrement j.
        /\n11*\n1*$/ {
            s/^([^\n]*\n)[^\n]([^\n])/\1\2/ # Consume one symbol of the second string.
            bscan
        }

    # Remove the last i and j from the stack
    s/\n1*\n1*(\n1*)$/\1/
    # [ return i j value1 value2 value3 ]

    # Increment the TOS if S_1[i]!=S_2[j].
    /^(.)[^\n]*\n\1[^\n]*\n/! s/$/1/

    # Restore the processed strings.
    s/^[^\n]*\n[^\n]*\n// # Remove a remnants of the damaged strings.
    # Remove all the but first two strings from the hold space.
    x; s/^([^\n]*\n[^\n]*\n).*$/\1/; x
    G # Copy the backuped strings to the pattern space.
    # Move the restored strings to the beginning of the buffer.
    s/^(.*)\n([^\n]*\n[^\n]*\n)$/\2\1/

    # Find the minimum between the 3 topmost items of the stack.

    # First, find the minimum of the 2 topmost elements.
    s/$/\nreturn_4/; bminimum; :return_4
    # [ return i j value1 min1 ]

    # Next, find the minimum between the remaining two items.
    s/$/\nreturn_5/; bminimum; :return_5
    # [ return i j min ]

    # The TOS contains the minimum now.

    :end

    # Add new entry to the memoization matrix.
    s/^([^\n]*\n[^\n]*\n)(.*\n)(1*)\n(1*)\n(1*)$/\1<\3,\4=\5>\n\2\5/

    :return
    s/(\n[^\n]*)(\n1*)$/\2\1/ # Swap

    /\nreturn_1$/ {s/\n[^\n]*$//; breturn_1}
    /\nreturn_2$/ {s/\n[^\n]*$//; breturn_2}
    /\nreturn_3$/ {s/\n[^\n]*$//; breturn_3}

s/^.*\n(1*)\n[^\n]*$/\1/ # Remove all the data except the final result.

# Print the result in decimal.
x; s/^.*$/0/; x

:print
    /./! {x; p; q}

    x
    # Increment the content of the hold buffer.

    :replace s/9(_*)$/_\1/; treplace # Replace all leading 9s by _.
    s/^(_*)$/0\1/ # Append 0 if there are no digts left.

    s/^/0123456789@/ # Add a lookup table.
    :increment
        s/(.)(.)(@.*)\1(_*)$/\1\3\2\4/ # Increment the last digit.
        tdigit_incremented
        s/.@/@/
        :digit_incremented
        /..@/bincrement # Repeat until the lookup table is empty.

    s/^.*@// # There is no need in the lookup table anymore.

    s/_/0/g # Replace all the _ by 0s.
    x; s/1// # Decrement the unary number.
    bprint

# Find the minimum among the two topmost items on the stack.
:minimum
    # The TOS contains a return address; do the swap.
    s/(\n1*\n1*)(\n[^\n]*)$/\2\1/ # Swap.

    h; x; s/^.*\n(1*\n1*)$/\1/

    :two_minimum
        /^\n/ {x; s/\n1*$//; bok} # Second element is minimal.
        /\n$/ {x; s/\n1*(\n1*)$/\1/; bok} # First element is minimal.
        s/^1//; s/1$//
        btwo_minimum
    :ok

    s/(\n[^\n]*)(\n1*)$/\2\1/ # Swap.

    /\nreturn_4$/ {s/\n[^\n]*$//; breturn_4}
    /\nreturn_5$/ {s/\n[^\n]*$//; breturn_5}
