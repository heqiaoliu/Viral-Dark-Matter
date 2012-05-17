function this = tsdata(signals)
%TSDATA   constructs a tsdata object containing SIGNALS
% 
%    SIGNALS can be Simulink.ModelDataLogs or a cell array of
%    Simulink.Timeseries. GETDATA will always return an array of
%    structs to callers
%


%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:31 $

this = fxptds.tsdata;
this.signals = signals;

% [EOF]