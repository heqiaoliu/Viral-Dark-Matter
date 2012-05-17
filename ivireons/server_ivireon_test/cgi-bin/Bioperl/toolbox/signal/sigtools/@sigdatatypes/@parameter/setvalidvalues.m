function setvalidvalues(hPrm, vv)
%SETVALIDVALUES Change the valid values
%   SETVALIDVALUES(hPRM, VV) Change the valid values to VV.  This method works
%   only for parameters that store a cell of strings for their valid values.
%   The valid value vector must remain the same length.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2007/12/14 15:17:56 $

error(nargchk(2,2,nargin,'struct'));

% The function only applies if the old and new valid values are cells of strs
if ~iscellstr(vv),
    error(generatemsgid('MustBeAString'),'New valid values must be a cell of strings.');
end

oldvv = get(hPrm, 'AllOptions');
if ~iscellstr(oldvv),
    error(generatemsgid('MustBeAString'),'Old valid values must be a cell of strings.');
end
oldvv = {oldvv{:}};

if length(oldvv) ~= length(vv),
    error(generatemsgid('InvalidDimensions'),'New valid values must be the same length as the old valid values.');
end

if ~isequal(oldvv, vv),

    p = findprop(hPrm, 'Value');

    indx = find(strcmpi(hPrm.Value, oldvv));
    dindx = find(strcmpi(hPrm.DefaultValue, oldvv));
    
    delete(p);

    set(hPrm, 'AllOptions', vv);

    createvaluefromcell(hPrm);

    set(hPrm, 'Value', vv{indx});
    set(hPrm, 'DefaultValue', vv{dindx});

    send(hPrm, 'NewValidValues', handle.EventData(hPrm, 'NewValidValues'));
end

% [EOF]
