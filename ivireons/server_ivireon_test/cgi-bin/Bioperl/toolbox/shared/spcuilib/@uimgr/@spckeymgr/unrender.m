function unrender(h, arg) %#ok
%UNRENDER <short description>
%   OUT = UNRENDER(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/02/02 13:12:07 $

h.hWidget.uninstall;
h.hWidget = []; 
% [EOF]
