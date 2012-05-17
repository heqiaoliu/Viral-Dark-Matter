function msfuncorr(block, varargin)
%MSFUNCORR an MATLAB S-function which performs auto- and cross-correlation.
%   This MATLAB file is designed to be used in a Simulink S-function block.
%   It stores up a buffer of input and output points of the system
%   then plots the power spectral density of the input signal.
%
%   The input arguments are:
%       npts:      number of points to use in the fft (e.g. 128)
%       howOften:  how often to plot the ffts (e.g. 64)
%       offset:    sample time offset (usually zeros)
%       ts:        how often to sample points (secs)
%       cross:     set to 1 for cross-correlation 0 for auto
%       biased:    set to 'biased' or 'unbiased'
%
%   The cross correlator gives two plots: the time history,
%   and the auto- or cross-correlation.
%
%   See also, SFUNTMPL, XCORR, SFUNPSD.

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $
  if (nargin < 2)
     setup(block);
     return;
  end;
  flag = varargin{1};
  switch flag
  %%%%%%%%%
  % Start %
  %%%%%%%%%
  case 'Start'
    LocalBlockStartFcn
      
  %%%%%%%%%%%%%%
  % NameChange %
  %%%%%%%%%%%%%%
  case 'NameChange'
    LocalBlockNameChangeFcn

  %%%%%%%%%%%%%%%%%%%%%%%%
  % CopyBlock, LoadBlock %
  %%%%%%%%%%%%%%%%%%%%%%%%
  case { 'CopyBlock', 'LoadBlock' }
    LocalBlockLoadCopyFcn

  %%%%%%%%%%%%%%%
  % DeleteBlock %
  %%%%%%%%%%%%%%%
  case 'DeleteBlock'
    LocalBlockDeleteFcn

  %%%%%%%%%%%%%%%%
  % DeleteFigure %
  %%%%%%%%%%%%%%%%
  case 'DeleteFigure'
    LocalFigureDeleteFcn     
    
  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    if ischar(flag),
      DAStudio.error('Simulink:blocks:unhandledFlag', flag);
    else
      DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));
    end
  end
    
