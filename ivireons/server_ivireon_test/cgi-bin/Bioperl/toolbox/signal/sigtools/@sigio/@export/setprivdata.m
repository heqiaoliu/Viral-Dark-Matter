function datamodel = setprivdata(this, datamodel)
%SETPRIVDATA

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:44:57 $

l = handle.listener(datamodel, 'VectorChanged', @lclvectorchanged_listener);
set(l, 'CallbackTarget', this);
set(this, 'VectorChangedListener', l);

% -------------------------------------------------------------------------
function lclvectorchanged_listener(this, eventData)

if ~isempty(eventData.Source),
    setupdestinations(this);
end

% [EOF]
