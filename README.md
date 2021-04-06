# levenshtein-in-sed

The Levenshtein distance in [GNU] sed.

Returns the numerical value of the shortest edit distance between given strings
(without obtaining an actual edit script, which would be much harder to implement
in sed.)

Reference: http://en.wikipedia.org/wiki/edit_distance

Read the script `levenshtein.sed` for details. :)

A naive reference implementation in C can be found in the file `reference.c`.
You can compile it with e.g., `gcc -o reference reference.c` and use it to
check a results returned by the sed-script.

(C) Author of the script: Circiter (mailto:xcirciter@gmail.com)

Repository: https://github.com/Circiter/levenshtein-in-sed

License: MIT.
