function v=m2vec(w);
%*******************************************************************
% Usage: V=M2VEC(W)
% M2VEC transforms a symmetric dxd matrix W into a column vector V 
%		of the size dx(d+1)/2. The inverse transform is implemented 
%		in the v2mat()	function 
%
% See also: 
%	v2mat
%******************************************************************

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:02:29 $

% Author(s): Anatoli Iouditski

v=w(find(reshape(triu(ones(size(w))),size(w,1)^2,1)));





