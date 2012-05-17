function msfunpsd(block, varargin)
%MSFUNPSD an MATLAB S-function which performs spectral analysis using ffts.
%   This MATLAB file is designed to be used in a Simulink M-S-function block.
%   It stores up a buffer of input and output points of the system
%   then plots the power spectral density of the input signal.
%
%     The input arguments are:
%     npts:           number of points to use in the fft (e.g. 128)
%     HowOften:       how often to plot the ffts (e.g. 64)
%     offset:         sample time offset (usually zeros)
%     ts:             how often to sample points (secs)
%     averaging:      whether to average the psd or not
%
%   Two or three plots are given: the time history, the instantaneous psd
%   the average psd.
%
%   See also, FFT, SPECTRUM, SFUNTMPL, SFUNTF.

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
%   Andrew Grace 5-30-91.
%   Revised Wes Wang 4-28-93, 8-17-93.
%   Revised Charlie Ko 9-26-96.
%   Revised Veena Mellarkod 9-18-08

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
    
%endfunction

function setup(block)


npts = block.DialogPrm(2).Data;
HowOften = block.DialogPrm(3).Data;
offset = block.DialogPrm(4).Data;
ts = block.DialogPrm(5).Data;

if HowOften > npts
    DAStudio.error('Simulink:blocks:numberOfBufferPointsGreaterThanPlotFreq');
end

if (ts < 0.0)
    DAStudio.error('Simulink:blocks:sampleTimeMustBePositive');
end

% Register number of ports
block.NumInputPorts  = 1;
block.NumOutputPorts = 0;

% Override input port properties
block.InputPort(1).DirectFeedthrough = 0;

% Register parameters
block.NumDialogPrms     = 6;
block.SampleTimes = [ts offset];
block.SetSimViewingDevice(true);

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @LocalBlockStartFcn);
block.RegBlockMethod('Update', @Update);

% call backs
SetBlockCallbacks(gcbh);
%end setup

function DoPostPropSetup(block)
  block.NumDworks = 1;
  fftpts = block.DialogPrm(1).Data;
  npts = block.DialogPrm(2).Data;
  averaging = block.DialogPrm(6).Data;
  
  block.Dwork(1).Name            = 'vis';
  block.Dwork(1).Dimensions      = npts + 2 + averaging * round(fftpts/2) + 1; % No. of stored values
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = 0;

%end DoPostPropSetup

function InitializeConditions(block)
block.Dwork(1).Data(1,1) = 1; % initialize counter
%end InitializeConditions

