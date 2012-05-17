function addContextMenu(this)
%ADDCONTEXTMENU  Installs the right-click menus for simView figure

%  Author(s): Erman Korkut 31-Mar-2009
%   Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2009/08/08 01:19:22 $
opts = this.PlotOptions;

%% Right click menu for Time plot
hPlot = this.TimePlot;
hAxGrid = hPlot.AxesGrid;

% Characteristic
mChar = hPlot.addMenu('characteristics');
% Add the initial output characteristic
uimenu('Parent',mChar,'Label',ctrlMsgUtils.message('Slcontrol:frest:strInitialOutput'),...
    'Callback',@(x,y) LocalCallback(x,hPlot,'InitialOutput','resppack.TimeInitialValueData','resppack.TimeFinalValueView'),...
    'UserData',{'InitialOutput','resppack.TimeInitialValueData','resppack.TimeFinalValueView'},...
    'Checked','on','Tag','InitialOutput');
% IO Selector
uimenu('Parent', hAxGrid.UIcontextMenu,'Label',xlate('I/O Selector...'),...
    'Callback',{@LocalCreateChannelSelector this},'Tag','ioselector',...
    'Separator','on');
% Grid
hAxGrid.addMenu('grid','Separator','on');
% Full view
hPlot.addMenu('fullview');
% Show full output - add this menu only if ApplyFilteringInFRESTIMATE is
% 'on' for a sinestream signal
if isa(this.SimulationData,'frestviews.SinestreamSource') && ...
        strcmp(this.SimulationData.Input.ApplyFilteringInFRESTIMATE,'on')
    uimenu('Parent', hAxGrid.UIcontextMenu,'Label',ctrlMsgUtils.message('Slcontrol:frest:strShowFilteredOutput'),...
        'Callback',{@LocalShowFilteredOutput this},'Checked',this.SimulationData.Input.ApplyFilteringInFRESTIMATE,...
        'Separator','on','Tag','FilterOption');
end

%% Right click menu for Spectrum plot
hPlot = this.SpectrumPlot;
hAxGrid = hPlot.AxesGrid;
% Characteristic
mChar = hPlot.addMenu('characteristics');
% Add the fundamental harmonic characteristic
uimenu('Parent',mChar,'Label',ctrlMsgUtils.message('Slcontrol:frest:strInputFrequency'),...
    'Callback',@(x,y) LocalCallback(x,hPlot,'FundamentalHarmonic','wavepack.SpectrumHarmonicData','wavepack.SpectrumHarmonicView'),...
    'UserData',{'FundamentalHarmonic','wavepack.SpectrumHarmonicData','wavepack.SpectrumHarmonicView'},...
    'Checked','on','Tag','InputFrequency');
% IO Selector
uimenu('Parent', hAxGrid.UIcontextMenu,'Label',xlate('I/O Selector...'),...
    'Callback',{@LocalCreateChannelSelector this},'Tag','ioselector',...
    'Separator','on');
% Units
% Frequency
mFreqUnits = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strFrequencyUnits'),...
    'Separator','on');
% rad/s
hRad = uimenu('Parent',mFreqUnits,'Label',ctrlMsgUtils.message('Slcontrol:frest:strRadPerSec'),...    
    'Checked',LocalBool2OnOff(strcmp(opts.SpectrumFreqUnits,'rad/s')),...
    'Tag','FreqUnitRad');        
% Hz
hHz = uimenu('Parent',mFreqUnits,'Label',ctrlMsgUtils.message('Slcontrol:frest:strHz'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SpectrumFreqUnits,'Hz')),...
    'Tag','FreqUnitHz');
set(hRad,'Callback',{@LocalFrequencyUnits this.SpectrumPlot hRad hHz this});
set(hHz,'Callback',{@LocalFrequencyUnits this.SpectrumPlot hRad hHz this});
% Amplitude
mSpecAmpUnits = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strAmplitudeUnits'),...
    'Tag','SpecAmpUnitsMain');
hAbs = uimenu('Parent',mSpecAmpUnits,'Label',ctrlMsgUtils.message('Slcontrol:frest:strAbs'),...    
    'Checked',LocalBool2OnOff(strcmp(opts.SpectrumAmpUnits,'abs')),...
    'Tag','AmpUnitsAbs');
hDB = uimenu('Parent',mSpecAmpUnits,'Label',ctrlMsgUtils.message('Slcontrol:frest:strdB'),...    
    'Checked',LocalBool2OnOff(strcmp(opts.SpectrumAmpUnits,'dB')),...
    'Tag','AmpUnitsdB');
