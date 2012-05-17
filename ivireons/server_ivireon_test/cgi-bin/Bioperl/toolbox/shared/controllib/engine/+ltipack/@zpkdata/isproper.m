function [boo,D] = isproper(D,varargin)
% Returns TRUE if model is proper.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:40 $
Mask = (D.k==0 | cellfun('length',D.z)<=cellfun('length',D.p));
boo = all(Mask(:));

