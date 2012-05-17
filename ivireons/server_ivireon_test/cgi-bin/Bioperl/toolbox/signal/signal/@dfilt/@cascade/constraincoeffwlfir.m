function Hd = constraincoeffwlfir(this,Href,WL,varargin)
%CONSTRAINCOEFFWLFIR Constrain coefficient wordlength.
%   This should be a private method.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:32:19 $


Hd = optimizecascade(this,Href,{@constraincoeffwl,WL},varargin{:});


% [EOF]
