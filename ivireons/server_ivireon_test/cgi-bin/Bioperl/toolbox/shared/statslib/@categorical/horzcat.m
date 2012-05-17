%HORZCAT Horizontal concatenation for categorical arrays.
%   C = HORZCAT(A, B, ...) horizontally concatenates the categorical arrays A,
%   B, ... .  For matrices, all inputs must have the same number of rows.  For
%   N-D arrays, all inputs must have the same sizes except in the second
%   dimension.  The set of categorical levels for C is the sorted union of the
%   sets of levels of the inputs, as determined by their labels.
%
%   C = HORZCAT(A,B) is called for the syntax [A B].
%
%   See also CATEGORICAL/CAT, CATEGORICAL/VERTCAT.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:53 $

% This is an abstract method.