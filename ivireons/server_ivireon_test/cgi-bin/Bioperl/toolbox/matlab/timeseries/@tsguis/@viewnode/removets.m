function removets(h,ts)

% Copyright 2004-2008 The MathWorks, Inc.

% Removes a time series from a plot and updates the axes indices and
% @viewnote table to reflect the change.

%% If no plot then nothing to do
if isempty(h.Plot) || ~ishandle(h.Plot)
    return
end

%% If a timeseries is passed as the second argument find the corresponding
%% wave
if isa(ts,'wavepack.waveform')
    wave = ts;
else
    wave = [];
    for k=1:length(h.Plot.Waves)
        if ~isempty(h.Plot.Waves(k).DataSrc) && ...
                isequal(h.Plot.Waves(k).DataSrc.Timeseries,ts)   
            wave = h.Plot.Waves(k);
            break;
        end        
    end
end

if ~isempty(wave)
    % Find row indices in the deleted wave that are not present in any of
    % the other waves
    affectedInd = wave.RowIndex(:);
    for k=1:length(h.Plot.Waves)
        if h.Plot.Waves(k)~=wave
            affectedInd = setdiff(affectedInd,h.Plot.Waves(k).RowIndex(:));
        end
    end
    % Modify all the row indices of the remaining waves 
    for k=1:length(h.Plot.Waves)
        if h.Plot.Waves(k)~=wave
            theseRows = h.Plot.Waves(k).RowIndex(:);
            for j=1:length(theseRows)
                theseRows(j) = theseRows(j)-sum(affectedInd<theseRows(j));
            end
            h.Plot.Waves(k).RowIndex = theseRows;
        end
    end        
    h.Plot.rmwave(wave);
    h.send('tschanged',handle.EventData(h,'tschange'));

    % Programmatically refresh the time series table to remove any empty
    % axes or close the view if its empty
    if isempty(h.Plot.waves)
        h.remove(h.getRoot.Tsviewer.TreeManager);
    else
        h.Plot.packAxes;
    end
end    