% end of msfuncorr

   
function setup(block)   
    % Register number of ports
    %block.NumInputPorts  = block.DialogPrm(5).Data+1;
    block.NumInputPorts = 1;
    block.NumOutputPorts = 0;

    % Override input port properties
    block.InputPort(1).DirectFeedthrough = 1;
    
    % Inherited Sample Time
    block.SampleTimes = [block.DialogPrm(4).Data block.DialogPrm(3).Data];

    % Set the block simStateCompliance to default (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';
    
    % Register parameters
    block.NumDialogPrms     = 6;
    block.SetSimViewingDevice(true);

    block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
    block.RegBlockMethod('InitializeConditions', @InitConditions);
    block.RegBlockMethod('Start', @LocalBlockStartFcn);
    block.RegBlockMethod('Update', @Update);
    SetBlockCallbacks(block.BlockHandle);
     
%endfunction
 
function DoPostPropSetup(block)

  %% Setup Dwork
  block.NumDworks = 1;
  block.Dwork(1).Name = 'vis'; 
  block.Dwork(1).UsedAsDiscState = 0;
  block.Dwork(1).Dimensions      = (block.DialogPrm(5).Data+1) * (block.DialogPrm(1).Data+1);
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
 
%endfunction

%
%=============================================================================
% LocalBlockStartFcn
% Function that is called when the simulation starts.  Initialize the
% Cross Correlation scope figure.
%=============================================================================
%
function LocalBlockStartFcn(block)%#ok

FigHandle = GetSfunCorrFigure(gcbh);

if ~ishghandle(FigHandle),
  FigHandle = CreateSfunCorrFigure;
end
ud = get(FigHandle,'UserData');
switch GetSfunCorrType(gcbh)

  case 'cross'
    set(ud.Input1Line,'XData',0,'YData',0);
    set(ud.Input2Line,'XData',0,'YData',0);

  case 'auto'
    set(ud.Input1Line,'XData',0,'YData',0);

end
set(ud.TimeHistoryTitle,'String','Working - please wait');

%endfunction


function InitConditions(block)

  %% Initialize Dwork
  % first value is a counter
  block.Dwork(1).Data(1,1) = 1;
  
%endfunction



%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function Update(block)
% dialog prms
npts     = block.DialogPrm(1).Data;
howOften = block.DialogPrm(2).Data;
offset   = block.DialogPrm(3).Data;%#ok
ts       = block.DialogPrm(4).Data;
cross    = block.DialogPrm(5).Data;
biased   = block.DialogPrm(6).Data;

% input data
u        = block.InputPort(1).Data;
% The work values are used only for display and not for storing
x        = block.Dwork(1).Data;
% current time
t        = block.CurrentTime;
%
% Locate the figure window associated with this block. If it's not a valid
% handle (it may have been closed by the user), then return.
%
FigHandle=GetSfunCorrFigure(gcbh,cross);
if ~ishghandle(FigHandle),
  return
end

%
% initialize sys
%
sys = zeros(npts+1,1+cross);
sys(:) = x;

%
% increment the counter and store the current input in the discrete state
% referenced by this counter
%

% make sure the counter is real positive integer
block.Dwork(1).Data(1,1) = round(block.Dwork(1).Data(1,1));

block.Dwork(1).Data(1,1)  = block.Dwork(1).Data(1,1) + 1;
x(1,1) = block.Dwork(1).Data(1,1);
sys(x(1,1),:) = u(:).';

if rem(x(1,1),howOften)==0,

  ud = get(FigHandle,'UserData');
  lasta = [sys(x(1,1)+1:npts+1,1);sys(2:x(1,1),1)];
  if cross
    lastb = [sys(x(1,1)+1:npts+1,2);sys(2:x(1,1),2)];
    % Take real part to avoid small residual complex part
    y = real(xcorr(lasta,lastb,biased));
  else
    y = real(xcorr(lasta,biased));
  end

  tvec = (t - ts * sys(x(1,1)) + ts * (1:npts))';
  npts1 = npts-1;
  lvec = (-npts1:1:npts1).'*ts;
  if cross
    set(ud.TimeHistoryAxis,...
        'Visible','on',...
        'Xlim', [min(tvec) max(tvec)],...
        'Ylim', [min(min([lasta;lastb])) max(max([lasta;lastb+eps]))]);
    set(ud.Input1Line,'XData',tvec,'YData',lasta);
    set(ud.Input2Line,'XData',tvec,'YData',lastb);
  else
    set(ud.TimeHistoryAxis,...
        'Visible','on',...
        'Xlim',[min(tvec)  max(tvec)],...
	'Ylim',[min(lasta) max(lasta+eps)]);
     set(ud.Input1Line,'XData',tvec,'YData',lasta)
  end

  set(ud.TimeHistoryTitle,'String','Time history')
  set(ud.AutoCorrLine,'XData',lvec,'YData',y)
  xl = get(ud.TimeHistoryAxis,'Xlabel');
  set(xl,'String','Time (secs)')
  set(ud.AutoCorrAxis,...
      'Visible','on',...
      'Xlim',[min(lvec),max(lvec)],...
      'Ylim',[min(y) max(y)+eps]);

  if cross
    set(ud.AutoCorrTitle,'String',['Cross correlation (', biased, ')'])
  else
    set(ud.AutoCorrTitle,'String',['Auto correlation (',biased, ')'])
  end

  xl = get(ud.AutoCorrAxis,'Xlabel');
  set(xl,'String','Lag (secs)')
  set(FigHandle,'Color',get(FigHandle,'Color'));

  drawnow
end

%
% if the buffer's full, then reset the counter (it's stored in the first
% Dwork data)
%

if sys(1,1) == npts
  block.Dwork(1).Data(1,1) = 1;
end
sys(1,1) = block.Dwork(1).Data(1,1);

% resaving back to DWork
block.Dwork(1).Data = sys(:);
%endfunction

%
%=============================================================================
% LocalBlockNameChangeFcn
% Function that handles name changes on the cross correlation block.
%=============================================================================
%
function LocalBlockNameChangeFcn

%
% the figure handle is stored in the block's UserData
%
FigHandle = GetSfunCorrFigure(gcbh);
if (~isempty(FigHandle) && (FigHandle ~= -1)),
  set(FigHandle,'Name',get_param(gcbh,'Name'));
end

% end LocalBlockNameChangeFcn

%
%=============================================================================
% LocalBlockLoadCopyFcn
% This is the Auto Correlation or Cross Correlation block's CopyFcn and
% LoadFcn.  Initialize the block's UserData such that a figure is not
% associated with the block.
%=============================================================================
%
function LocalBlockLoadCopyFcn

SetSfunCorrFigure(gcbh,-1);

% end LocalBlockLoadCopyFcn

%
%=============================================================================
% LocalBlockDeleteFcn
% This is the Auto Correlation or Cross Correlation block's
% DeleteFcn.  Delete the block's figure window, if present, upon
% deletion of the block.
%=============================================================================
%
function LocalBlockDeleteFcn(block)

%
% Get the figure handle, the second arg to SfunCorrFigure is set to zero
% so that function doesn't create the figure if it doesn't exist.
%
FigHandle=GetSfunCorrFigure(gcbh);
if ishghandle(FigHandle),
  delete(FigHandle);
  SetSfunCorrFigure(gcbh,-1);
end

% end LocalBlockDeleteFcn

%
%=============================================================================
% LocalFigureDeleteFcn
% This is the Auto Correlation or Cross Correlation figure window's
% DeleteFcn.  The figure window is being deleted, update the correlation
% block's UserData to reflect the change.
%=============================================================================
%
function LocalFigureDeleteFcn

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
SetSfunCorrFigure(ud.Block,-1)