% Callbacks will be set with the scale handle below
% Scale
% Frequency
mFreqScale = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strFrequencyScale'),...
    'Separator','on');
hLin = uimenu('Parent',mFreqScale,'Label',ctrlMsgUtils.message('Slcontrol:frest:strLinear'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SpectrumFreqScale,'linear')),...
    'Tag','FreqScaleLin');
hLog = uimenu('Parent',mFreqScale,'Label',ctrlMsgUtils.message('Slcontrol:frest:strLog'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SpectrumFreqScale,'log')),...
    'Tag','FreqScaleLog');
set(hLin,'Callback',{@LocalFrequencyScale this.SpectrumPlot hLin hLog this});
set(hLog,'Callback',{@LocalFrequencyScale this.SpectrumPlot hLin hLog this});
% Amplitude
mSpecAmpScale = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strAmplitudeScale'),...
    'Tag','SpecAmpScaleMain');
hLin = uimenu('Parent',mSpecAmpScale,'Label',ctrlMsgUtils.message('Slcontrol:frest:strLinear'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SpectrumAmpScale,'linear')),...
    'Tag','AmpScaleLin');
hLog = uimenu('Parent',mSpecAmpScale,'Label',ctrlMsgUtils.message('Slcontrol:frest:strLog'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SpectrumAmpScale,'log')),...
    'Tag','AmpScaleLog');
set(hLin,'Callback',{@LocalMagnitudeScaleSpectrum this.SpectrumPlot hLin hLog this mSpecAmpUnits});
set(hLog,'Callback',{@LocalMagnitudeScaleSpectrum this.SpectrumPlot hLin hLog this mSpecAmpUnits});
% Set the callback for amplitude units
set(hAbs,'Callback',{@LocalMagnitudeUnitsSpectrum this.SpectrumPlot hAbs hDB this mSpecAmpScale});
set(hDB,'Callback',{@LocalMagnitudeUnitsSpectrum this.SpectrumPlot hAbs hDB this mSpecAmpScale});
% Disable it if AmpUnits is dB.
if strcmp(opts.SpectrumAmpUnits,'dB')
    set(mSpecAmpScale,'Enable','off')
end

% Grid
hAxGrid.addMenu('grid','Separator','on');
% Full view
hPlot.addMenu('fullview');

%% Right click menu for Summary plot
hPlot = this.SummaryPlot;
if isempty(hPlot)
    return;
end
hAxGrid = hPlot.SummaryBode.AxesGrid;
% Show menu
hPlot.SummaryBode.addBodeMenu('show');
% IO Selector
uimenu('Parent', hAxGrid.UIcontextMenu,'Label',xlate('I/O Selector...'),...
    'Callback',{@LocalCreateChannelSelector this},'Tag','ioselector',...
    'Separator','on');
% Units
% Frequency
mFreqUnits = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strFrequencyUnits'),...
    'Separator','on');
% rad/s
hRad = uimenu('Parent',mFreqUnits,'Label',ctrlMsgUtils.message('Slcontrol:frest:strRadPerSec'),...    
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryFreqUnits,'rad/s')),...
    'Tag','FreqUnitRad');        
% Hz
hHz = uimenu('Parent',mFreqUnits,'Label',ctrlMsgUtils.message('Slcontrol:frest:strHz'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryFreqUnits,'Hz')),...
    'Tag','FreqUnitHz');
set(hRad,'Callback',{@LocalFrequencyUnits hPlot.SummaryBode hRad hHz this});
set(hHz,'Callback',{@LocalFrequencyUnits hPlot.SummaryBode hRad hHz this});
% Amplitude
mSumMagUnits = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strMagnitudeUnits'),...
    'Tag','SumMagUnitsMain');
hAbs = uimenu('Parent',mSumMagUnits,'Label',ctrlMsgUtils.message('Slcontrol:frest:strAbs'),...    
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryMagUnits,'abs')),...
    'Tag','AmpUnitsAbs');
hDB = uimenu('Parent',mSumMagUnits,'Label',ctrlMsgUtils.message('Slcontrol:frest:strdB'),...    
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryMagUnits,'dB')),...
    'Tag','AmpUnitsdB');
