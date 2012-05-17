function [ret] = dosupport(~,hTarget)

% Copyright 2003-2010 The MathWorks, Inc.

% axes or axes children
ret = ~isempty(ancestor(hTarget,'axes'));
