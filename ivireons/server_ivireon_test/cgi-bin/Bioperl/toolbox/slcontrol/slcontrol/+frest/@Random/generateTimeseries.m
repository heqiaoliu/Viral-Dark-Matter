function out = generateTimeseries(obj)
% GENERATETIMESERIES Generate MATLAB timeseries for the specified random
% input signal
%
%   insig = generateTimeseries(in) generates the MATLAB timeseries object
%   which captures the actual data corresponding to the specified random
%   input signal in.
%
%   See also frestimate, frest.Random


%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2009/11/09 16:35:04 $

% Restore the stream and state of default random stream
prevstream = RandStream.setDefaultStream(obj.Stream);
obj.Stream.State = obj.State;

data = obj.Amplitude*rand(1,obj.NumSamples);
tfinal = (obj.Ts*(obj.NumSamples-1));
time = 0:obj.Ts:tfinal;
out = timeseries(data(:),time);
out.Name = ctrlMsgUtils.message('Slcontrol:frest:TimeseriesName','Random');
out.DataInfo.Interpolation.Name = 'Zero-order hold';
% Restore the original stream
RandStream.setDefaultStream(prevstream);
end