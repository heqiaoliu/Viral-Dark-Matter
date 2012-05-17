function h = ltiplot(ax,PlotType,InputNames,OutputNames,PlotOptions,Prefs,varargin)
%LTIPLOT  Construct LTI plot using @resppack.
%
%   H = LTIPLOT(AX,PlotType,InputNames,OutputNames,Preferences) where
%     * AX is an HG axes handle
%     * PlotType is the response type
%     * InputNames and OutputNames are the I/O names (specify axes grid size)
%     * PlotOptions is a PlotOptions object for initializing the plot.
%     * Prefs = Preference object (tbxprefs or viewprefs)

%   Author(s): Adam DiVergilio, P. Gahinet, B. Eryilmaz
%   Revised  : Kamesh Subbarao, 10-15-2001
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.53.4.10 $ $Date: 2008/12/29 01:47:06 $

% Get plot object if exists
h = gcr(ax);

% Get plot add/replace status
NewPlot = strcmp(get(ax,'NextPlot'),'replace');
NewRespPlot = NewPlot || isempty(h);

% Generate appropriate plot options for this plot
PlotOptions = ltiplotoption(PlotType,PlotOptions,Prefs,NewRespPlot,h);

% Check hold state
% Used to see if grid is on
if ~NewPlot && isempty(h) && ~isempty(findall(ax,'Tag','CSTgridLines'))
   PlotOptions.Grid = 'on';
end

% Clear and reset axes if new plot
if NewPlot
  % Clear any existing response plot upfront (otherwise style
  % settings below get erased by CLA in respplot/check_hold)
  if ~isempty(h)
    cla(h.AxesGrid,handle(ax))  % speed optimization
  end
  
  % Release manual limits and hide axis for optimal performance
  % RE: Manual negative Xlim can cause warning for BODE (not reset by clear)
  set(ax,'Visible','off','XlimMode','auto','YlimMode','auto')
end

% Style settings specific to LTI plots
if NewRespPlot
  set(ax,...
      'XGrid',      PlotOptions.Grid,...
      'YGrid',      PlotOptions.Grid,...
      'XColor',     PlotOptions.TickLabel.Color,...
      'YColor',     PlotOptions.TickLabel.Color,...
      'FontSize',   PlotOptions.TickLabel.FontSize,...
      'FontWeight', PlotOptions.TickLabel.FontWeight,...
      'FontAngle',  PlotOptions.TickLabel.FontAngle,...
      'Selected',   'off')
  set(get(ax,'Title'),...
      'FontSize',  PlotOptions.Title.FontSize,...
      'FontWeight',PlotOptions.Title.FontWeight,...
      'FontAngle', PlotOptions.Title.FontAngle)
  set(get(ax,'XLabel'),...
      'Color',     PlotOptions.XLabel.Color,...
      'FontSize',  PlotOptions.XLabel.FontSize,...
      'FontWeight',PlotOptions.XLabel.FontWeight,...
      'FontAngle', PlotOptions.XLabel.FontAngle)
  set(get(ax,'YLabel'),...
      'Color',     PlotOptions.YLabel.Color,...
      'FontSize',  PlotOptions.YLabel.FontSize,...
      'FontWeight',PlotOptions.YLabel.FontWeight,...
      'FontAngle', PlotOptions.YLabel.FontAngle)
end

% Create plot
GridSize = [length(OutputNames) , length(InputNames)];  % generic case
Settings = {'InputName',  InputNames, ...
      'OutputName', OutputNames,...
      'Tag', PlotType};

