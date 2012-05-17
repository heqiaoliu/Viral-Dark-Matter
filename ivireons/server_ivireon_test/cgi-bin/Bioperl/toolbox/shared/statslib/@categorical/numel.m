function e = numel(a,varargin)
%NUMEL Number of elements in a categorical array.
%   N = NUMEL(A) returns the number of elements in the categorical array A.
%
%   N = NUMEL(A, VARARGIN) returns the number of subscripted elements, N, in
%   A(index1, index2, ..., indexN), where VARARGIN is a cell array whose
%   elements are index1, index2, ... indexN.
%
%   See also CATEGORICAL/SIZE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:12 $

e = numel(a.codes,varargin{:});
