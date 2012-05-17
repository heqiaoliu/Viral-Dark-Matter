function h0 = lsimplot(varargin)
%LSIMPLOT  Simulate time response of LTI models to arbitrary inputs.
%
%   LSIMPLOT, an extension of LSIM, provides a command line interface for   
%   customizing the plot appearance.
%
%   LSIMPLOT(SYS) opens the Linear Simulation Tool for the LTI model SYS
%   (created with either TF, ZPK, or SS), which enables interactive
%   specification of driving input(s), the time vector, and initial
%   state.
%
%   LSIMPLOT(SYS1,SYS2,...) opens the Linear Simulation Tool for multiple
%   LTI models SYS1,SYS2,.... Driving inputs are common to all specified
%   systems but initial conditions can be specified separately for each.
%
%   LSIMPLOT(SYS,U,T) plots the time response of the LTI model SYS to the
%   input signal described by U and T.  The time vector T consists of 
%   regularly spaced time samples. For MIMO systems U is a matrix with
%   as many columns as inputs and whose i-th row specifies the input value
%   at time T(i). For SISO systems U can be specified either as a row or
%   column vector.
%   For example, 
%           t = 0:0.01:5;   u = sin(t);   lsimplot(sys,u,t)  
%   simulates the response of a single-input model SYS to the input 
%   u(t)=sin(t) during 5 seconds.
%
%   For discrete-time models, U should be sampled at the same rate as SYS
%   (T is then redundant and can be omitted or set to the empty matrix).
%   For continuous-time models, choose the sampling period T(2)-T(1) small 
%   enough to accurately describe the input U.  LSIM issues a warning when
%   U is undersampled and hidden oscillations may occur.
%         
%   LSIMPLOT(SYS,U,T,X0) specifies the initial state vector X0 at time T(1) 
%   (for state-space models only).  X0 is set to zero when omitted.
%
%   LSIMPLOT(SYS1,SYS2,...,U,T,X0) simulates the response of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The initial condition X0 
%   is optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      lsimplot(sys1,'r',sys2,'y--',sys3,'gx',u,t).
%
%   LSIMPLOT(AX,...) plots into the axes with handle AX.
%
%   LSIMPLOT(..., PLOTOPTIONS) plots the initial condition response 
%   with the options specified in PLOTOPTIONS. See TIMEOPTIONS for 
%   more detail.
%
%   H = LSIMPLOT(...) returns the handle to the simulated time response 
%   plot. You can use this handle to customize the plot with the 
%   GETOPTIONS and SETOPTIONS commands.  See TIMEOPTIONS for a list 
%   of available plot options.
%
%   For continuous-time models,
%      LSIMPLOT(SYS,U,T,X0,'zoh')  or  LSIMPLOT(SYS,U,T,X0,'foh') 
%   explicitly specifies how the input values should be interpolated 
%   between samples (zero-order hold or linear interpolation).  By 
%   default, LSIM selects the interpolation method automatically based 
%   on the smoothness of the signal U.
%
%   See also LSIM, GENSIG, TIMEOPTIONS, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%   To compute the time response of continuous-time systems, LSIM uses linear 
%   interpolation of the input between samples for smooth signals, and 
%   zero-order hold for rapidly changing signals like steps or square waves. 

%	J.N. Little 4-21-85
%	Revised 7-31-90  Clay M. Thompson
%       Revised A.C.W.Grace 8-27-89 (added first order hold)
%	                    1-21-91 (test to see whether to use foh or zoh)
%	Revised 12-5-95 Andy Potvin
%       Revised 5-8-96  P. Gahinet
%       Revised 6-16-00 A. DiVergilio
%	Copyright 1986-2010 The MathWorks, Inc. 
%	$Revision: 1.1.8.2 $  $Date: 2010/04/11 20:35:52 $

% Get argument names
for ct = length(varargin):-1:1
    ArgNames(ct,1) = {inputname(ct)};
end

% Parse input list
% Check for axes argument
if ishghandle(varargin{1},'axes')
    ax = varargin{1};
    varargin(1) = [];
    ArgNames(1) = [];
else
    ax = [];
end

try
   [sysList,Extras,OptionsObject] = DynamicSystem.parseRespFcnInputs(varargin,ArgNames);
   [sysList,t,x0,u,InterpRule] = DynamicSystem.checkLsimInputs(sysList,Extras);
catch E
   throw(E)
end

% Can only plot real data
if ~(isreal(u) && isreal(x0))
    ctrlMsgUtils.error('Control:analysis:lsim5')
end

% Derive plot I/O size
[InputName,OutputName,EmptySys] = mrgios(sysList.System);
if any(EmptySys)
   ctrlMsgUtils.warning('Control:analysis:PlotEmptyModel')
end

% Create plot
try
   if isempty(ax)
      ax = gca;
   end
   h = ltiplot(ax,'lsim',InputName,OutputName,OptionsObject,cstprefs.tbxprefs);
catch ME
   throw(ME)
end

% Add responses
for ct=1:length(sysList)
   sysInfo = sysList(ct);
   Sizes = size(sysInfo.System);
   Sizes(2) = [];
   if all(Sizes)
      src = resppack.ltisource(sysInfo.System, 'Name', sysInfo.Name);
      r = h.addresponse(src);
      DefinedCharacteristics = src.getCharacteristics('lsim');
      r.setCharacteristics(DefinedCharacteristics);
      r.DataFcn = {'lsim' src r};
      % Styles and options
      initsysresp(r,'lsim',h.Options,sysInfo.Style)
      % Place any specified initial conditions in responses jgo
      r.context.IC = x0;
   end
end

DefinedCharacteristics = struct(...
    'CharacteristicLabel', ctrlMsgUtils.message('Controllib:plots:strPeakResponse'), ...
    'CharacteristicID', 'PeakResponse', ...
    'CharacteristicData', 'wavepack.TimePeakAmpData',...
    'CharacteristicView', 'resppack.SimInputPeakView',...
    'CharacteristicGroup', 'Characteristic');

for ct1 = 1:length(h.Input)
    h.Input(ct1).setCharacteristics(DefinedCharacteristics);
end

% Assign default InputIndex values
localizeInputs(h)
% If no inputs specified, open the lsim GUI
thisDataExceptionWarning = h.DataExceptionWarning;
if isempty(u)
    % Temporarily turn off data exception warning to suppress
    % insufficient inputs warning
    h.DataExceptionWarning = 'off';
    h.lsimgui('lsiminp'); %open lsim GUI
else % Otherwise add input data etc.
    h.Input.Interpolation = InterpRule; % Assign interpolation rule
    setinput(h,t,u,'TimeUnits','sec'); % Add input signal
    h.Input.Visible = 'on';
end
% Draw now
if strcmp(h.AxesGrid.NextPlot,'replace')
    h.Visible = 'on';  % new plot created with Visible='off'
else
    draw(h)  % hold mode
end
h.DataExceptionWarning = thisDataExceptionWarning;
% Right-click menus
ltiplotmenu(h,'lsim');

if nargout
    h0 = h;
end