function out = setcurrentdest(this, out)
%SETCURRENTDEST SetFunction for CurrentDestination property.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/05/20 03:10:42 $

ad = get(this,'AvailableDestinations');
ac = get(this,'AvailableConstructors');

if  any([isempty(ad) isempty(ac)]),
    return;
else
    % Try to find the destination string
    idx = strmatch(lower(out),lower(ad));
    if isempty(idx), 
        idx = 1; 
        msgid = generatemsgid('destinationNotAvail');
        warning(msgid,'The destination %s is not available for this data.',out);
    end
    out = ad{idx};
end

% Set the appropriate destination object
setdestobj(this, ac{idx});

this.isapplied = false;

% [EOF]