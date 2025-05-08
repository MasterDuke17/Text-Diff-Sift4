# Text::Diff::Sift4
A Raku implementation of the common version of the Sift4 string distance algorithm (https://siderite.dev/blog/super-fast-and-accurate-string-distance.html).

## Synopsis
```raku
use Text::Diff::Sift4;

say sift4("string1", "string2");
# 1
```

## Description
An algorithm to compute the distance between two strings in O(n).
```raku
sift4(str s1, str s2, int maxOffset = 10, int maxDistance = 10 --> Int)
s1 and s2 are the strings to compare
maxOffset is the number of characters to search for matching letters
maxDistance is the distance at which the algorithm should stop computing the value and just exit (the strings are too different anyway)
```

## Copyright & License
Copyright 2025 Daniel Green.

This module may be used under the terms of the Artistic License 2.0.
