function b = isplottable(h, varargin)
%ISPLOTTABLE

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:14 $

b = isa(h.Signal, 'Simulink.Timeseries');

% [EOF]