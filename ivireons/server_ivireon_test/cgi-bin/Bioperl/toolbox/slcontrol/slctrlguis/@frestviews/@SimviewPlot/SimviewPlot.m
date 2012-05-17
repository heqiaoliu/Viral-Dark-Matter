function p = SimviewPlot(hfig,sysfrd,datasrc,opts,curselection,syscomp)
%  SIMVIEWPLOT  Constructor for @SimviewPlot class
%
%

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.5 $ $Date: 2009/10/16 06:46:16 $

% Create the class instance
p = frestviews.SimviewPlot;

% Attach data,options and default current settings for selection of range
p.SimulationData = datasrc;
p.PlotOptions = opts;
labelSettings = {'InputName' sysfrd.InputName 'OutputName' sysfrd.OutputName};


%% Create individual components - Time, FFT and Summary
gridsize = size(sysfrd);
input = p.SimulationData.Input;
% Time plot
time_ax = axes('Position',[0.02 0.02 0.96 0.96],'Parent',hfig);
% Initialize axis with the appropriate options that are already being used
% for time plots such as step.
axopts = ltiplotoption('step',[],cstprefs.tbxprefs,1,[]);
frest.frestutils.initAxisSettings(time_ax,axopts);
if isa(input,'frest.Sinestream')
    p.TimePlot = resppack.sinestreamplot(time_ax,gridsize,labelSettings{:});   
else
    p.Timeplot = resppack.timeplot(time_ax,gridsize,labelSettings{:});
end
% Make labels translated
p.TimePlot.AxesGrid.Title = ctrlMsgUtils.message('Controllib:plots:strTimeResponse');
p.TimePlot.AxesGrid.XLabel = ctrlMsgUtils.message('Controllib:plots:strTime');
p.TimePlot.AxesGrid.YLabel = ctrlMsgUtils.message('Controllib:plots:strAmplitude');

% FFT plot
fft_ax = axes('Position',[0.02 0.02 0.96 0.96],'Parent',hfig);
% Use same settings for fft plot
frest.frestutils.initAxisSettings(fft_ax,axopts);
p.SpectrumPlot = resppack.fftplot(fft_ax,gridsize,labelSettings{:});

% Set the styles and update titles for sinestream input, use default for others
if isa(input,'frest.Sinestream')
    numstyles = numel(p.TimePlot.StyleManager.Styles);
    styleset = p.TimePlot.StyleManager.Styles;
    for ct = numel(input.Frequency):-1:1
        styles(ct) = styleset(rem(ct-1,numstyles)+1);
    end
    p.Styles = styles;
    % Update titles due to filtering
    if strcmp(input.ApplyFilteringInFRESTIMATE,'on')
        p.TimePlot.AxesGrid.Title = ctrlMsgUtils.message('Controllib:plots:strFilteredTimeResponse');
        p.SpectrumPlot.AxesGrid.Title = ctrlMsgUtils.message('Controllib:plots:strFilteredFFT');
    end
end

