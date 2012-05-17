function [rto, errmsg] = runtimeObjects(this)
%RUNTIMEOBJECTS Return the run time objects.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:25 $

signals = get(this, 'Signals');

if isempty(signals)
    rto    = [];
    errmsg = 'There are no selected signals.';
else
    [rto, errmsg] = runtimeObjects(signals);
end

% [EOF]
