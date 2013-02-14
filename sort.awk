#!/usr/bin/awk -f

# comparison function
# usage: __compare(a, b, how)
# compares "a" and "b" based on "how", returning 0 for false and 1 for true.
# required for all of the qsort() functions below
function __compare(a, b, how) {
  # standard comparisons
  if (how == "std asc") {
    return a < b;
  } else if (how == "std desc") {
    return a > b;

  # force string comps
  } else if (how == "str asc") {
    return "a" a < "a" b;
  } else if (how == "str desc") {
    return "a" a > "a" b;

  # force numeric
  } else if (how == "num asc") {
    return +a < +b;
  } else if (how == "num desc") {
    return +a > +b;
  }
}

# comparison function for the *psort* functions
# usage: __pcompare(a, b, patterns, max, how)
# compares "a" and "b" based on "patterns" and "how", returning 0 for false and
# 1 for true. "patterns" is an indexed array of regexes, from 1 through "max".
# each regex takes priority over subsequent regexes, followed by non-matching
# values. required for all of the psort() functions below
function __pcompare(a, b, pattens, plen, how,    p) {
  # loop over each regex in order, and check if either value matches
  for (p=1; p<=plen; p++) {
    # if the first matches...
    if (a ~ p) {
      # check if the second also matches. if so, do a normal comparison
      if (b ~ p) {
        return __compare(a, b, how);

      # if the second doesn't match, the first sorts higher
      } else {
        return 1;
      }

    # if the second matches but the first didn't, the second sorts higher
    } else if (b ~ p) {
      return 0;
    }
  }

  # no patterns matched, do a normal comparison
  return __compare(a, b, how);
}

# actual sorting function
# sorts the values in "array" in-place, from indices "left" to "right", based
# on the comparison mode "how" (see the qsort() description).
# required for all of the qsort() functions below
function __quicksort(array, left, right, how,    piv, mid, tmp) {
  # return if array contains one element or less
  if ((right - left) <= 0) {
    return;
  }

  # choose random pivot
  piv = int(rand() * (right - left + 1)) + left;

  # swap left and pivot
  tmp = array[piv];
  array[piv] = array[left];
  array[left] = tmp;
  
  mid = left;
  # iterate over each element from the second to the last, and compare
  for (piv=left+1; piv<=right; piv++) {
    # if the comparison based on "how" is true...
    if (__compare(array[piv], array[left], how)) {
      # increment mid
      mid++;

      # swap mid and pivot
      tmp = array[piv];
      array[piv] = array[mid];
      array[mid] = tmp;
    }
  }

  # swap left and mid
  tmp = array[mid];
  array[mid] = array[left];
  array[left] = tmp;
  
  # recursively sort the two halves
  __quicksort(array, left, mid - 1, how);
  __quicksort(array, mid + 1, right, how);
}

# actual sorting function for the qsortv() function
# sorts the indices in "array" on the original values in "values", from indices
# "left" to "right", based on the comparison mode "how" (see the qsortv()
# description)
# required for the qsortv() function below
function __vquicksort(array, values, left, right, how,    piv, mid, tmp) {
  # return if array contains one element or less
  if ((right - left) <= 0) {
    return;
  }

  # choose random pivot
  piv = int(rand() * (right - left + 1)) + left;

  # swap left and pivot
  tmp = array[piv];
  array[piv] = array[left];
  array[left] = tmp;
  tmp = values[piv];
  values[piv] = values[left];
  values[left] = tmp;
  
  mid = left;
  # iterate over each element from the second to the last, and compare
  for (piv=left+1; piv<=right; piv++) {
    # if the comparison based on "how" is true...
    if (__compare(values[piv], values[left], how)) {
      # increment mid
      mid++;

      # swap mid and pivot
      tmp = array[piv];
      array[piv] = array[mid];
      array[mid] = tmp;
      tmp = values[piv];
      values[piv] = values[mid];
      values[mid] = tmp;
    }
  }

  # swap left and mid
  tmp = array[mid];
  array[mid] = array[left];
  array[left] = tmp;
  tmp = values[mid];
  values[mid] = values[left];
  values[left] = tmp;
  
  # recursively sort the two halves
  __vquicksort(array, values, left, mid - 1, how);
  __vquicksort(array, values, mid + 1, right, how);
}

