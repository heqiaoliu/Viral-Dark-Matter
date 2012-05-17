function slideg(varargin)
%SLIDEG Slider Gain block helper function.
%   SLIDEG manages the dialog box for the Slider Gain block.
%   All block and Handle Graphics callbacks are funneled through
%   this SLIDEG.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.45.4.14 $

% Get current gcb handle and cache it away
% in case some other actions cause gcb to change
%
% In many cases, gcb will be the top mask block of the slider gain
% In some cases, gcb could be junk unrelated to the slider gain
%    this can happen when using the HG dialog with the slider widget
%
orig_gcbh = gcbh;
%
% Some older versions of the slider gain used 3 or 6 input args.
% Update them behind the scenes to the newest API.
%
switch nargin,
  
  case {4,6}

    LocalObsolete(orig_gcbh,nargin,varargin{1:end});
    Action = 'Open';

  case 0
    
    DAStudio.error('Simulink:dialog:SlidegNoArg');
    
  otherwise,
    
    Action = varargin{1};
    
    if 1 ~= nargin
        DAStudio.warning('Simulink:dialog:SlidegExtraArgs');
    end    
    
end

switch Action,
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Open - double click on the block %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'Open',
    blockHandleSliderGainTopMask = orig_gcbh;
    LocalOpenBlockFcn(blockHandleSliderGainTopMask);

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Close - close_system call %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'Close',
    blockHandleSliderGainTopMask = orig_gcbh;
    LocalCloseBlockFcn(blockHandleSliderGainTopMask);

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DeleteBlock - block is being deleted %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'DeleteBlock',
    blockHandleSliderGainTopMask = orig_gcbh;
    LocalDeleteBlockFcn(blockHandleSliderGainTopMask);

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Copy - block is being copied %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'Copy',
    blockHandleNewDestinationSliderGain = orig_gcbh;
    LocalCopyBlockFcn(blockHandleNewDestinationSliderGain);

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Load - block is being loaded %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'Load',
    blockHandleSliderGainTopMask = orig_gcbh;
    LocalLoadBlockFcn(blockHandleSliderGainTopMask);

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % NameChange - block name has been changed %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'NameChange',
    blockHandleSliderGainAfterNameChanged = orig_gcbh;
    LocalNameChangeBlockFcn(blockHandleSliderGainAfterNameChanged);

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ParentClose - block's parent has closed %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'ParentClose',
    blockHandleSliderGainTopMask = orig_gcbh;
    LocalParentCloseBlockFcn(blockHandleSliderGainTopMask);

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DeleteFigure - figure is being deleted %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                 gcb could be junk
  case 'DeleteFigure',
    LocalDeleteFigureFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % CloseRequest - figure is being closed %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                 gcb could be junk
  case 'CloseRequest',
    LocalCloseRequestFigureFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Help - help button has been pressed %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                 gcb could be junk
  case 'Help',
    LocalHelpFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Slider - slider is clicked on %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                 gcb could be junk
  case 'Slider',
    LocalSliderFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % LowEdit - low edit box edited %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                 gcb could be junk
  case 'LowEdit',
    LocalLowEditFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % GainEdit - gain edit box edited %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                 gcb could be junk
  case 'GainEdit',
    LocalGainEditFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % HighEdit - high edit box edited %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                 gcb could be junk
  case 'HighEdit',
    LocalHighEditFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % StartFcn
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'StartFcn',
    blockHandleSliderGainTopMask = orig_gcbh;
    LocalStartBlockFcn(blockHandleSliderGainTopMask)
   
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % StopFcn
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'StopFcn'
    blockHandleSliderGainTopMask = orig_gcbh;
    LocalStopBlockFcn(blockHandleSliderGainTopMask)
    
 otherwise,
    DAStudio.error('Simulink:dialog:UnknownAction',Action);

