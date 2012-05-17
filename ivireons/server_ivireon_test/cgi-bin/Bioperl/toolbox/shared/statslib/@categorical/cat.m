%CAT Concatenate categorical arrays.
%   C = CAT(DIM, A, B, ...) concatenates the categorical arrays A, B, ...
%   along dimension DIM.  All inputs must have the same size except along
%   dimension DIM.  The set of categorical levels for C is the sorted union of
%   the sets of levels of the inputs, as determined by their labels.
%
%   See also CATEGORICAL/HORZCAT, CATEGORICAL/VERTCAT.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:36 $

% This is an abstract method.