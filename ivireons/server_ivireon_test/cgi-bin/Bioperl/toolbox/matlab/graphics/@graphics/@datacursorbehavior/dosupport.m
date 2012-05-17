function [ret] = dosupport(~,hTarget)

% Copyright 2003-2009 The MathWorks, Inc.

% axes or axes children
ret = ~isempty(ancestor(hTarget,'Axes'));