% end LocalBlockDeleteFcn

%
%=============================================================================
% GetSfunCorrType
% Retrieves the type of correlation block, 'cross' or 'auto'.
%=============================================================================
%
function corrType=GetSfunCorrType(block)

if strcmp(get_param(block,'BlockType'),'M-S-Function'),
  block=get_param(block,'Parent');
end

maskType = get_param(block,'MaskType');

switch maskType,

  case 'Cross Correlator'
    corrType = 'cross';
 
  case 'Auto Correlator'
    corrType = 'auto';

  otherwise,
    DAStudio.error('Simulink:blocks:undefinedCorrelationType', maskType);

end
% end GetSfunCorrType

%
%=============================================================================
% GetSfunCorrFigure
% Retrieves the figure window associated with this M-S-function correlation block
% from the block's parent subsystem's UserData.
%=============================================================================
%
function FigHandle=GetSfunCorrFigure(block,FigHandle)%#ok

if strcmp(get_param(block,'BlockType'),'M-S-Function'),
  block=get_param(block,'Parent');
end

FigHandle=get_param(block,'UserData');
if isempty(FigHandle),
  FigHandle=-1;
end
% end GetSfunCorrFigure

%
%=============================================================================
% SetSfunCorrFigure
% Stores the figure window associated with this M-S-function correlation block
% in the block's parent subsystem's UserData.
%=============================================================================
%
function SetSfunCorrFigure(block,FigHandle)

if strcmp(get_param(block,'BlockType'),'M-S-Function'),
  block=get_param(block,'Parent');
end

set_param(block,'UserData',FigHandle);
% end SetSfunCorrFigure

%
%=============================================================================
% CreateSfunCorrFigure
% Creates the figure window associated with this M-S-function correlation block.
%=============================================================================
%
function FigHandle=CreateSfunCorrFigure

bh=gcbh;
if strcmp(get_param(bh,'BlockType'),'M-S-Function')
    bh = get_param(get_param(bh,'Parent'),'Handle');
end
%
% the figure doesn't exist, create one
%
FigHandle = figure('Unit',         'pixel',...
                   'Position',     [100 100 500 400],...
                   'MenuBar',      'none',...
                   'NumberTitle',  'off',...
                   'Name',         get_param(bh,'Name'),...
                   'IntegerHandle','off',...
		           'DeleteFcn',    'msfuncorr([],''DeleteFigure'')');

%
% store the block's handle in the figure's UserData
%
ud.Block=bh;

%
% create the various objects in the figure
%
ud.TimeHistoryAxis = subplot(211);
switch GetSfunCorrType(bh),
  case 'cross',
    hold on
    ud.Input1Line = plot(0,0);
    ud.Input2Line = plot(0,0);
    hold off

  case 'auto'
    ud.Input1Line = plot(0,0);
end
set(ud.TimeHistoryAxis,'Visible','off');
ud.TimeHistoryTitle = get(ud.TimeHistoryAxis,'Title');
set(ud.TimeHistoryTitle,'String','Working - please wait');

ud.AutoCorrAxis=subplot(212);
ud.AutoCorrLine = plot(0,0);
ud.AutoCorrTitle = get(ud.AutoCorrAxis,'Title');
set(ud.AutoCorrAxis,'Visible','off');

%
% squirrel away the figure handle in the current block, and put the
% various handles into the figure's UserData
%
SetSfunCorrFigure(bh,FigHandle);
set(FigHandle,'HandleVisibility','callback','UserData',ud);

% end CreateSfunCorrFigure

%
%=============================================================================
% SetBlockCallbacks
% This sets the callbacks of the block if it is not a reference.
%=============================================================================
%
function SetBlockCallbacks(blockh)

%
% the actual source of the block is the parent subsystem
%
blockp=get_param(blockh,'Parent');

%
% if the block isn't linked, issue a warning, and then set the callbacks
% for the block so that it has the proper operation
%
if strcmp(get_param(blockp,'LinkStatus'),'none'),
  warnmsg=sprintf(['The Cross Correlation scope ''%s'' should be replaced with a ' ...
                   'new version from the simulink_extras block library'],...
                   blockp);
  warning(warnmsg);%#ok

  callbacks={
    'CopyFcn',       'msfuncorr([],''CopyBlock'')' ;
    'DeleteFcn',     'msfuncorr([],''DeleteBlock'')' ;
    'LoadFcn',       'msfuncorr([],''LoadBlock'')' ;
    'StartFcn',      'msfuncorr([],''Start'')' ;
    'NameChangeFcn', 'msfuncorr([],''NameChange'')' ;
  };

  for i=1:length(callbacks),
    if ~strcmp(get_param(blockp,callbacks{i,1}),callbacks{i,2}),
      set_param(blockp,callbacks{i,1},callbacks{i,2})
    end
  end
end

% end SetBlockCallbacks
