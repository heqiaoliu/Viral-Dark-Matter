function P = get_values(h,dummy)
%GETVARIABLENAMES GetFunction for the VariableNames property.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:27:23 $

lvh = getcomponent(h, '-class', 'siggui.labelsandvalues');
P = get(lvh,'Values');

% [EOF]
