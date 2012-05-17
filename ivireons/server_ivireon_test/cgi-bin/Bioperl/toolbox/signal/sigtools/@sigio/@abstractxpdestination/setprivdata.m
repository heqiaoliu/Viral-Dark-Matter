function datamodel = setprivdata(this, datamodel)
%SETPRIVDATA

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:44:08 $

% Create a listener to the Data property
l  = handle.listener(datamodel, 'VectorChanged', @prop_listener);
set(l, 'CallbackTarget', this);
set(this, 'VectorChangedListener', l);

prop_listener(this);

% -------------------------------------------------------
function prop_listener(this, eventData)

if ~isempty(this.data)
    % Call an API method to update the concrete classes based on new data.
    newdata(this);
end

% [EOF]
