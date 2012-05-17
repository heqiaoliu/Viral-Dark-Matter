function filter_listener(hEH, eventData)
%FILTER_LISTENER Listener to the filter of the exportheader object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:14:52 $

update_variables(hEH);
update_datatype(hEH);

if isrendered(hEH),
    resetoperations(hEH);
end

% [EOF]
