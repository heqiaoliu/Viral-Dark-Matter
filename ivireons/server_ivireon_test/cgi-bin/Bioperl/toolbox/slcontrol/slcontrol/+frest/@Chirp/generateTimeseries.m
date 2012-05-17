function out = generateTimeseries(obj)
% GENERATETIMESERIES Generate MATLAB timeseries for the specified chirp
% input signal
%
%   insig = generateTimeseries(in) generates the MATLAB timeseries object
%   which captures the actual data corresponding to the specified chirp
%   input signal in.
%
%   See also frestimate, frest.Chirp.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2009/11/09 16:35:03 $

tfinal = (obj.Ts*(obj.NumSamples-1));
time = 0:obj.Ts:tfinal;

data = obj.Amplitude*chirp(time,...
    unitconv(obj.FreqRange(1),obj.FreqUnits,'Hz'),tfinal,unitconv(obj.FreqRange(2),obj.FreqUnits,'Hz'),...
    obj.SweepMethod,obj.InitialPhase,obj.Shape);
% Wrap in a Timeseries object
out = timeseries(data(:),time);
out.Name = ctrlMsgUtils.message('Slcontrol:frest:TimeseriesName','Chirp');
out.DataInfo.Interpolation.Name = 'Zero-order hold';
end