switch PlotType
   case 'bode'
      h = resppack.bodeplot(ax, GridSize, Settings{:}, varargin{:}); 
   case 'impulse'
      h = resppack.timeplot(ax, GridSize, Settings{:}, varargin{:});
   case 'initial'
      h = resppack.simplot(ax,GridSize(1),...
         'OutputName', OutputNames, 'Tag', PlotType, varargin{:});
   case 'iopzmap'
      h = resppack.pzplot(ax, GridSize,...
         Settings{:}, 'FrequencyUnits', PlotOptions.FreqUnits, varargin{:});  
   case 'hsv'
      h = resppack.hsvplot(ax, 'Tag', PlotType, varargin{:});
   case 'lsim'
      h = resppack.simplot(ax, GridSize(1),...
         'OutputName', OutputNames, 'Tag', PlotType, varargin{:});
      h.setInputWidth(length(InputNames));
      h.Input.ChannelName = InputNames;
   case 'nichols'
      h = resppack.nicholsplot(ax, GridSize, Settings{:}, varargin{:});
   case 'nyquist'
      h = resppack.nyquistplot(ax, GridSize, Settings{:},...
         'FrequencyUnits', PlotOptions.FreqUnits, varargin{:});
   case 'pzmap'
      h = resppack.mpzplot(ax,'Tag', PlotType,...
         'FrequencyUnits', PlotOptions.FreqUnits, varargin{:});  
   case 'rlocus'
      h = resppack.rlplot(ax,'Tag', PlotType,...
         'FrequencyUnits', PlotOptions.FreqUnits, varargin{:});  
   case 'sigma'
      h = resppack.sigmaplot(ax, 'Tag', PlotType, varargin{:});  
   case 'step'
      h = resppack.timeplot(ax, GridSize, Settings{:}, varargin{:});
end

% Delete datatips when the axis is clicked
set(allaxes(h),'ButtonDownFcn',{@LocalAxesButtonDownFcn h}) %Temporary workaround
%set(allaxes(h),'ButtonDownFcn',@(eventsrc,y) defaultButtonDownFcn(h,eventsrc))

% Control cursor and datatip popups over characteristic markers
% REVISIT: remove this code when MouseEntered/Exited event available
fig = ancestor(h.AxesGrid.Parent,'figure');
if isempty(get(fig,'WindowButtonMotionFcn'))
   set(fig,'WindowButtonMotionFcn',@(x,y) hoverfig(fig))
   % Customize datacursor to use datatip style and not
   % cursor window
   hTool = datacursormode(fig);
   %% Set default Z-Stacking and datatip styles
   set(hTool,'EnableZStacking',true);
   set(hTool,'ZStackMinimum',10);
   set(hTool,'DisplayStyle','datatip');
end

% Limit management
if any(strcmp(PlotType, {'step','impulse','initial'}))
   L = handle.listener(h.AxesGrid, 'PreLimitChanged', @LocalAdjustSimHorizon);
   set(L, 'CallbackTarget', h);
   h.addlisteners(L);
end

% set plot properties
setoptions(h,PlotOptions);


%-------------------------Local Functions--------------------------------%
%------------------------------------------------------------------------%
% Purpose: Recompute responses to span the x-axis limits
%------------------------------------------------------------------------%
function LocalAdjustSimHorizon(this, eventdata)
Responses = this.Responses;
Tfinal = max(getfocus(this));
for ct = 1:length(Responses)
   DataSrc = Responses(ct).DataSrc;
   if ~isempty(DataSrc)
      try
         % Read plot type (step, impulse, or initial) from Tag 
         % (needed for step+hold+impulse)
         UpdateFlag = DataSrc.fillresp(Responses(ct),Tfinal);
         if UpdateFlag
            draw(Responses(ct))
         end
      end
   end
end



% Temporary workaround
% ----------------------------------------------------------------------------% 
% Purpose: Axes callback to delete datatips when clicked 
% ----------------------------------------------------------------------------% 
function LocalAxesButtonDownFcn(EventSrc,EventData,RespPlot)
% Axes ButtonDown function
% Process event

switch get(ancestor(EventSrc,'figure'),'SelectionType')
    case 'normal'
        PropEdit = PropEditor(RespPlot,'current');  % handle of (unique) property editor
        if ~isempty(PropEdit) && PropEdit.isVisible
            % Left-click & property editor open: quick target change
            PropEdit.setTarget(RespPlot);
        end
        % Get the cursor mode object
        hTool = datacursormode(ancestor(EventSrc,'figure'));
        % Clear all data tips
        target = handle(EventSrc);
        if ishghandle(target,'axes')
            removeAllDataCursors(hTool,target);
        end
    case 'open'
        % Double-click: open editor
        if usejava('MWT')
            PropEdit = PropEditor(RespPlot);
            PropEdit.setTarget(RespPlot);
        end
end