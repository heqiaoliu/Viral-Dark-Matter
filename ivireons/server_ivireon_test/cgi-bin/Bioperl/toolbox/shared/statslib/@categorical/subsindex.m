function i = subsindex(a)
%SUBSINDEX Subscript index for a categorical array.
%   I = SUBSINDEX(A) is called for the syntax 'X(A)' when A is a categorical
%   array and X is one of the built-in types (most commonly 'double').
%   SUBSINDEX returns the internal categorical level codes of A converted to
%   zero-based integer indices.
%
%   SUBSINDEX is invoked separately on all the subscripts in an expression
%   such as X(A,B).
%
%   Example:
%      load fisheriris
%      a = ordinal(species,[],unique(species));
%      colmeans = grpstats(meas,a,@mean);
%      residuals = meas - colmeans(a,:);
%  
%   See also CATEGORICAL, CATEGORICAL/DOUBLE.

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2008/12/01 07:41:24 $

i = double(a.codes) - 1;