end % switch

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalParamsToMaskEntries
% Pass in the low, gain, and high values for the slider gain, and the
% appropriate entries will be set on the mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalParamsToMaskEntries(blockHandleSliderGainTopMask, low, gain, high)

maskNames = get_param(blockHandleSliderGainTopMask,'MaskNames');

set_param(blockHandleSliderGainTopMask,...
          maskNames{1},num2str(low),...
          maskNames{2},num2str(gain),...
          maskNames{3},num2str(high));

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalMaskEntriesToParams
% Convert the MaskEntries parameter of the current block to a vector with the
% low, gain, and high limits for the slider gain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [low,gain,high]=LocalMaskEntriesToParams(block)

parms = get_param(block,'MaskValues');
low   = str2double(parms{1});
gain  = str2double(parms{2});
high  = str2double(parms{3});

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalGetValue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function  value = LocalGetValue(low,gain,high)

if high == low
    value = 0.5;
else
    value = (gain-low)/(high-low);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalOpenBlockFcn
% Called when the slider gain is clicked on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalOpenBlockFcn(blockHandleSliderGainTopMask)

modelHandle = bdroot(blockHandleSliderGainTopMask);

%
% The slider gain dialog handle is stored in the block's user data
% If the figure is still valid and it's a slider gain figure, then
% bring it forward.  Otherwise, the dialog needs to be recreated.
%
FigHandle = get_param(blockHandleSliderGainTopMask,'UserData');
if ishghandle(FigHandle),
  set(FigHandle,'Visible','on');
  figure(FigHandle);