# actual sorting function for the *psort* functions
# sorts the values in "array" in-place, from indices "left" to "right", based
# on "how" and the array "patterns" (see the psort() description)
# required for all of the psort() functions below
function __pquicksort(array, left, right, patterns, plen, how,
                      piv, mid, tmp) {
  # return if array contains one element or less
  if ((right - left) <= 0) {
    return;
  }

  # choose random pivot
  piv = int(rand() * (right - left + 1)) + left;

  # swap left and pivot
  tmp = array[piv];
  array[piv] = array[left];
  array[left] = tmp;
  
  mid = left;
  # iterate over each element from the second to the last, and compare
  for (piv=left+1; piv<=right; piv++) {
    # if the comparison based on "how" is true...
    if (__pcompare(array[piv], array[left], patterns, plen, how)) {
      # increment mid
      mid++;

      # swap mid and pivot
      tmp = array[piv];
      array[piv] = array[mid];
      array[mid] = tmp;
    }
  }

  # swap left and mid
  tmp = array[mid];
  array[mid] = array[left];
  array[left] = tmp;
  
  # recursively sort the two halves
  __pquicksort(array, left, mid - 1, patterns, plen, how);
  __pquicksort(array, mid + 1, right, patterns, plen, how);
}

# actual shuffle function
# shuffles the values in "array" in-place, from indices "left" to "right".
# required for all of the shuf() functions below
function __shuffle(array, left, right,    r, i, tmp) {
  # loop backwards over the elements
  for (i=right; i>left; i--) {
    # generate a random number between the start and current element
    r = int(rand() * (i - left + 1)) + left;

    # swap current element and randomly generated one
    tmp = array[i];
    array[i] = array[r];
    array[r] = tmp;
  }
}



## usage: qsort(s, d [, how])
## sorts the elements in the array "s" using awk's normal rules for comparing
## values, creating a new sorted array "d" indexed with sequential integers
## starting with 1. returns the length, or -1 if an error occurs.. leaves the
## indices of the source array "s" unchanged. the optional string "how" controls
## the direction and the comparison mode. uses the quick sort algorithm, with a
## random pivot to avoid worst-case behavior on already sorted arrays. requires
## the __compare() and __quicksort() functions.
## valid values for "how" are:
##   "std asc"
##     use awk's standard rules for comparison, ascending. this is the default
##   "std desc"
##     use awk's standard rules for comparison, descending.
##   "str asc"
##     force comparison as strings, ascending.
##   "str desc"
##     force comparison as strings, descending.
##   "num asc"
##     force a numeric comparison, ascending.
##   "num desc"
##     force a numeric comparison, descending.
function qsort(array, out, how,    count, i) {
  # make sure how is correct
  if (length(how)) {
    if (how !~ /^(st[rd]|num) (a|de)sc$/) {
      return -1;
    }

  # how was not passed, use the default
  } else {
    how = "std asc";
  }
  
  # loop over each index, and generate a new array with the same values and
  # sequential indices
  count = 0;
  for (i in array) {
    out[++count] = array[i];
  }

  # seed the random number generator
  srand();

  # actually sort
  __quicksort(out, 1, count, how);

  # return the length
  return count;
}

## usage: iqsort(s [, how])
## the bevavior is the same as that of qsort(), except that the array "s" is
## sorted in-place. the original indices are destroyed and replaced with
## sequential integers. everything else is described in qsort() above.
function iqsort(array, how,    tmp, count, i) {
  # make sure how is correct
  if (length(how)) {
    if (how !~ /^(st[rd]|num) (a|de)sc$/) {
      return -1;
    }

  # how was not passed, use the default
  } else {
    how = "std asc";
  }
  
  # loop over each index, and generate a new array with the same values and
  # sequential indices
  count = 0;
  for (i in array) {
    tmp[++count] = array[i];
    delete array[i];
  }

  # copy tmp back over array
  for (i=1; i<=count; i++) {
    array[i] = tmp[i];
    delete tmp[i];
  }

  # seed the random number generator
  srand();

  # actually sort
  __quicksort(array, 1, count, how);

  # return the length
  return count;
}

## usage: qsorti(s, d [, how])
## the behavior is the same as that of qsort(), except that the array indices
## are used for sorting, not the array values. when done, the new array is
## indexed numerically, and the values are those of the original indices.
## everything else is described in qsort() above.
function qsorti(array, out, how,    count, i) {
  # make sure how is correct
  if (length(how)) {
    if (how !~ /^(st[rd]|num) (a|de)sc$/) {
      return -1;
    }

  # how was not passed, use the default
  } else {
    how = "std asc";
  }

  # loop over each index, and generate a new array with the original indices
  # mapped to new numeric ones
  count = 0;
  for (i in array) {
    out[++count] = i;
  }

  # seed the random number generator
  srand();

  # actually sort
  __quicksort(out, 1, count, how);

  # return the length
  return count;
}

