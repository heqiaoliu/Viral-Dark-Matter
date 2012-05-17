function class = set_class(this, class) %#ok<INUSL>
%SET_CLASS PreSet function for the 'Class' property

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:42:14 $

if ~(isequal(class,1) || isequal(class,2))
    error(generatemsgid('InvalidClassValue'), ...
        'Class must be equal to 1 or 2.');
    
end

% [EOF]
