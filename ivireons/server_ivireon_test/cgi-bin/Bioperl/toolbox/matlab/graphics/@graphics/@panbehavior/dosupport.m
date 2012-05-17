function [ret] = dosupport(~,hTarget)

% Copyright 2004-2009 The MathWorks, Inc.

% axes 
ret = ishghandle(hTarget,'axes');