## usage: iqsorti(s [, how])
## the bevavior is the same as that of qsorti(), except that the array "s" is
## sorted in-place. the original indices are destroyed and replaced with
## sequential integers. everything else is described in qsort() and qsorti()
## above.
function iqsorti(array, how,    tmp, count, i) {
  # make sure how is correct
  if (length(how)) {
    if (how !~ /^(st[rd]|num) (a|de)sc$/) {
      return -1;
    }

  # how was not passed, use the default
  } else {
    how = "std asc";
  }

  # loop over each index, and generate a new array with the original indices
  # mapped to new numeric ones
  count = 0;
  for (i in array) {
    tmp[++count] = i;
    delete array[i];
  }

  # copy tmp back over the original array
  for (i=1; i<=count; i++) {
    array[i] = tmp[i];
    delete tmp[i];
  }

  # seed the random number generator
  srand();

  # actually sort
  __quicksort(array, 1, count, how);

  # return the length
  return count;
}

## usage: qsortv(s, d [, how])
## sorts the indices in the array "s" based on the values, creating a new
## sorted array "d" indexed with sequential integers starting with 1, and the
## values the indices of "s". returns the length, or -1 if an error occurs.
## leaves the source array "s" unchanged. the optional string "how" controls
## the direction and the comparison mode. uses the quicksort algorithm, with a
## random pivot to avoid worst-case behavior on already sorted arrays. requires
## the __compare() and __vquicksort() functions. valid values for "how" are
## explained in the qsort() function above.
function qsortv(array, out, how,    values, count, i) {
  # make sure how is correct
  if (length(how)) {
    if (how !~ /^(st[rd]|num) (a|de)sc$/) {
      return -1;
    }

  # how was not passed, use the default
  } else {
    how = "std asc";
  }

  # loop over each index, and generate two new arrays: the original indices
  # mapped to numeric ones, and the values mapped to the same indices
  count = 0;
  for (i in array) {
    count++;
    out[count] = i;
    values[count] = array[i];
  }

  # seed the random number generator
  srand();

  # actually sort
  __vquicksort(out, values, 1, count, how);

  # return the length
  return count;
}



## usage: psort(s, d, patts, max [, how])
## sorts the values of the array "s", based on the rules below. creates a new
## sorted array "d" indexed with sequential integers starting with 1. "patts"
## is a compact (*non-sparse) 1-indexed array containing regular expressions.
## "max" is the length of the "patts" array. returns the length of the "d"
## array. "how" is explained in qsort() above. uses the quicksort algorithm,
## with a random pivot to avoid worst-case behavior on already sorted arrays.
## requires the __compare() and __pquicksort() functions.
##
##  Sorting rules:
##  - When sorting, values matching an expression in the "patts" array will
##    take priority over any other values
##  - Each expression in the "patts" array will have priority in ascending
##    order by index. "patts[1]" will have priority over "patts[2]" and
##    "patts[3]", etc
##  - Values both matching the same regex will be compared as usual
##  - All non-matching values will be compared as usual
function psort(array, out, patterns, plen, how,    count, i) {
  # make sure how is correct
  if (length(how)) {
    if (how !~ /^(st[rd]|num) (a|de)sc$/) {
      return -1;
    }

  # how was not passed, use the default
  } else {
    how = "std asc";
  }
  
  # loop over each index, and generate a new array with the same values and
  # sequential indices
  count = 0;
  for (i in array) {
    out[++count] = array[i];
  }

  # seed the random number generator
  srand();

  # actually sort
  __pquicksort(out, 1, count, patterns, plen, how);

  # return the length
  return count;
}

## usage: ipsort(s, patts, max [, how])
## the bevavior is the same as that of psort(), except that the array "s" is
## sorted in-place. the original indices are destroyed and replaced with
## sequential integers. everything else is described in psort() above.
function ipsort(array, patterns, plen, how,    tmp, count, i) {
  # make sure how is correct
  if (length(how)) {
    if (how !~ /^(st[rd]|num) (a|de)sc$/) {
      return -1;
    }

  # how was not passed, use the default
  } else {
    how = "std asc";
  }
  
  # loop over each index, and generate a new array with the same values and
  # sequential indices
  count = 0;
  for (i in array) {
    tmp[++count] = array[i];
    delete array[i];
  }

  # copy tmp back over array
  for (i=1; i<=count; i++) {
    array[i] = tmp[i];
    delete tmp[i];
  }

  # seed the random number generator
  srand();

  # actually sort
  __pquicksort(array, 1, count, patterns, plen, how);

  # return the length
  return count;
}