else
  if strcmp(get_param(modelHandle,'Lock'), 'on') || ...
     strcmp(get_param(blockHandleSliderGainTopMask,'LinkStatus'),'implicit')

      errordlg(...
          DAStudio.message('Simulink:dialog:SliderGainInLockLib'),...
          'Error', 'modal')
    return
  end

  dlgState = LocalGetDialogState(modelHandle);
  ScreenUnit = get(0,'Units');
  set(0,'Units','pixels');
  ScreenSize = get(0,'ScreenSize');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Following values used to be defined by 'layout'
  % Following in  pixels
  mStdButtonWidth = 90;
  mStdButtonHeight = 20;
  mFrameToText = 15;
  COMPUTER = computer;
  if strcmp(COMPUTER(1:2),'PC')
     mLineHeight = 13;
  else
     mLineHeight = 15;
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  ButtonWH = [mStdButtonWidth mStdButtonHeight];
  HS = 5;
  FigW = 3*mStdButtonWidth + 4*mFrameToText;
  FigH = 3*mStdButtonHeight + 5*HS + mLineHeight;
  FigurePos = [(ScreenSize(3)-FigW)/2 (ScreenSize(4)-FigH)/2 FigW FigH];

  bdPos  = get_param(get_param(blockHandleSliderGainTopMask,'Parent'), 'Location');
  blkPos = get_param(blockHandleSliderGainTopMask, 'Position');
  bdPos  = [bdPos(1:2)+blkPos(1:2) bdPos(1:2)+blkPos(1:2)+blkPos(3:4)];
  hgPos  = rectconv(bdPos,'hg');

  FigurePos(1) = hgPos(1)+(hgPos(3)-FigurePos(3));
  FigurePos(2) = hgPos(2)+(hgPos(4)-FigurePos(4));
  
  % make sure the dialog is not off the screen
  if FigurePos(1)<0
    FigurePos(1) = 1;
  elseif FigurePos(1)> ScreenSize(3)-FigurePos(3) 
    FigurePos(1) = ScreenSize(3)-FigurePos(3);
  end
  if FigurePos(2)<0
    FigurePos(2) = 1;
  elseif FigurePos(2)> ScreenSize(4)-FigurePos(4) 
    FigurePos(2) = ScreenSize(4)-FigurePos(4);
  end
  %
  % Remark: consider putting figure in middle of Simulink window
  %
  FigHandle=figure('Pos',            FigurePos,...
                   'Name',           get_param(blockHandleSliderGainTopMask,'Name'), ...
                   'Color',          get(0,'DefaultUIControlBackgroundColor'),...
                   'Resize',         'off',...
                   'NumberTitle',    'off',...
                   'MenuBar',        'none',...
                   'HandleVisibility','callback',...
                   'IntegerHandle',  'off',...
                   'CloseRequestFcn','slideg CloseRequest',...
                   'DeleteFcn',      'slideg DeleteFigure');

  %
  % Create static text
  %
  uicontrol('Parent',FigHandle,...
            'Style','text',...
            'String',xlate('Low','-s'),...
            'HorizontalAlignment','left',...
            'Position',[2*mFrameToText 2*mStdButtonHeight+3*HS mStdButtonWidth mLineHeight]);

  uicontrol('Parent',FigHandle,...
            'Style','text',...
            'String',xlate('High', '-s'),...
            'HorizontalAlignment','right', ...
            'Position',[2*mFrameToText+2*mStdButtonWidth 2*mStdButtonHeight+3*HS mStdButtonWidth mLineHeight]);

  %
  % Create slider
  % Remark: possibly check for value between zero and one
  %
  [low, gain, high] = LocalMaskEntriesToParams(blockHandleSliderGainTopMask);

  value = LocalGetValue(low,gain,high);
  position=[2*mFrameToText 2*mStdButtonHeight+mLineHeight+4*HS ...
            3*mStdButtonWidth mStdButtonHeight];
  ud.Slider = uicontrol('Parent',FigHandle,...
                        'Style','slider',...
                        'Value',value,...
                        'Position',position,...
                        'enable',dlgState,...
                        'Callback','slideg Slider');

  % Create editable controls
  Bup = 2*HS+mStdButtonHeight;
  ud.LowEdit=uicontrol('Parent',FigHandle,...
                       'Style','edit',...
                       'BackgroundColor','white', ...
                       'Position',[mFrameToText Bup ButtonWH], ...
                       'String',num2str(low),...
                       'UserData',low, ...
                       'enable',dlgState,...
                       'Callback','slideg LowEdit');

  ud.GainEdit=uicontrol('Parent',FigHandle,...
                        'Style','edit',...
                        'BackgroundColor','white', ...
                        'Position',[2*mFrameToText+mStdButtonWidth Bup ButtonWH], ...
                        'String',num2str(gain),...
                        'UserData',gain, ...
                        'enable',dlgState,...
                        'Callback','slideg GainEdit');
  ud.HighEdit=uicontrol('Parent',FigHandle,...
                        'Style','edit',...
                        'BackgroundColor','white', ...
                        'Pos',[3*mFrameToText+2*mStdButtonWidth Bup ButtonWH], ...
                        'String',num2str(high),...
                        'UserData',high, ...
                        'enable',dlgState,...
                        'Callback','slideg HighEdit');

  %
  % Create Close pushbutton
  %
  ud.Close=uicontrol('Parent',FigHandle,...
                    'Style','push',...
                    'String','Close', ...
                    'Position',[2*mStdButtonWidth+3*mFrameToText HS ButtonWH], ...
                    'Callback','slideg CloseRequest');

  %
  % Create Help pushbutton
  %
  ud.Help=uicontrol('Parent',FigHandle,...
                    'Style','push',...
                    'String','Help', ...
                    'Position',[mStdButtonWidth+2*mFrameToText HS ButtonWH], ...
                    'Callback','slideg Help');

  set(0,'Units',ScreenUnit);

  %
  % Set the vitals in the figure's user data
  %
  ud.blockHandleSliderGainTopMask = blockHandleSliderGainTopMask;
  set(FigHandle,'UserData',ud);

  %
  % Save this figure's handle in the block's user data
  %
  set_param(blockHandleSliderGainTopMask,'UserData',FigHandle)

