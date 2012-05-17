function abstractModDisp(h, fn)
%ABSTRACTMODDISP Display object properties in the given order

%   @modem/@abstractModDisp

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 15:57:07 $

% If h is a scalar, display properties in a predefined order, otherwise, use the
% built-in display method
if isscalar(h)
    % build a structure with customized ordering of properties
    s = get(h);
    s = orderfields(s, fn);
    
    % display the resulting structure
    disp(s);
else
    builtin('disp', h);
end
%-------------------------------------------------------------------------------
% [EOF]