% Summary pane - for sinestream and chirp only
if any(strcmp(class(input),{'frest.Sinestream' 'frest.Chirp'}))
    % Create & initialize the pane
    summary_ax = axes('Position',[0.02 0.02 0.96 0.96],'Parent',hfig);
    frest.frestutils.initAxisSettings(summary_ax,axopts);
    p.SummaryPlot = frestviews.SimviewSummary;
    set(summary_ax,'Visible','off','XlimMode','auto','YlimMode','auto')
    p.SummaryPlot.SummaryBode = resppack.bodeplot(summary_ax, gridsize, labelSettings{:});
    summary_h = p.SummaryPlot.SummaryBode;

    % Add estimation result
    if isa(input,'frest.Sinestream')
        % Create response for each FRD point if sinestream
        freqrad = unitconv(input.Frequency,input.FreqUnits,'rad/s');
        for ct = 1:numel(freqrad)
            sys = frd(sysfrd.response(:,:,ct),freqrad(ct));
            src = resppack.ltisource(sys);
            r = summary_h.addresponse(src);
            r.DataFcn = {'magphaseresp' src 'bode' r []};
            % Styles and preferences
            initsysresp(r,'bode',summary_h.Options,[])
        end
    else
        % Add full frd-object once
        src = resppack.ltisource(sysfrd);
        r = summary_h.addresponse(src);
        r.DataFcn = {'magphaseresp' src 'bode' r []};
        % Styles and preferences
        initsysresp(r,'bode',summary_h.Options,[])
    end 
    % Add system to compare, if any.
    if ~isempty(syscomp)
        src = resppack.ltisource(syscomp);
        r = summary_h.addresponse(src);
        r.DataFcn = {'magphaseresp' src 'bode' r []};
        % Styles and preferences       
        initsysresp(r,'bode',summary_h.Options,[])
    end
    % Add the range selectors    
    bodeaxes = p.SummaryPlot.SummaryBode.getaxes;
    if isa(input,'frest.Sinestream')
        freq = sysfrd.Frequency;
        if curselection > 1
            xlim = [mean(freq(curselection-1:curselection)),mean(freq(curselection:curselection+1))];
        elseif numel(freq) == 2             
            % Handle the case where there are only 2 frequencies
            gap = mean(freq)-min(freq);
            xlim = [freq(curselection)-gap freq(curselection)+gap];
        elseif numel(freq) == 1             
            % Handle the case where there is only one frequency
            % Set the gap to be one octave
            xlim = [freq*0.5 freq*2];
        end
        % Convert xlim to the current frequency units
        xlim = unitconv(xlim,sysfrd.Units,p.PlotOptions.SummaryFreqUnits);
    else
        % chirp - full sweep range
        xlim = sort(input.FreqRange);
        % Convert xlim to the current frequency units
        xlim = unitconv(xlim,input.FreqUnits,p.PlotOptions.SummaryFreqUnits);
    end
    % Create range selectors
    for ctout = 1:gridsize(1)
        for ctin = 1:gridsize(2)
            % Magnitude
            axmag = bodeaxes(ctout,ctin,1);
            XRangeSelectors(ctout,ctin,1) = ctrluis.XRangeSelector(axmag,xlim);
            XRangeSelectors(ctout,ctin,1).setVisible('on');
            % Phase
            axphase = bodeaxes(ctout,ctin,2);
            XRangeSelectors(ctout,ctin,2) = ctrluis.XRangeSelector(axphase,xlim);
            XRangeSelectors(ctout,ctin,2).setVisible('on');
        end
    end
    p.SummaryPlot.XRangeSelectors = XRangeSelectors;    
    % Turn off phase by default
    p.SummaryPlot.SummaryBode.PhaseVisible = 'off';
    % Make labels translated
    p.SummaryPlot.SummaryBode.AxesGrid.Title = ctrlMsgUtils.message('Controllib:plots:strBodeDiagram');
    p.SummaryPlot.SummaryBode.AxesGrid.XLabel = ctrlMsgUtils.message('Controllib:plots:strFrequency');
    p.SummaryPlot.SummaryBode.AxesGrid.YLabel = {ctrlMsgUtils.message('Controllib:plots:strMagnitude');...
        ctrlMsgUtils.message('Controllib:plots:strPhase')};

end


%% Add an initial response to time and FFT - There will be at least one
%% response at all times

% Time plot
p.TimePlot.addresponse;
% Set data source and function
p.TimePlot.Responses.DataSrc = p.SimulationData;
p.TimePlot.Responses.DataFcn = {'getTimeData' p.SimulationData ...
    curselection p.TimePlot.Responses gridsize};
p.TimePlot.Responses.Name = ctrlMsgUtils.message('Slcontrol:frest:ResponseName',...
    frest.frestutils.getInputTypeString(p.SimulationData.Input));
% Add DC characteristic
p.TimePlot.Responses.addchar('InitialOutput','resppack.TimeInitialValueData', 'resppack.TimeFinalValueView');
% Set characteristics DataFcn
c = p.TimePlot.Responses.Characteristics;
c.DataFcn = {'getInitialOutput' c.Data c gridsize p.SimulationData.Output};


% Spectrum Plot
p.SpectrumPlot.addresponse;
p.SpectrumPlot.Responses.DataSrc = p.SimulationData;
p.SpectrumPlot.Responses.DataFcn = {'getSpectrumData' p.SimulationData ...
    curselection p.SpectrumPlot.Responses gridsize};

% Initialize FreqIndices, draw frequency harmonics and apply style for sinestream
if isa(input,'frest.Sinestream')
    % Add harmonic characteristics
    p.SpectrumPlot.Responses.addchar('FundamentalHarmonic',...
        'wavepack.SpectrumHarmonicData','wavepack.SpectrumHarmonicView');
    % Set the characteristics datafcn
    c = p.SpectrumPlot.Responses.Characteristics;
    c.DataFcn = {'getFundamentalFreq' c.Data c gridsize...
        input.Frequency(curselection) input.FreqUnits};
    % Initialize indices
    p.FreqIndices = curselection;
    p.RespIndices = 1;
    % Apply styles
    p.TimePlot.Responses.Style = p.Styles(curselection);
    p.SpectrumPlot.Responses.Style = p.Styles(curselection);
    % Apply styles to frequencies in FRD plot    
    for ct = 1:numel(input.Frequency)
        thisstyle = copy(p.Styles(ct));
        thisstyle.Markers = {'*'};
        summary_h.Responses(ct).Style = thisstyle;
    end
    % Make system to compare blue, if any
    if numel(summary_h.Responses) > numel(input.Frequency)
        summary_h.Responses(end).Style = p.Styles(1);
    end    
