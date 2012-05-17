function Hd = optimizestopbandfir(this,Href,WL,varargin)
%OPTIMIZESTOPBANDFIR Optimize stopband.
%   This should be a private method.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:32:24 $


Hd = optimizecascade(this,Href,{@maximizestopband,WL},varargin{:});


% [EOF]
