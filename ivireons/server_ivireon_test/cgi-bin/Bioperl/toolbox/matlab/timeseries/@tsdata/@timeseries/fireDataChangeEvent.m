function fireDataChangeEvent(h,varargin)
%FIREDATACHANGEEVENT  Fire datachange event

%   Author(s): James Owen
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/27 23:08:22 $

if h.DataChangeEventsEnabled
    if nargin>=2
        h.send('datachange',varargin{1});
    else % Must include the source in the dataChangeEvent
        h.send('datachange',tsdata.dataChangeEvent(h,[],[]));
    end
end