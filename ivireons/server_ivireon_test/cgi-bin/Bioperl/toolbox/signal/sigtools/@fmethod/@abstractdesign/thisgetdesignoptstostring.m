function [sOut, fnOut] = thisgetdesignoptstostring(this, s, fn) %#ok<INUSL>
%THISGETDESIGNOPTSTOSTRING
    
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/11/13 05:03:49 $

% Do nothing. Let the subclass remove more fields by overriding this method.
sOut = s;
fnOut = fn;
