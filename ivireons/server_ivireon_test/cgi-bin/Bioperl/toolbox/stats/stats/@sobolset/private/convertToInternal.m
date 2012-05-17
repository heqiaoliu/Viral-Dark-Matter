function X = convertToInternal(X)
%CONVERTTOINTERNAL Convert double numbers to internal representation.
%
%   X = CONVERTTOINTERNAL(X) converts a double array of fractions into an
%   internal representation for use in the sequence generation.  This
%   function is normally used on a single point, to create a suitable start
%   value for the algorithm.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:21:28 $

X = X.*(2^53);
X = uint64(X);
