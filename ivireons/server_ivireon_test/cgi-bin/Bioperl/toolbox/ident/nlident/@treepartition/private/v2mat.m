function w=v2mat(v)
%*******************************************************************
% V2MAT transforms a column vector of the size dx(d+1)/2 into
%		a symmetric dxd matrix w. The inverse transform is implemented
%		in the m2vec()	function
% Usage:
% 	W=V2MAT(V);
% See also: m2vec.m
%******************************************************************

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:25:31 $

% Author(s): Anatoli Iouditski

v=v(:);
d=(sqrt(1+8*size(v,1))-1)/2;

w=zeros(d,d);
w(find(triu(ones(d))))=v;
tmp=w';
w(find(tril(ones(d))))=tmp(find(tril(ones(d))));
