function [Hbest,mrfflag] = optimizecoeffwl(this,varargin)
% This should be a private method.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:32:12 $

% Make sure to work with reference filter in case filter has been quantized
Href = reffilter(this);

try
    [Hbest,mrfflag] = optimizecoeffwlfir(this,Href,varargin{:});
catch ME
    error(ME.identifier,ME.message);
end




% [EOF]
