%CONV2 Two dimensional convolution.
%   C = CONV2(A, B) performs the 2-D convolution of matrices A and B.
%   If [ma,na] = size(A), [mb,nb] = size(B), and [mc,nc] = size(C), then
%   mc = max([ma+mb-1,ma,mb]) and nc = max([na+nb-1,na,nb]).
%
%   C = CONV2(H1, H2, A) convolves A first with the vector H1 along the
%   rows and then with the vector H2 along the columns. If n1 = length(H1)
%   and n2 = length(H2), then mc = max([ma+n1-1,ma,n1]) and 
%   nc = max([na+n2-1,na,n2]).
%
%   C = CONV2(..., SHAPE) returns a subsection of the 2-D
%   convolution with size specified by SHAPE:
%     'full'  - (default) returns the full 2-D convolution,
%     'same'  - returns the central part of the convolution
%               that is the same size as A.
%     'valid' - returns only those parts of the convolution
%               that are computed without the zero-padded edges.
%               size(C) = max([ma-max(0,mb-1),na-max(0,nb-1)],0).
%
%   See also CONV, CONVN, FILTER2 and, in the Signal Processing
%   Toolbox, XCORR2.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 5.21.4.5 $  $Date: 2008/08/20 22:57:06 $
%   Built-in function.

