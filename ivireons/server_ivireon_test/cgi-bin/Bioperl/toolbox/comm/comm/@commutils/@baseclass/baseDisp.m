function baseDisp(this, fieldNames, excludedFieldNames)
%BASEDISP Display object properties in the given order

%   @commsutils/@baseclass
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 15:57:00 $

% If this is a scalar, display properties in a predefined way, otherwise use the
% built-in display method
if isscalar(this)
    % build a structure with customized ordering of properties
    s = get(this);
    
    % Order the fields
    s = orderfields(s, fieldNames);
    
    % Remove excluded fields
    s = rmfield(s, excludedFieldNames);
    
    % display the resulting structure
    disp(s);
else
    builtin('disp', h);
end


%-------------------------------------------------------------------------------
% [EOF]