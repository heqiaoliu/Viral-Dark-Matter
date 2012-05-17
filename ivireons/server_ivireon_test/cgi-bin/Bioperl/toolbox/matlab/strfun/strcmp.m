%STRCMP Compare strings.
%   TF = STRCMP(S1,S2) compares the strings S1 and S2 and returns logical 1
%   (true) if they are identical, and returns logical 0 (false) otherwise.  
%
%   TF = STRCMP(S,C), compares string S to each element of cell array C,
%   where S is a character vector (or a 1-by-1 cell array) and C is a cell 
%   array of strings. The function returns TF, a logical array that is the 
%   same size as C and contains logical 1 (true) for those elements of C 
%   that are a match, and logical 0 (false) for those elements that are not. 
%   The order of the two input arguments is not important.
%
%   TF = STRCMP(C1,C2) compares each element of C1 to the same element in C2, 
%   where C1 and C2 are equal-size cell arrays of strings. Input C1 and/or C2 
%   can also be a character array having the number of rows as there are 
%   cells in the cell array. The function returns TF, a logical array that
%   is the same size as C1 or C2, and contains logical 1 (true) for those 
%   elements of C1 and C2 that are a match, and logical 0 (false) for those
%   elements that are not.
%
%   When one of the inputs is a cell array, scalar expansion occurs as 
%   needed.
%
%   STRCMP supports international character sets.
%
%   See also STRNCMP, STRCMPI, STRFIND, DEBLANK, REGEXP.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.17.4.11 $  $Date: 2009/11/16 22:27:30 $
%   Built-in function.


