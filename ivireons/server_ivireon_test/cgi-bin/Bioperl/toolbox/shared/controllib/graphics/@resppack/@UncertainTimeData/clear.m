function clear(this)
%CLEAR  Clears data.

%  Author(s): Craig Buhr
%  Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:49:32 $

[this.Data.Time] = deal([]);
[this.Data.Amplitude] = deal([]);

this.Bounds = struct(...
    'Time', [], ...
    'UpperAmplitudeBound', [], ...
    'LowerAmplitudeBound', []);

this.Ts = [];