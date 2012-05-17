function out = setavailconstr(h,out)
%SETAVAILCONSTR SetFunction for AvailableConstructors property.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:44:50 $

if isempty(out),
    return;
else
    set(h,'privAvailableConstructors',out);
end

out = [];

% [EOF]