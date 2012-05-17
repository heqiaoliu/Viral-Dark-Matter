function valueStored = updateChannel(this, proposedValue)
%  UPDATECHANNEL compares the new selection to current and take necessary
%  actions such as add/remove/update responses.
%
%

% Author(s): Erman Korkut 17-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2009/10/16 06:46:19 $


% Translate channel selection to input/outputvisible properties of TimePlot
% SpectrumPlot and SummaryBode plot

% Remove all listeners
if ~isempty(this.SummaryPlot)
    delete(this.SummaryPlot.SelectorListeners);
    % Turn off all range selectors
    for ct = numel(this.SummaryPlot.XRangeSelectors):-1:1
        this.SummaryPlot.XRangeSelectors(ct).setVisible('off');
    end
end

% Turn all input/output off
for ct = 1:numel(this.TimePlot.InputVisible)
    this.TimePlot.InputVisible{ct} = 'off';
    this.SpectrumPlot.InputVisible{ct} = 'off';
    if ~isempty(this.SummaryPlot)
        this.SummaryPlot.SummaryBode.InputVisible{ct} = 'off';
    end
end
for ct = 1:numel(this.TimePlot.OutputVisible)
    this.TimePlot.OutputVisible{ct} = 'off';
    this.SpectrumPlot.OutputVisible{ct} = 'off';
    if ~isempty(this.SummaryPlot)
        this.SummaryPlot.SummaryBode.OutputVisible{ct} = 'off';
    end
end

% Turn back only the selected channel on
this.TimePlot.OutputVisible{proposedValue(1)} = 'on';
this.TimePlot.InputVisible{proposedValue(2)} = 'on';
this.SpectrumPlot.OutputVisible{proposedValue(1)} = 'on';
this.SpectrumPlot.InputVisible{proposedValue(2)} = 'on';
% Update the channel info in the title
set(this.TitleBar.Handle,'String',...
    sprintf('%s  %s',this.TitleBar.ColumnLabel{proposedValue(2)},this.TitleBar.RowLabel{proposedValue(1)}));

if ~isempty(this.SummaryPlot)
    this.SummaryPlot.SummaryBode.OutputVisible{proposedValue(1)} = 'on';
    this.SummaryPlot.SummaryBode.InputVisible{proposedValue(2)} = 'on';
    % Turn on the listener for the for the selected channels selectors.
    sel = this.SummaryPlot.XRangeSelectors(proposedValue(1),proposedValue(2),:);
    sel(1).setVisible('on');
    sel(2).setVisible('on');
    % Add listener to the selector range
    this.SummaryPlot.SelectorListeners = ...
        sel.addlistener('XRange','PostSet',@(es,ed)LocalRangeChanged(es,ed,this));
    
    % Set the location of range selector where it was left at previous channel
    oldChannel = this.CurrentChannel;
    % Protect against emptiness as it is initially empty
    if ~isempty(oldChannel)
        % Turn off listeners first not to reset CurrentSelection
        this.SummaryPlot.SelectorListeners(1).Enabled = false;
        this.SummaryPlot.SelectorListeners(2).Enabled = false;
        sel(1).XRange = this.SummaryPlot.XRangeSelectors(oldChannel(1),oldChannel(2),1).XRange;
        sel(2).XRange = this.SummaryPlot.XRangeSelectors(oldChannel(1),oldChannel(2),2).XRange;
        % Turn them back on
        this.SummaryPlot.SelectorListeners(1).Enabled = true;
        this.SummaryPlot.SelectorListeners(2).Enabled = true;
    end
end
valueStored = proposedValue;
end

function LocalRangeChanged(es,ed,p)
% Get the newly selected frequency range
FRange = ed.AffectedObject.XRange;
in = p.SimulationData.Input;
% Convert units of FRange to input's
FRangeConv = unitconv(FRange,p.SummaryPlot.SummaryBode.AxesGrid.XUnits,in.FreqUnits);

if isa(in,'frest.Sinestream')
    % Find the selected frequency range
    f = in.Frequency;
    flow = f >= FRangeConv(1);
    fhigh = f <= FRangeConv(2);
    % Set the selection
    p.CurrentSelection = find(flow & fhigh);
else
    % Chirp
    times = in.TranslateFromFrequencyToTime(FRangeConv);
    indices = 1+round(times./(in.Ts));
    if all(indices <= 1) || all(indices >= in.NumSamples)
        p.CurrentSelection = [];
    else
        if indices(1) <= 1
            indices(1) = 1;
        end
        if indices(2) >= in.NumSamples
            indices(2) = in.NumSamples;
        end
        p.CurrentSelection = indices;
    end 
end

% Align the other range selector
othersel = p.SummaryPlot.XRangeSelectors(p.CurrentChannel(1),p.CurrentChannel(2),:);
% Turn off listeners before doing so not to compute current selection again
p.SummaryPlot.SelectorListeners(1).Enabled = false;
p.SummaryPlot.SelectorListeners(2).Enabled = false;
for ct = 1:numel(othersel)
    if ed.AffectedObject ~= othersel(ct)
        othersel(ct).XRange = FRange;
    end
end
% Turn them back on
p.SummaryPlot.SelectorListeners(1).Enabled = true;
p.SummaryPlot.SelectorListeners(2).Enabled = true;


end

