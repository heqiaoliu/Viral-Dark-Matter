function fireDataChangeEvent(h,varargin)
%FIREDATACHANGEEVENT

% Copyright 2005-2006 The MathWorks, Inc.

if h.DataChangeEventsEnabled
    h.send('datachange',varargin{:});
end