end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDeleteBlockFcn
% Called when the slider gain block is deleted
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalDeleteBlockFcn(blockHandleSliderGainTopMask)

FigHandle=get_param(blockHandleSliderGainTopMask,'UserData');
if ishghandle(FigHandle),
  delete(FigHandle);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCloseBlockFcn
% Called when the slider gain block is closed via close_system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalCloseBlockFcn(blockHandleSliderGainTopMask)

FigHandle=get_param(blockHandleSliderGainTopMask,'UserData');
if ishghandle(FigHandle),
  delete(FigHandle);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDeleteFigureFcn
% Called when the slider gain figure is deleted
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalDeleteFigureFcn

FigHandle=get(0,'CallbackObject');
ud=get(FigHandle,'UserData');

set_param(ud.blockHandleSliderGainTopMask,'UserData',[]);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCloseRequestFigureFcn
% Called when the slider gain figure is closed by various means.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalCloseRequestFigureFcn

cbo=get(0,'CallbackObject');
cboType = get(cbo,'type');
switch cboType
  case 'uicontrol',
    FigHandle = get(cbo,'Parent');
  case 'figure'
    FigHandle = cbo;
  otherwise,
    DAStudio.error('Simulink:dialog:SlidegUnexpectedObject',mfilename);
end

delete(FigHandle);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalHelpFcn
% Called when the slider gain Help button is pressed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalHelpFcn

ud = get(gcf,'userdata');
slhelp(ud.blockHandleSliderGainTopMask);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCopyBlockFcn
% Called when the slider gain block is copied
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalCopyBlockFcn(blockHandleNewDestinationSliderGain)

% If the UserData is empty, the block might still be in a locked library,
% so don't bother trying to reset it unnecessarily.
if (~isempty(get_param(blockHandleNewDestinationSliderGain,'UserData')))
  set_param(blockHandleNewDestinationSliderGain,'UserData',[]);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalLoadBlockFcn
% Called when the slider gain block is loaded
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalLoadBlockFcn(blockHandleSliderGainTopMask)

if strcmpi(get_param(bdroot(blockHandleSliderGainTopMask),'BlockDiagramType'),'Model')
  set_param(blockHandleSliderGainTopMask,'UserData',[]);
end
DisallowUnitGainElimination(blockHandleSliderGainTopMask);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalNameChangeBlockFcn
% Called when the slider gain block name is changed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalNameChangeBlockFcn(blockHandleSliderGainAfterNameChanged)

FigHandle=get_param(blockHandleSliderGainAfterNameChanged,'UserData');
if ishghandle(FigHandle),
  set(FigHandle,'Name',get_param(blockHandleSliderGainAfterNameChanged,'Name'));
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalParentCloseBlockFcn
% Called when the slider gain block's parent is closed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalParentCloseBlockFcn(blockHandleSliderGainTopMask)

FigHandle=get_param(blockHandleSliderGainTopMask,'UserData');
if ishghandle(FigHandle),
  delete(FigHandle);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSliderFcn
% Called when the slider gain block slider is clicked on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalSliderFcn

FigHandle=gcf;
ud=get(FigHandle,'UserData');

[low, gain, high] = LocalMaskEntriesToParams(ud.blockHandleSliderGainTopMask);

gain=low+get(ud.Slider,'Value')*(high-low);

LocalSetLowGainHigh(ud, low, gain, high);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalScanEntry
% If scan fails, old value is returned.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [newValue,errstr] = LocalScanEntry(varNameStr,oldValue,textToScan)

newValue = oldValue;

scanSuccess = true;

[potentialNewValue, count, errstr] = sscanf(textToScan,'%f');

if ( ~isempty(errstr)                  || ...
     1 ~= count                        || ...
     isempty(potentialNewValue)        || ...
     any(~isfinite(potentialNewValue)) )

    scanSuccess = false;
else
    newValue = potentialNewValue;
end

