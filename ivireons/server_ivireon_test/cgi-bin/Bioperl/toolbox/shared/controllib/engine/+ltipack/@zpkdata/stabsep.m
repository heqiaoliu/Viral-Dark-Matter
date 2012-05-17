function [D1,D2] = stabsep(D,varargin)
% Stable/unstable decomposition of ZPK models.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:33:56 $
[D1,D2] = stabsep(ss(D),varargin{:});
D1 = zpk(D1);   D2 = zpk(D2);
