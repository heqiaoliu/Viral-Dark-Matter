function A = hdsSetSlice(A,Section,B)
%HDSSETSLICE  Modifies array slice.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:15:23 $
A(Section{:}) = B;