else
    % Make spectrum plots regular plot
    p.SpectrumPlot.Responses.View.Style = 'plot';
end

% Delete datatips when the time or spectrum axis is clicked
set(allaxes(p.TimePlot),'ButtonDownFcn',{@frest.frestutils.clearDataTips})
set(allaxes(p.SpectrumPlot),'ButtonDownFcn',{@frest.frestutils.clearDataTips})

p.Figure = handle(hfig);

% Arrange displaying of channel information
LocalPlaceChannelInfo(p);

% Add menus
figmenus(p);

% Specify the channel
p.CurrentChannel = [1 1];

% Draw summary, if any
if ~isempty(p.SummaryPlot)
    p.SummaryPlot.SummaryBode.Visible = 'on';
    set(allaxes(p.SummaryPlot.SummaryBode),'ButtonDownFcn',...
        {@frest.frestutils.clearDataTips})
end

% Set the options and make the figure visible
setoptions(p);
set(hfig,'Visible','on');


% Set the selection, this will draw everything also (except summary).
p.CurrentSelection = curselection;
% Make sure all XRange selectors are in visible axes area
if ~isempty(p.SummaryPlot)
    LocalPlaceXRangeSelectorsInAxesArea(p.SummaryPlot)
end

% Right-click menus
addContextMenu(p);

% Set resize function
set(hfig,'ResizeFcn',{@(x,y)layout(p)})

% Set the hoverfig as the WindowButtonMotionFcn
set(hfig,'WindowButtonMotionFcn',@(x,y) hoverfig(hfig));


end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalPlaceXRangeSelectorsInAxesArea
%  Makes sure that all range selectors are in visible area
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalPlaceXRangeSelectorsInAxesArea(sump)
% Get range selector limits
xlim = sump.XRangeSelectors(1).XRange;
% Find the tightest visible area among all axes
actxlim = cell2mat(sump.SummaryBode.AxesGrid.getxlim);
actxlim = [max(actxlim(:,1)) min(actxlim(:,2))];
% Make sure they are in the tightest area
if xlim(1) < actxlim(1)
    sump.XRangeSelectors(1).XRange(1) =  actxlim(1);
end
if xlim(2) > actxlim(2)
    sump.XRangeSelectors(1).XRange(2) =  actxlim(2);
end
end

function LocalPlaceChannelInfo(p)
% Store row/column labels in the titlebar
p.TitleBar.ColumnLabel = p.TimePlot.AxesGrid.ColumnLabel;
p.TitleBar.RowLabel = p.TimePlot.AxesGrid.RowLabel;
% Create empty labels with the size of row/column for each plot
emptyc = repmat({''},numel(p.TitleBar.ColumnLabel),1);
emptyr = repmat({''},numel(p.TitleBar.RowLabel),1);
% Set the row/column labels to empty
p.TimePlot.AxesGrid.ColumnLabel = emptyc;
p.TimePlot.AxesGrid.RowLabel = emptyr;
p.SpectrumPlot.AxesGrid.ColumnLabel = emptyc;
p.SpectrumPlot.AxesGrid.RowLabel = emptyr;
if ~isempty(p.SummaryPlot)
    p.SummaryPlot.SummaryBode.AxesGrid.ColumnLabel = ...
        repmat({''},numel(p.SummaryPlot.SummaryBode.AxesGrid.ColumnLabel),1);
    p.SummaryPlot.SummaryBode.AxesGrid.RowLabel = ...
        repmat({''},numel(p.SummaryPlot.SummaryBode.AxesGrid.RowLabel),1);
end

% Create the title bar
p.TitleBar.Handle = annotation(p.Figure,'textbox',[0,0,1,1]);
set(p.TitleBar.Handle,...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle',...
    'FontWeight',p.TimePlot.AxesGrid.TitleStyle.FontWeight,...
    'Color',p.TimePlot.AxesGrid.TitleStyle.Color,...
    'FontAngle',p.TimePlot.AxesGrid.TitleStyle.FontAngle,...
    'FontSize',p.TimePlot.AxesGrid.TitleStyle.FontSize,...
    'Interpreter',p.TimePlot.AxesGrid.TitleStyle.Interpreter,...
    'LineStyle','none',...
    'Visible','on');



end