## usage: psorti(s, d, patts, max [, how])
## the behavior is the same as that of psort(), except that the array indices
## are used for sorting, not the array values. when done, the new array is
## indexed numerically, and the values are those of the original indices.
## everything else is described in psort() above.
function psorti(array, out, patterns, plen, how,    count, i) {
  # make sure how is correct
  if (length(how)) {
    if (how !~ /^(st[rd]|num) (a|de)sc$/) {
      return -1;
    }

  # how was not passed, use the default
  } else {
    how = "std asc";
  }

  # loop over each index, and generate a new array with the original indices
  # mapped to new numeric ones
  count = 0;
  for (i in array) {
    out[++count] = i;
  }

  # seed the random number generator
  srand();

  # actually sort
  __pquicksort(out, 1, count, patterns, plen, how);

  # return the length
  return count;
}

## usage: ipsorti(s, patts, max [, how])
## the bevavior is the same as that of psorti(), except that the array "s" is
## sorted in-place. the original indices are destroyed and replaced with
## sequential integers. everything else is described in psort() and psorti()
## above.
function ipsorti(array, patterns, plen, how,    tmp, count, i) {
  # make sure how is correct
  if (length(how)) {
    if (how !~ /^(st[rd]|num) (a|de)sc$/) {
      return -1;
    }

  # how was not passed, use the default
  } else {
    how = "std asc";
  }

  # loop over each index, and generate a new array with the original indices
  # mapped to new numeric ones
  count = 0;
  for (i in array) {
    tmp[++count] = i;
    delete array[i];
  }

  # copy tmp back over the original array
  for (i=1; i<=count; i++) {
    array[i] = tmp[i];
    delete tmp[i];
  }

  # seed the random number generator
  srand();

  # actually sort
  __pquicksort(array, 1, count, patterns, plen, how);

  # return the length
  return count;
}



## usage: shuf(s, d)
## shuffles the array "s", creating a new shuffled array "d" indexed with
## sequential integers starting with one. returns the length, or -1 if an error
## occurs. leaves the indices of the source array "s" unchanged. uses the knuth-
## fisher-yates algorithm. requires the __shuffle() function.
function shuf(array, out,    count, i) {
  # loop over each index, and generate a new array with the same values and
  # sequential indices
  count = 0;
  for (i in array) {
    out[++count] = array[i];
  }

  # seed the random number generator
  srand();

  # actually shuffle
  __shuffle(out, 1, count);

  # return the length
  return count;
}

## usage: ishuf(s)
## the behavior is the same as that of shuf(), except the array "s" is sorted
## in-place. the original indices are destroyed and replaced with sequential
## integers. everything else is described in shuf() above.
function ishuf(array,    tmp, count, i) {
  # loop over each index, and generate a new array with the same values and
  # sequential indices
  count = 0;
  for (i in array) {
    tmp[++count] = array[i];
    delete array[i];
  }

  # copy tmp back over array
  for (i=1; i<=count; i++) {
    array[i] = tmp[i];
    delete tmp[i];
  }

  # seed the random number generator
  srand();

  # actually shuffle
  __shuffle(array, 1, count);

  # return the length
  return count;
}

## usage: shufi(s, d)
## the bevavior is the same as that of shuf(), except that the array indices
## are shuffled, not the array values. when done, the new array is indexed
## numerically, and the values are those of the original indices. everything
## else is described in shuf() above.
function shufi(array, out,    count, i) {
  # loop over each index, and generate a new array with the original indices
  # mapped to new numeric ones
  count = 0;
  for (i in array) {
    out[++count] = i;
  }

  # seed the random number generator
  srand();

  # actually shuffle
  __shuffle(out, 1, count);

  # return the length
  return count;
}

## usage: ishufi(s)
## the behavior is tha same as that of shufi(), except that the array "s" is
## sorted in-place. the original indices are destroyed and replaced with
## sequential integers. everything else is describmed in shuf() and shufi()
## above.
function ishufi(array,    tmp, count, i) {
  # loop over each index, and generate a new array with the original indices
  # mapped to new numeric ones
  count = 0;
  for (i in array) {
    tmp[++count] = i;
    delete array[i];
  }

  # copy tmp back over the original array
  for (i=1; i<=count; i++) {
    array[i] = tmp[i];
    delete tmp[i];
  }

  # seed the random number generator
  srand();

  # actually shuffle
  __shuffle(array, 1, count);

  # return the length
  return count;
}



# Copyright Daniel Mills <dm@e36freak.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