% Set the callbacks later with scale
% Phase
mPhaseUnits = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strPhaseUnits'));
hDeg = uimenu('Parent',mPhaseUnits,'Label',ctrlMsgUtils.message('Slcontrol:frest:strDegree'),...    
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryPhaseUnits,'deg')),...
    'Tag','PhaseUnitsDeg');
hRad = uimenu('Parent',mPhaseUnits,'Label',ctrlMsgUtils.message('Slcontrol:frest:strRadians'),...    
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryPhaseUnits,'rad')),...
    'Tag','PhaseUnitsRad');
set(hDeg,'Callback',{@LocalPhaseUnits hPlot.SummaryBode hDeg hRad this});
set(hRad,'Callback',{@LocalPhaseUnits hPlot.SummaryBode hDeg hRad this});
% Scale
% Frequency
mFreqScale = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strFrequencyScale'),...
    'Separator','on');
hLin = uimenu('Parent',mFreqScale,'Label',ctrlMsgUtils.message('Slcontrol:frest:strLinear'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryFreqScale,'linear')),...
    'Tag','FreqScaleLin');
hLog = uimenu('Parent',mFreqScale,'Label',ctrlMsgUtils.message('Slcontrol:frest:strLog'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryFreqScale,'log')),...
    'Tag','FreqScaleLog');
set(hLin,'Callback',{@LocalFrequencyScale hPlot.SummaryBode hLin hLog this});
set(hLog,'Callback',{@LocalFrequencyScale hPlot.SummaryBode hLin hLog this});
% Amplitude
mSumMagScale = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strMagnitudeScale'),...
    'Tag','SumMagScaleMain');
hLin = uimenu('Parent',mSumMagScale,'Label',ctrlMsgUtils.message('Slcontrol:frest:strLinear'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryMagScale,'linear')),...
    'Tag','AmpScaleLin');
hLog = uimenu('Parent',mSumMagScale,'Label',ctrlMsgUtils.message('Slcontrol:frest:strLog'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryMagScale,'log')),...
    'Tag','AmpScaleLog');
set(hLin,'Callback',{@LocalMagnitudeScaleSummary hPlot.SummaryBode hLin hLog this mSumMagUnits});
set(hLog,'Callback',{@LocalMagnitudeScaleSummary hPlot.SummaryBode hLin hLog this mSumMagUnits});
% Set the callbacks for units
set(hAbs,'Callback',{@LocalMagnitudeUnitsSummary hPlot.SummaryBode hAbs hDB this mSumMagScale});
set(hDB,'Callback',{@LocalMagnitudeUnitsSummary hPlot.SummaryBode hAbs hDB this mSumMagScale});
% Disable it if AmpUnits is dB.
if strcmp(opts.SummaryMagUnits,'dB')
    set(mSumMagScale,'Enable','off');
end
% Phase
mPhaseScale = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strPhaseScale'));
hLin = uimenu('Parent',mPhaseScale,'Label',ctrlMsgUtils.message('Slcontrol:frest:strLinear'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryPhaseScale,'linear')),...
    'Tag','PhaseScaleLin');
hLog = uimenu('Parent',mPhaseScale,'Label',ctrlMsgUtils.message('Slcontrol:frest:strLog'),...   
    'Checked',LocalBool2OnOff(strcmp(opts.SummaryPhaseScale,'log')),...
    'Tag','PhaseScaleLog');
set(hLin,'Callback',{@LocalPhaseScale hPlot.SummaryBode hLin hLog this});
set(hLog,'Callback',{@LocalPhaseScale hPlot.SummaryBode hLin hLog this});

% Grid
hAxGrid.addMenu('grid','Separator','on');
% Full view
hPlot.SummaryBode.addMenu('fullview');
% Phase unwrapping
mPhaseWrap = uimenu('Parent',hAxGrid.UIcontextMenu,...
    'Label',ctrlMsgUtils.message('Slcontrol:frest:strPhaseWrapping'),...
    'Checked',LocalBool2OnOff(strcmp(this.SummaryPlot.SummaryBode.Options.UnwrapPhase,'on')),...
    'Tag','PhaseWrapping');
set(mPhaseWrap,'Callback',{@LocalPhaseUnwrapping hPlot.SummaryBode this})


% Local Characteristic callback
function LocalCallback(eventSrc, hplot, Identifier, dataClass, viewClass)
% Toggles characteristic visibility based on checked state of menu
m = eventSrc;  % menu handle
if strcmp(get(m,'checked'),'on');
  newState='off';
else
  newState='on';
end

% Update menu check
set(m,'checked',newState);