if ~scanSuccess

    switch varNameStr
        
      case 'low'

        errstr=DAStudio.message('Simulink:dialog:SlidegInvalidLowerLimit',textToScan);

      case 'gain'
        
        errstr=DAStudio.message('Simulink:dialog:SlidegInvalidGainValue',textToScan);
        
      otherwise

        errstr=DAStudio.message('Simulink:dialog:SlidegInvalidUpperLimit',textToScan);
    end
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalLowEditFcn
% Called when the slider gain block low edit field is edited
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalLowEditFcn

warnstr = '';
FigHandle=gcf;
ud=get(FigHandle,'UserData');

[low, gain, high] = LocalMaskEntriesToParams(ud.blockHandleSliderGainTopMask);

[low,errstr] = LocalScanEntry('low',low,get(ud.LowEdit,'String'));

if ~isempty(errstr)

    errordlg(errstr,'Error','modal');
    return
end

% Modal diagnostic corrupts HG {get,set} operations
% Defer displaying warning diagnostic until posting new value 
if low > gain,
  warnstr=DAStudio.message('Simulink:dialog:SlidegLowerLimitGTGain', ...
                          sprintf('%g',low), ...
                          sprintf('%g',gain));
  low = gain;
end

value = LocalGetValue(low,gain,high);
set(ud.Slider,'Value',value);

LocalSetLowGainHigh(ud, low, gain, high);
set(ud.LowEdit ,'string',num2str(low))
set(ud.GainEdit,'string',num2str(gain))
set(ud.HighEdit,'string',num2str(high))

% Post diagnostics
if ~isempty(warnstr)
  warndlg(warnstr,'Warning','modal');
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalGainEditFcn
% Called when the slider gain block gain edit field is edited
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalGainEditFcn

FigHandle=gcf;
ud=get(FigHandle,'UserData');

[low, gain, high] = LocalMaskEntriesToParams(ud.blockHandleSliderGainTopMask);

[gain,errstr] = LocalScanEntry('gain',gain,get(ud.GainEdit,'String'));

if ~isempty(errstr)

    errordlg(errstr,'Error','modal');
    return
end

if (low > gain) 
  low = gain;
elseif (gain > high),
  high = gain;
end

value = LocalGetValue(low,gain,high);
set(ud.Slider,'Value',value);

LocalSetLowGainHigh(ud, low, gain, high);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalHighEditFcn
% Called when the slider gain block gain edit field is edited
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalHighEditFcn

warnstr = '';
FigHandle=gcf;
ud=get(FigHandle,'UserData');

[low, gain, high] = LocalMaskEntriesToParams(ud.blockHandleSliderGainTopMask);

[high,errstr] = LocalScanEntry('high',high,get(ud.HighEdit,'String'));

if ~isempty(errstr)
  errordlg(errstr,'Error','modal');
  return
end

% Modal diagnostics corrupt HG {get,set} operations
% Defer displaying warning diagnostic until posting new value 
if (gain > high),

    warnstr=DAStudio.message('Simulink:dialog:SlidegUpperLimitLTGain', ...
                             sprintf('%g',high), ...
                             sprintf('%g',gain));
    high = gain;
end

value = LocalGetValue(low,gain,high);
set(ud.Slider,'Value',value);

LocalSetLowGainHigh(ud, low, gain, high);

% Post diagnostics
if ~isempty(warnstr)
  warndlg(warnstr,'Warning','modal');
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalBlkHandleToPath
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function blkPathStr = LocalBlkHandleToPath(blockHandle)

blkPathStr = [ get_param(blockHandle,'Parent'),'/',get_param(blockHandle,'Name') ];

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSetLowGainHigh
% Beeps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalSetLowGainHigh(ud, low, gain, high)
modelHandle = bdroot(ud.blockHandleSliderGainTopMask);
if (strcmp(get_param(modelHandle,'SimulationStatus'),'initializing'))

    errstr=DAStudio.message('Simulink:dialog:SlidegNoChangeWhenInit');
    
    errordlg(errstr, LocalBlkHandleToPath(ud.blockHandleSliderGainTopMask), 'modal');    
    return;
