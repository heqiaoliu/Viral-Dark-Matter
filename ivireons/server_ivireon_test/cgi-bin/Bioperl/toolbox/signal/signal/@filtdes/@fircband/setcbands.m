function out  = setcbands(hObj, out)
%SETCBANDS Private pre-set function

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/04/21 16:30:36 $

% Cache the old ConstrainedBands in case the set fails.
oldcb = get(hObj, 'ConstrainedBands');

set(hObj, 'privConstrainedBands', out);

out = [];

try
    filterType_listener(hObj);
catch ME
    
    % If the object failed to update properly reset the constrainedbands
    set(hObj, 'privConstrainedBands', oldcb);
    
    estr = ME.message;
    eid = ME.identifier;
    if isempty(eid), error(cleanerrormsg(estr));
    else,            error(eid, cleanerrormsg(estr)); end
end

% [EOF]