% Add characteristic to waveform's that don't already have it, and set its global visibility
hplot.addchar(Identifier,dataClass,viewClass,'Visible',newState)


function LocalCreateChannelSelector(~, ~, this)
% Build I/O selector if does not exist
if isempty(this.ChannelSelector) 
   this.ChannelSelector = this.addChannelSelector;
end
this.ChannelSelector.Visible = 'on';


function LocalFrequencyUnits(eventSrc, ~, this, hRad, hHz, p)
% Set the frequency units
m = eventSrc;
if (hRad == m)
    othermenu = hHz;
else
    othermenu = hRad;
end
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
    set(othermenu,'Checked','on');
else
    set(m,'Checked','on');
    set(othermenu,'Checked','off');
end
oldUnits = this.AxesGrid.XUnits;
% Take the action
if strcmp(get(hRad,'Checked'),'on')
    this.AxesGrid.XUnits = 'rad/s';
else
    this.AxesGrid.XUnits = 'Hz';
end
% Update the plot options
if isa(this,'resppack.fftplot')
    p.PlotOptions.SpectrumFreqUnits = this.AxesGrid.XUnits;
else
    p.PlotOptions.SummaryFreqUnits = this.AxesGrid.XUnits;
    % Update XRange selectors location for bode plot    
    % Turn off listener before doing so, we do not need to update the current
    % selection
    p.SummaryPlot.SelectorListeners(1).Enabled = false;
    p.SummaryPlot.SelectorListeners(2).Enabled = false;
    xRangeSelectors = p.SummaryPlot.XRangeSelectors;
    % The units for XRange selector is the initial units before this update
    xRangeUnits = oldUnits;
    for ct = 1:numel(xRangeSelectors)
        xRangeSelectors(ct).XRange = unitconv(xRangeSelectors(ct).XRange,xRangeUnits,this.AxesGrid.XUnits);
    end
    p.SummaryPlot.SelectorListeners(1).Enabled = true;
    p.SummaryPlot.SelectorListeners(2).Enabled = true;
end




function LocalFrequencyScale(eventSrc, ~, this, hLin, hLog,p)
% Set the frequency units
m = eventSrc;
if (hLin == m)
    othermenu = hLog;
else
    othermenu = hLin;
end
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
    set(othermenu,'Checked','on');
else
    set(m,'Checked','on');
    set(othermenu,'Checked','off');
end
% Take the action
if strcmp(get(hLin,'Checked'),'on')
    this.AxesGrid.XScale = 'linear';
else
    this.AxesGrid.XScale = 'log';
end
% Update the plot options
if isa(this,'resppack.fftplot')
    p.PlotOptions.SpectrumFreqScale = this.AxesGrid.XScale;
else
    p.PlotOptions.SummaryFreqScale = this.AxesGrid.XScale;
end


    
function LocalMagnitudeUnitsSpectrum(eventSrc, ~, this, hAbs, hDB,p, hScale)
% Set the frequency units
m = eventSrc;
if (hAbs == m)
    othermenu = hDB;
else
    othermenu = hAbs;
end
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
    set(othermenu,'Checked','on');
else
    set(m,'Checked','on');
    set(othermenu,'Checked','off');
end
% Take the action
if strcmp(get(hAbs,'Checked'),'on')
    this.AxesGrid.YUnits = 'abs';
    % Enable scale menu
    set(hScale,'Enable','on');
else
    this.AxesGrid.YUnits = 'dB';
    % Disable scale menu
    set(hScale,'Enable','off');
end
% Update the plot options
p.PlotOptions.SpectrumAmpUnits = this.AxesGrid.YUnits;

function LocalMagnitudeUnitsSummary(eventSrc, ~, this, hAbs, hDB,p, hScale)
% Set the frequency units
m = eventSrc;
if (hAbs == m)
    othermenu = hDB;
else
    othermenu = hAbs;
end
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
    set(othermenu,'Checked','on');
else
    set(m,'Checked','on');
    set(othermenu,'Checked','off');
end
% Take the action
if strcmp(get(hAbs,'Checked'),'on')
    this.AxesGrid.YUnits{1} = 'abs';
    % Enable the scale menu
    set(hScale,'Enable','on');
else
    this.AxesGrid.YUnits{1} = 'dB';
    % Disable the scale menu
    set(hScale,'Enable','off');
end
% Update the plot options
p.PlotOptions.SummaryMagUnits =  this.AxesGrid.YUnits{1};

