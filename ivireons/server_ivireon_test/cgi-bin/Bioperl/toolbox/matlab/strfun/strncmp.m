%STRNCMP Compare first N characters of strings.
%   TF = STRNCMP(S1,S2,N) performs a case-sensitive comparison between the
%   first N characters of strings S1 and S2. The function returns logical 1 
%   (true) if they are the same and returns logical 0 (false) otherwise.  
%
%   TF = STRNCMP(S,C,N) performs a case-sensitive comparison between the 
%   first N characters of string S and the first N characters in each element 
%   of cell array C. Input S is a character vector (or 1-by-1 cell array), and
%   input C is a cell array of strings. The function returns TF, a logical 
%   array that is the same size as C and contains logical 1 (true) for those 
%   elements of C that are a match, and logical 0 (false) for those elements 
%   that are not. The order of the two input arguments is not important.
%
%   TF = STRNCMP(C1,C2,N) performs a case-sensitive comparison between the 
%   first N characters of each element of cell array C1 and the first N 
%   characters of the same element in cell array C2. Inputs C1 and C2 are 
%   equal-size cell arrays of strings. Input C1 and/or C2 can also be a 
%   character array having the same number of rows as there are cells in the 
%   cell array. The function returns TF, a logical array that is the same size
%   as C1 or C2, and contains logical 1 (true) for those elements of C1 and C2 
%   that are a match, and logical 0 (false) for those elements that are not.
%
%   When one of the inputs is a cell array, scalar expansion will occur as 
%   needed.
%
%   STRNCMP supports international character sets.
%
%   See also STRCMP, STRCMPI, STRNCMPI, REGEXP.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.16.4.12 $  $Date: 2009/11/16 22:27:35 $
%   Built-in function.


