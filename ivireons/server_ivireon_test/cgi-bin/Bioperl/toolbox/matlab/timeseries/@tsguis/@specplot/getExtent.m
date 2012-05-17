function extentInterval = getExtent(h)

% Copyright 2005 The MathWorks, Inc.

%% Gets the full freq interval (in the plot freqUnits) occupied by all the
%% time series 

%% Default is [0 1]
if isempty(h.Waves)
    extentInterval = [0 1];
    return
end

newUpperFreq = 0;
for k=1:length(h.Waves)
    unitconvfact = 1/tsunitconv(sprintf('%ss',h.Waves(k).Data.FreqUnits(5:end)),...
        h.Waves(k).DataSrc.Timeseries.TimeInfo.Units);
    if ~isempty(h.Waves(k).Data.NyquistFreq) && isscalar(h.Waves(k).Data.NyquistFreq)
        newUpperFreq =  max(newUpperFreq,h.Waves(k).Data.NyquistFreq);
    end
end
extentInterval = [0 newUpperFreq];
        
%% Prevent zero length intervals
if diff(extentInterval)<eps
    extentInterval = [extentInterval(1)-10*eps extentInterval(1)+10*eps];
end