function updatebins(h)
%% Update the bins property of the plot based on the definitions in the 
%% tsspecnode Dialog

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/27 23:03:19 $

%% No action if there is no TimePlot
if isempty(h.Plot) || ~ishandle(h.Plot) 
    return
end

if isempty(h.Dialog) || get(h.Handles.RADIOuniform,'Value')   
    % Construct a uniform bin vector
    if isempty(h.Dialog)
        numbins = 50;
    else
        numbins = eval(get(h.Handles.TXTNumBins,'String'),'[]');
    end
    if ~isempty(numbins) && isscalar(numbins) && numbins>1 && numbins<1e6
        L = inf;
        U = -inf;
        for k=1:length(h.Plot.Waves)
            thisdata = h.Plot.Waves(k).DataSrc.Timeseries.Data;
            L = min(L,min(thisdata(:)));
            U = max(U,max(thisdata(:)));
        end
        bins = linspace(L,U,numbins);
    else % Invalid number of bins - abort and revert to default
        errordlg('Invalid number of bins','Time Series Tools','modal')
        set(h.Handles.TXTNumBins,'String','50')
        return
    end
else
    % Construct a custom bin vector
    bins = eval(get(h.Handles.TXTCenters,'String'),'[]');    
    % If bin vec is invalid abort and revert to default 
    if isempty(bins) || ~(all(isfinite(bins)) && ndims(bins)==2 && ...
            min(size(bins))==1 && issorted(bins)) || length(bins)>1e6
           errordlg('Invalid bin vector','Time Series Tools','modal')
           set(h.Handles.TXTCenters,'String','1:10')
           return
    end
end

%% Apply the bin vector to the datafcn for each wave
h.Plot.Bins = bins;
for k=1:length(h.Plot.Waves)
    h.Plot.Waves(k).DataSrc.send('SourceChanged')
end