function LocalMagnitudeScaleSpectrum(eventSrc, ~, this, hLin, hLog, p, hUnits)
% Set the frequency units
m = eventSrc;
if (hLin == m)
    othermenu = hLog;
else
    othermenu = hLin;
end
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
    set(othermenu,'Checked','on');
else
    set(m,'Checked','on');
    set(othermenu,'Checked','off');
end
% Take the action
if strcmp(get(hLin,'Checked'),'on')
    this.AxesGrid.YScale = 'linear';
    % Enable units menu
    set(hUnits,'Enable','on');
else
    this.AxesGrid.YScale = 'log';
    % Disable units menu
    set(hUnits,'Enable','off');
end
% Update the plot options
p.PlotOptions.SpectrumAmpScale = this.AxesGrid.YScale;



function LocalMagnitudeScaleSummary(eventSrc, ~, this, hLin, hLog, p, hUnits)
% Set the frequency units
m = eventSrc;
if (hLin == m)
    othermenu = hLog;
else
    othermenu = hLin;
end
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
    set(othermenu,'Checked','on');
else
    set(m,'Checked','on');
    set(othermenu,'Checked','off');
end
% Take the action
if strcmp(get(hLin,'Checked'),'on')
    this.AxesGrid.YScale{1} = 'linear';
    % Enable units menu
    set(hUnits,'Enable','on');
else
    this.AxesGrid.YScale{1} = 'log';
    % Disable units menu
    set(hUnits,'Enable','off');
end
% Update the plot options
p.PlotOptions.SummaryMagScale = this.AxesGrid.YScale{1};


function LocalPhaseUnits(eventSrc, ~, this, hDeg, hRad, p )
% Set the frequency units
m = eventSrc;
if (hDeg == m)
    othermenu = hRad;
else
    othermenu = hDeg;
end
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
    set(othermenu,'Checked','on');
else
    set(m,'Checked','on');
    set(othermenu,'Checked','off');
end
% Take the action
if strcmp(get(hDeg,'Checked'),'on')
    this.AxesGrid.YUnits{2} = 'deg';
else
    this.AxesGrid.YUnits{2} = 'rad';
end
% Update the plot options
p.PlotOptions.SummaryPhaseUnits = this.AxesGrid.YUnits{2};

function LocalPhaseScale(eventSrc, ~, this, hLin, hLog, p)
% Set the frequency units
m = eventSrc;
if (hLin == m)
    othermenu = hLog;
else
    othermenu = hLin;
end
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
    set(othermenu,'Checked','on');
else
    set(m,'Checked','on');
    set(othermenu,'Checked','off');
end
% Take the action
if strcmp(get(hLin,'Checked'),'on')
    this.AxesGrid.YScale{2} = 'linear';    
else
    this.AxesGrid.YScale{2} = 'log';    
end
% Update the plot options
p.PlotOptions.SummaryPhaseScale = this.AxesGrid.YScale{2};

function LocalPhaseUnwrapping(eventSrc, ~, this, p)
% Set the frequency units
m = eventSrc;
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
else
    set(m,'Checked','on');
end
% Take the action
this.Options.UnwrapPhase = get(m,'Checked');
% Update the plot options
if strcmp(this.Options.UnwrapPhase,'on')
    p.PlotOptions.SummaryPhaseWrapping = 'off';
else
    p.PlotOptions.SummaryPhaseWrapping = 'on';
end


function LocalShowFilteredOutput(eventSrc, ~, this)
m = eventSrc;
% Toggle
if strcmp(get(m,'Checked'),'on')
    set(m,'Checked','off');
else
    set(m,'Checked','on');
end
% Take the action
this.SimulationData.ShowFilteredOutput = get(m,'Checked');
% Update title
if strcmp(get(m,'Checked'),'on')
    this.TimePlot.AxesGrid.Title = ctrlMsgUtils.message('Controllib:plots:strFilteredTimeResponse');
    this.SpectrumPlot.AxesGrid.Title = ctrlMsgUtils.message('Controllib:plots:strFilteredFFT');    
else
    this.TimePlot.AxesGrid.Title = ctrlMsgUtils.message('Controllib:plots:strTimeResponse');
    this.SpectrumPlot.AxesGrid.Title = ctrlMsgUtils.message('Controllib:plots:strFFT');
end
% Redraw everything
draw(this)
function out = LocalBool2OnOff(in)
if in
    out = 'on';
else
    out = 'off';
end










