function [ret] = dosupport(hThis,hTarget)

% Copyright 2004 The MathWorks, Inc.

% axes or axes child
ret = ~isempty(ancestor(hTarget,'axes'));
