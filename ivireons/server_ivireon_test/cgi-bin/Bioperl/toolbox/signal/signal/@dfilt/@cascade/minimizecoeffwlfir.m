function Hbest = minimizecoeffwlfir(this,Href,varargin)
%   This should be a private method.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:32:22 $

Hbest = optimizecascade(this,Href,@minimizecoeffwl,varargin{:});

% [EOF]
