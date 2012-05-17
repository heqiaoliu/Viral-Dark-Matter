%ISNUMERIC True for numeric arrays.
%   ISNUMERIC(A) returns true if A is a numeric array and false otherwise. 
%
%   For example, integer and float (single and double) arrays are numeric,
%   while logicals, strings, cell arrays, and structure arrays are not.
%
%   Example:
%      isnumeric(pi)
%      returns true since pi has class double while
%      isnumeric(true)
%      returns false since true has data class logical.
%
%   See also ISA, DOUBLE, SINGLE, ISFLOAT, ISINTEGER, ISSPARSE, ISLOGICAL, ISCHAR.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/21 19:23:36 $

