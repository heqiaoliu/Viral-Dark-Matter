function [D1,D2] = stabsep(D,varargin)
% Stable/unstable decomposition of transfer functions.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:33:01 $
[D1,D2] = stabsep(ss(D),varargin{:});
D1 = tf(D1);   D2 = tf(D2);