function Update(block)
% mdlUpdates - Compute Discrete State updates.
%
%
   % get dialog param values
  fftpts = block.DialogPrm(1).Data;
  npts = block.DialogPrm(2).Data;
  HowOften = block.DialogPrm(3).Data;
  ts = block.DialogPrm(5).Data;
  averaging = block.DialogPrm(6).Data;

   % input data
   u        = block.InputPort(1).Data;
   % Dwork values used for visualization
   x        = block.Dwork(1).Data;
   % current time
   t        = block.CurrentTime;
   %
   % Find the figure handle associated with this block. If the handle
   % is not valid (i.e. - the user closed the figure during simulation),
   % mdlUpdates performs no operations.
   %
   FigHandle = GetSfunPSDFigure(gcbh);
   if (~ishghandle(FigHandle))
      return
   end
   %
   % Initialize sys.
   %
   sys = x;
   %
   % Increment the counter and store the current input in the
   % discrete state referenced by this counter.
   %

   % make sure the counter is real positive integer
   block.Dwork(1).Data(1,1) = round(block.Dwork(1).Data(1,1));

   block.Dwork(1).Data(1,1)  = block.Dwork(1).Data(1,1) + 1;
   x(1,1) = block.Dwork(1).Data(1,1);
   sys(x(1,1),:) = u(:).';
   sys(x(1)) = u;
   %
   % Check whether it is the time to update plots
   %
   if (rem(x(1),HowOften) == 0)
      ud = get(FigHandle,'UserData');
      ptsind = 1:npts;
      buffer = [sys(x(1)+1:npts+1);sys(2:x(1))];
      n = round(fftpts/2);                         % Used round as in mdlInitializeSizes
      freq = 2*pi/ts;                              % Multiply by 2*pi to get radians
      w = freq*(0:n-1)./(2*(n-1));
      %
      % Detrend the data: remove best straight line fit
      %
      a = [ptsind.'/npts,ones(npts,1)];
      y = buffer-a*(a\buffer);
      %
      % Hammining window to remove transient effects at the
      % beginning and end of the time sequence.
      %
      nw = min(fftpts,npts);
      win = 0.5*(1-cos(2*pi*(1:nw).'/(nw+1)));
      g = fft(y(1:nw).*win,fftpts);
      u = win.'*win;
      syy = g.*conj(g)/u;
      gyy = g;
      s = max(fix(npts/n)-1,1);                    % If no overlap, use fftpts instead of n
      %
      % Perform averaging with overlap if number of fftpts is less than buffer
      % For no overlap set ng = fftpts:fftpts:npts-fftpts.
      %
      for ng = n:n:(npts-fftpts)
         g = fft(y(ng+1:ng+fftpts).*win,fftpts);
         syy = syy+g.*conj(g)/u;
         gyy = gyy+g;
      end
      gyy = gyy/s;
      syy = syy/s;
      syy = [syy(1);2*syy(2:n)];
      psd = syy*(ts/(2*pi));
      tvec = t-ts*npts+ts*ptsind;
      xlim = [tvec(1),tvec(end)];
      %
      % For time history plot.
      %
      ylim = getLimits(buffer);
      set(ud.TimeHistoryAxis,'Visible','on','Xlim',xlim,'Ylim',ylim);
      set(ud.TimeHistoryInputLine,'XData',tvec,'YData',buffer);
      set(ud.TimeHistoryTitle,'String','Time history');
      xl = get(ud.TimeHistoryAxis,'Xlabel');
      set(xl,'String','Time (secs)');
      %
      % Check whether we have to perform averaging
      %
      if (averaging)
         cnt = sys(npts+2+n);		                    % Counter for averaging
         sys(npts+2:npts+1+n) = cnt/(cnt+1)*sys(npts+2:npts+1+n)+psd/(cnt+1);
         sys(npts+2+n) = sys(npts+2+n)+1;
         psd = sys(npts+3:npts+1+n);
         tmp = 'Average Power Spectral Density';
      else
         tmp = 'Power Spectral Density';
         psd = psd(2:n);
      end
      ylim = getLimits(psd);
      %
      % For the PSD plot.
      %
      w2n = w(2:n);
      xlim = [w2n(1),w2n(end)];
      set(ud.PSDAxis,'Visible','on','Xlim',xlim,'Ylim',ylim);
      set(ud.PSDInputLine,'XData',w2n,'YData',psd);
      set(ud.PSDTitle,'String',tmp);
      
      xl = get(ud.PSDAxis,'Xlabel');
      yl = get(ud.PSDAxis,'Ylabel');
      set([xl,yl],{'String'},{'Frequency (rads/sec)';'Mag^2/(rad/sec)'});
      
      phase = (180/pi)*unwrap(atan2(imag(gyy),real(gyy)));
      phase = phase(2:n);
      ylim = getLimits(phase);
      %
      % For phase plot
      %
      set(ud.PhaseAxis,'Visible','on','Xlim',xlim,'Ylim',ylim);
      set(ud.PhaseInputLine,'XData',w2n,'YData',phase);
      set(ud.PhaseTitle,'String',cat(2,tmp,'(phase)'));
      xl = get(ud.PhaseAxis,'Xlabel');
      yl = get(ud.PhaseAxis,'Ylabel');
      set([xl,yl],{'String'},{'Frequency (rads/sec)';'Degrees'});
      drawnow
   end
   %
   % If the buffer is full, reset the counter. The counter is store in
   % the first discrete state.
   %
   if sys(1,1) == npts
      block.Dwork(1).Data(1,1) = 1;
   end
   sys(1,1) = block.Dwork(1).Data(1,1);

   % resaving back to DWork
   block.Dwork(1).Data = sys(:);
%end Update

function limits = getLimits(signal)
%GETLIMITS Returns lower and upper limits associated with the SIGNAL.
%          NaN/Inf values are removed from the signal before the calculation.
%
   s = signal(isfinite(signal));
   if (isempty(s)), s = 0; end
   smin = min(s);
   smax = max(s);
   sdel = (smax-smin)/100+eps;
   limits = [smin-sdel,smax+sdel];
   return
%endlimits
   


%
%=============================================================================
% LocalBlockStartFcn
% Function that is called when the simulation starts.  Initialize the
% XY Graph scope figure.
%=============================================================================
%
function LocalBlockStartFcn(block)

%
% Retrieve the block's figure handle.
%
FigHandle = GetSfunPSDFigure(gcbh);
if isempty(FigHandle)
  FigHandle=-1;
end

if ~ishghandle(FigHandle)
  FigHandle = CreateSfunPSDFigure;
end
ud = get(FigHandle,'UserData');
set(ud.TimeHistoryTitle,'String','Working - please wait');

% end LocalBlockStartFcn

%
%===========================================================================
% CreateSfunPSDFigure
% Creates the figure window that is associated with the PSD Block.
%===========================================================================
%
function FigHandle=CreateSfunPSDFigure

bh=gcbh;
if strcmp(get_param(bh,'BlockType'),'M-S-Function')
    bh = get_param(get_param(bh,'Parent'),'Handle');
end
%
% The figure doesn't already exist, create one.
%
FigHandle = figure('Units',        'points',...
                   'Position',     GetFigurePosition,...
                   'MenuBar',      'none',...
                   'NumberTitle',  'off',...
                   'IntegerHandle','off',...
                   'Name',         get_param(bh,'Name'),...
		   'DeleteFcn',    'msfunpsd([],''DeleteFigure'')');

%
% Store the block's handle in the figure's UserData.
%
ud.Block=bh;

%
% Create the various objects within the figure.
%

% Subplot of the time history data.
ud.TimeHistoryAxis = subplot(311);
set(ud.TimeHistoryAxis,'Position',[.13 .72 .77 .2]);
ud.TimeHistoryInputLine = plot(0,0,'m');
ud.TimeHistoryTitle = get(ud.TimeHistoryAxis,'Title');
set(ud.TimeHistoryAxis,'Visible','off');

% Subplot of the Power Spectral Density.
ud.PSDAxis = subplot(312);
set(ud.PSDAxis,'Position',[.13 .4 .77 .2]);
ud.PSDInputLine = plot(0,0);
ud.PSDTitle = get(ud.PSDAxis,'Title');
set(ud.PSDAxis,'Visible','off');

% Subplot of the phase shift diagram.
ud.PhaseAxis = subplot(313);
set(ud.PhaseAxis,'Position',[.13 .08 .77 .2]);
ud.PhaseInputLine = plot(0,0);
ud.PhaseTitle = get(ud.PhaseAxis,'Title');
set(ud.PhaseAxis,'Visible','off');

%
% Place the figure handle in the current block's UserData.  Then
% place the various object handles into the Figure's UserData.
%
SetSfunPSDFigure(bh,FigHandle);
set(FigHandle,'HandleVisibility','off','UserData',ud);

% end CreateSfunPSDFigure

%
%===========================================================================
% GetSfunPSDFigure
% Retrieves the figure handle that is associated with this block from the
% block's parent subsystem's UserData.
%===========================================================================
%
function FigHandle=GetSfunPSDFigure(block)

if strcmp(get_param(block,'BlockType'),'M-S-Function'),
  block=get_param(block,'Parent');
end

FigHandle=get_param(block,'UserData');
if isempty(FigHandle),
  FigHandle=-1;
end

% end GetSfunPSDFigure.

%
%===========================================================================
% SetSfunPSDFigure
% Stores the figure handle that is associated with this block into the
% block's UserData.
%===========================================================================
%
function SetSfunPSDFigure(block,FigHandle)

if strcmp(get_param(block,'BlockType'),'M-S-Function'),
  block=get_param(block,'Parent');
end

set_param(block,'UserData',FigHandle);

% end SetSfunPSDFigure.

%
%=============================================================================
% LocalBlockNameChangeFcn
% Function that handles name changes on the PSD Graph scope block.
%=============================================================================
%
function LocalBlockNameChangeFcn

%
% get the figure associated with this block, if it's valid, change
% the name of the figure
%
FigHandle = GetSfunPSDFigure(gcbh);
if ishghandle(FigHandle),
  set(FigHandle,'Name',get_param(gcbh,'Name'));
end

% end LocalBlockNameChangeFcn

%
%=============================================================================
% LocalBlockLoadCopyFcn
% This is the PSD block's CopyFcn and LoadFcn.  Initialize the block's
% UserData such that a figure is not associated with the block.
%=============================================================================
%
function LocalBlockLoadCopyFcn

SetSfunPSDFigure(gcbh,-1);

% end LocalBlockLoadCopyFcn

%
%=============================================================================
% LocalBlockDeleteFcn
% This is the PSD block's DeleteFcn.  Delete the block's figure
% window, if present, upon deletion of the block.
%=============================================================================
%
function LocalBlockDeleteFcn

%
% Get the figure handle, the second arg to SfunCorrFigure is set to zero
% so that function doesn't create the figure if it doesn't exist.
%
FigHandle=GetSfunPSDFigure(gcbh);
if ishghandle(FigHandle)
  delete(FigHandle);
  SetSfunPSDFigure(gcbh,-1);
end

% end LocalBlockDeleteFcn

%
%=============================================================================
% LocalFigureDeleteFcn
% This is the PSD's figure window's DeleteFcn.  The figure window
% is being deleted, update the correlation block's UserData to
% reflect the change.
%=============================================================================
%
function LocalFigureDeleteFcn

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
SetSfunPSDFigure(ud.Block,-1)

% end LocalFigureDeleteFcn

%
%=============================================================================
% SetBlockCallbacks
% This sets the LoadFcn, CopyFcn and DeleteFcn of the block.
%=============================================================================
%
function SetBlockCallbacks(block)

%
% the actual source of the block is the parent subsystem
%
block=get_param(block,'Parent');

%
% if the block isn't linked, issue a warning, and then set the callbacks
% for the block so that it has the proper operation
%
if strcmp(get_param(block,'LinkStatus'),'none'),
  DAStudio.warning('Simulink:blocks:replacementOfFunctionByBlock', 'Power Spectral Density Graph scope', block);
  callbacks={'CopyFcn',       'msfunpsd([],''CopyBlock'')' ;
             'DeleteFcn',     'msfunpsd([],''DeleteBlock'')';
             'LoadFcn',       'msfunpsd([],''LoadBlock'')';
             'StartFcn',      'msfunpsd([],''Start'')';
             'NameChangeFcn', 'msfunpsd([],''NameChange'')'};

  for i=1:length(callbacks),
    if ~strcmp(get_param(block,callbacks{i,1}),callbacks{i,2}),
      set_param(block,callbacks{i,1},callbacks{i,2})
    end
  end
end

% end SetBlockCallbacks

%
%=============================================================================
% GetFigurePosition
% This deciphers the figure position based on the screen size
%=============================================================================
%
function figpos = GetFigurePosition
    
    origRootUnitSetting = get(0,'Units');
    set(0,'Units','points'); % Work using points as units for consistency
    
    %% defaultPosition = [lowerx lowery width height]
    
    defaultPosition = [100 100 400 510];
    screenSize = get(0,'screenSize');
    
    %% Make sure that figure does not go off the screen
    %% to the right
    
    screenWidth = screenSize(3);
    
    if (defaultPosition(1) + defaultPosition(3)) > screenWidth
        defaultPosition(3) = screenWidth - 50 - defaultPosition(1);
    end
    
    %% Make sure that figure does not go off the top of
    %% the screen
    
    screenHeight = screenSize(4);
    
    if (defaultPosition(2) + defaultPosition(4)) > screenHeight
        defaultPosition(4) = screenHeight - 50 - defaultPosition(2);
    end
    
    set(0,'Units',origRootUnitSetting);
    figpos = defaultPosition;
    
    
    


