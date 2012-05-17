function [ret] = dosupport(~,hTarget)

% Copyright 2003-2009 The MathWorks, Inc.

% axes 
ret = ishghandle(hTarget,'axes');
