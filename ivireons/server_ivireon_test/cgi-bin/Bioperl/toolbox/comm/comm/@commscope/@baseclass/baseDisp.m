function baseDisp(this, fieldNames, excludedFieldNames)
%BASEDISP Display object properties in the given order

%   @commscope/@baseclass

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/06/11 15:56:56 $

% If this is a scalar, display properties in a predefined order, otherwise, use
% the built-in display method
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
    builtin('disp', this);
end

%-------------------------------------------------------------------------------
% [EOF]