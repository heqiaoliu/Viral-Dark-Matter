function l = addNewDataListener(this, callbackFunction)
%ADDNEWDATALISTENER Add a listener to 'NewData'

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:37 $

l = handle.listener(this, this.findprop('DataBuffer'), ...
    'PropertyPostSet', makeCallback(this, callbackFunction));

% -------------------------------------------------------------------------
function cb = makeCallback(this, callbackFunction)

cb = @(h, ev) onNewData(this, callbackFunction);

% -------------------------------------------------------------------------
function onNewData(this, callbackFunction)

if ~isempty(this.DataBuffer) && any([this.DataBuffer.end] ~= 0)
    callbackFunction(this);
end

% [EOF]
