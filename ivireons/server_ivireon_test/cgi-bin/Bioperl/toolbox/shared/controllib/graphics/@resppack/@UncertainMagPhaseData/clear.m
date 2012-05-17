function clear(this)
%CLEAR  Clears data.

%  Author(s): Craig Buhr
%  Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:19 $

[this.Data.Frequency] = deal([]);
[this.Data.Magnitude] = deal([]);
[this.Data.Phase] = deal([]);

this.Bounds = struct(...
    'Frequency', [], ...
    'UpperMagnitudeBound', [], ...
    'LowerMagnitudeBound', [],...
    'UpperPhaseBound', [], ...
    'LowerPhaseBound', []);

this.Ts = [];