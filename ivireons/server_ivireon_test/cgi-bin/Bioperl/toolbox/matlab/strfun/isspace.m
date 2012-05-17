%ISSPACE True for white space characters.
%   For a string S, ISSPACE(S) returns an array the same size as S 
%   containing logical 1 (TRUE) where the elements of S are
%   Unicode-represented whitespace characters and logical 0 (FALSE) where
%   they are not.  
%
%   White space characters for which ISSPACE returns TRUE include tab, line
%   feed, vertical tab, form feed, carriage return, and space, in addition
%   to a number of other Unicode characters. 
%
%   Example
%      isspace('  Find spa ces ')
%      Columns 1 through 13 
%         1   1   0   0   0   0   1   0   0   0   1   0   0
%      Columns 14 through 15 
%         0   1
%     
%   See also ISLETTER.
 
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.9.4.5 $  $Date: 2009/09/03 05:25:28 $

%   Built-in function.

