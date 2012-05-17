function valueStored = updateSelection(this, proposedValue)
%  UPDATESELECTION compares the new selection to current and take necessary
%  actions such as add/remove/update responses.
%
%

% Author(s): Erman Korkut 16-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:49:57 $



if isa(this.TimePlot,'resppack.sinestreamplot')
    %% Sinestream plot            
    % Update existing frequencies
    for ct = 1:min(numel(this.FreqIndices),numel(proposedValue))
        LocalReuseExistingResponse(this,ct,proposedValue(ct));
    end
    if isempty(ct) ct = 0; end
    if ct < numel(proposedValue)
        % More to add, reuse old ones if any
        for ctnew = (ct+1):numel(proposedValue)
            resp2reuse = getAvailableResponse(this);
            if isempty(resp2reuse)
                LocalInsertResponse(this,proposedValue(ctnew));
            else
                LocalReuseOldResponse(this,proposedValue(ctnew),resp2reuse);
            end
        end
    elseif ct < numel(this.FreqIndices)
        % More to remove, turn off
        LocalTurnOffResponses(this,ct+1:numel(this.FreqIndices));
    end
else
    %% Other plots
    % Just update the DataFcn
    this.TimePlot.Responses.DataFcn = {'getTimeData' this.SimulationData ...
        proposedValue this.TimePlot.Responses size(this.SimulationData.Output)};
    this.SpectrumPlot.Responses.DataFcn = {'getSpectrumData' this.SimulationData ...
        proposedValue this.SpectrumPlot.Responses size(this.SimulationData.Output)};
end
valueStored = proposedValue;
% Redraw everything
draw(this)
end
function LocalReuseExistingResponse(this,ct,new_freq)
resp2reuse_ind = this.RespIndices(ct);
% Time plot
this.TimePlot.Responses(resp2reuse_ind).DataFcn = {'getTimeData' this.SimulationData ...
    new_freq this.TimePlot.Responses(resp2reuse_ind) size(this.SimulationData.Output)};
% Spectrum plot
this.SpectrumPlot.Responses(resp2reuse_ind).DataFcn = {'getSpectrumData' this.SimulationData ...
    new_freq this.SpectrumPlot.Responses(resp2reuse_ind) size(this.SimulationData.Output)};
% Update the characteristics datafcn
c = this.SpectrumPlot.Responses(resp2reuse_ind).Characteristics;
c.DataFcn = {'getFundamentalFreq' c.Data c size(this.SimulationData.Output) ...
    this.SimulationData.Input.Frequency(new_freq) this.SimulationData.Input.FreqUnits};
this.FreqIndices(ct) = new_freq;
end

function LocalTurnOffResponses(this,freqind)
% Turn off visibilities from time & spectrum plot
% Possible improvement - do without loop by creating cell arrays
ind2remove = this.RespIndices(freqind);
for ct = 1:numel(ind2remove)
    this.TimePlot.Responses(ind2remove(ct)).Visible = 'off';
    this.SpectrumPlot.Responses(ind2remove(ct)).Visible = 'off';
end
% Remove from visible indices
this.FreqIndices(freqind) = [];
this.RespIndices(freqind) = [];
end

function LocalInsertResponse(this,index)
% Time plot
this.TimePlot.addresponse;
this.TimePlot.Responses(end).DataSrc = this.SimulationData;
this.TimePlot.Responses(end).DataFcn = {'getTimeData' this.SimulationData ...
    index this.TimePlot.Responses(end) size(this.SimulationData.Output)};
% Add DC characteristic
this.TimePlot.Responses(end).addchar('InitialOutput','resppack.TimeInitialValueData', 'resppack.TimeFinalValueView');
% Set characteristics Data
c = this.TimePlot.Responses(end).Characteristics;
c.DataFcn = {'getInitialOutput' c.Data c size(this.SimulationData.Output) this.SimulationData.Output};

% Spectrum plot
this.SpectrumPlot.addresponse;
this.SpectrumPlot.Responses(end).DataSrc = this.SimulationData;
this.SpectrumPlot.Responses(end).DataFcn = {'getSpectrumData' this.SimulationData ...
    index this.SpectrumPlot.Responses(end) size(this.SimulationData.Output)};
% Update the list
this.FreqIndices(end+1) = index;
this.RespIndices(end+1) = numel(this.TimePlot.Responses);
% Apply style and add fundamental harmonic characteristic for sinestream
if isa(this.SimulationData.Input,'frest.Sinestream')
    this.TimePlot.Responses(end).Style = this.Styles(index);
    this.SpectrumPlot.Responses(end).Style = this.Styles(index);
    % Add fundamental frequency component characteristic
    this.SpectrumPlot.Responses(end).addchar('Fundamental Frequency',...
        'wavepack.SpectrumHarmonicData','wavepack.SpectrumHarmonicView');
    % Set the characteristics datafcn
    c = this.SpectrumPlot.Responses(end).Characteristics;
    c.DataFcn = {'getFundamentalFreq' c.Data c size(this.SimulationData.Output) ...
        this.SimulationData.Input.Frequency(index) this.SimulationData.Input.FreqUnits};
end

end
function LocalReuseOldResponse(this,new_freq,resp2reuse_ind)
% Time plot
this.TimePlot.Responses(resp2reuse_ind).DataFcn = {'getTimeData' this.SimulationData ...
    new_freq this.TimePlot.Responses(resp2reuse_ind) size(this.SimulationData.Output)};
% Spectrum plot
this.SpectrumPlot.Responses(resp2reuse_ind).DataFcn = {'getSpectrumData' this.SimulationData ...
    new_freq this.SpectrumPlot.Responses(resp2reuse_ind) size(this.SimulationData.Output)};
% Update the characteristics datafcn
c = this.SpectrumPlot.Responses(resp2reuse_ind).Characteristics;
c.DataFcn = {'getFundamentalFreq' c.Data c size(this.SimulationData.Output) ...
    this.SimulationData.Input.Frequency(new_freq) this.SimulationData.Input.FreqUnits};

this.FreqIndices(end+1) = new_freq;
this.RespIndices(end+1) = resp2reuse_ind;

% Update styles for non-sinestream
if isa(this.SimulationData.Input,'frest.Sinestream')
    this.TimePlot.Responses(resp2reuse_ind).Style = this.Styles(new_freq);
    this.SpectrumPlot.Responses(resp2reuse_ind).Style = this.Styles(new_freq);
end
this.TimePlot.Responses(resp2reuse_ind).Visible = 'on';
this.SpectrumPlot.Responses(resp2reuse_ind).Visible = 'on';
end