end
try
  LocalParamsToMaskEntries(ud.blockHandleSliderGainTopMask, low, gain, high);
  set(ud.LowEdit ,'string',num2str(low))
  set(ud.GainEdit,'string',num2str(gain))
  set(ud.HighEdit,'string',num2str(high))
catch myException
  errstr=DAStudio.message('Simulink:dialog:SlidegMATLABError',myException.message);
  errordlg(errstr, LocalBlkHandleToPath(ud.blockHandleSliderGainTopMask), 'modal');
end


%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSetDialogWidgetsState
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalSetDialogWidgetsState(blockHandleSliderGainTopMask)
FigHandle = get_param(blockHandleSliderGainTopMask,'UserData');
if ishghandle(FigHandle)
  modelHandle = bdroot(blockHandleSliderGainTopMask);
  dlgState = LocalGetDialogState(modelHandle);
  ud= get(FigHandle,'UserData');
  set(ud.Slider,'enable',dlgState);
  set(ud.LowEdit ,'enable', dlgState)
  set(ud.GainEdit,'enable', dlgState)
  set(ud.HighEdit,'enable', dlgState)
  
end
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalStopBlockFcn
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalStopBlockFcn(blockHandleSliderGainTopMask)

LocalSetDialogWidgetsState(blockHandleSliderGainTopMask);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalStartBlockFcn
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalStartBlockFcn(blockHandleSliderGainTopMask)

LocalSetDialogWidgetsState(blockHandleSliderGainTopMask);
 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalGetDialogState
% Get the state of the dialog to enable/disable certain controls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function out = LocalGetDialogState(mdl)
out = 'on';
s = getModelSimStateTunability(mdl);
if ~s
  out = 'off';
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DisallowUnitGainElimination
% Do not allow block reduction for unit gai
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function DisallowUnitGainElimination(blockHandleSliderGainTopMask)
cr  = sprintf('\n');
blockHandleGainUnderMask=find_system(blockHandleSliderGainTopMask              , ...
                      'LookUnderMasks','all' , ...
                      'FollowLinks'   ,'on'  , ...
                      'BlockType',    'Gain'    , ...
                      'Name'          ,['Slider' cr 'Gain']...
                      );
if (~isempty(blockHandleGainUnderMask) && strcmp(get_param(bdroot(blockHandleSliderGainTopMask),'Lock'),'off'))
  set_param(blockHandleGainUnderMask,'AllowUnitGainElimination','off')
end


%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalObsolete
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalObsolete(orig_gcbh,nArgs,varargin)

if 6 == nArgs
    
    low  = varargin{3};    % used to be hi
    gain = varargin{4};    % used to be flag
    high = varargin{5};    % used to be trash1
    
else % if 4 == nArgs
    
    low  = varargin{1};    % used to be low
    gain = varargin{2};    % used to be Gain
    high = varargin{3};    % used to be high

end

set_param(orig_gcbh,...
          'MaskPromptString','Low|Gain|High',...
          'OpenFcn',          'slideg Open',...         % for double click
          'CloseFcn',         'slideg Close',...        % for close_system
          'DeleteFcn',        'slideg DeleteBlock',...  % for delete
          'CopyFcn',          'slideg Copy',...         % for copy (update copy's user data)
          'LoadFcn',          'slideg Load',...         % restore open state of dialog
          'NameChangeFcn',    'slideg NameChange',...   % for name changes
          'ParentCloseFcn',   'slideg ParentClose');    % for parental closure

LocalParamsToMaskEntries(orig_gcbh, low, gain, high);

DAStudio.warning('Simulink:dialog:SlidegObsolete',LocalBlkHandleToPath(orig_gcbh));
