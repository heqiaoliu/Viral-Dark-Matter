function h0 = stepplot(varargin)
%STEPPLOT  Step response of LTI models.
%
%   STEPPLOT, an extension of STEP, provides a command line interface for   
%   customizing the plot appearance.
%
%   STEPPLOT(SYS) plots the step response of the LTI model SYS (created 
%   with either TF, ZPK, or SS).  For multi-input models, independent
%   step commands are applied to each input channel.  The time range 
%   and number of points are chosen automatically.
%
%   STEPPLOT(SYS,TFINAL) simulates the step response from t=0 to the 
%   final time t=TFINAL.  For discrete-time models with unspecified 
%   sampling time, TFINAL is interpreted as the number of samples.
%
%   STEPPLOT(SYS,T) uses the user-supplied time vector T for simulation. 
%   For discrete-time models, T should be of the form  Ti:Ts:Tf 
%   where Ts is the sample time.  For continuous-time models,
%   T should be of the form  Ti:dt:Tf  where dt will become the sample 
%   time for the discrete approximation to the continuous system.  The
%   step input is always assumed to start at t=0 (regardless of Ti).
%
%   STEPPLOT(SYS1,SYS2,...,T) plots the step response of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The time vector T is 
%   optional.  You can also specify a color, line style, and marker 
%   for each system, as in 
%      stepplot(sys1,'r',sys2,'y--',sys3,'gx').
%
%   STEPPLOT(AX,...) plots into the axes with handle AX.
%
%   STEPPLOT(..., PLOTOPTIONS) plots the step response with the options
%   specified in PLOTOPTIONS. See TIMEOPTIONS for more detail.
%
%   H = STEPPLOT(...) returns the handle to the step response plot. You can
%   use this handle to customize the plot with the GETOPTIONS and
%   SETOPTIONS commands.  See TIMEOPTIONS for a list of available plot
%   options.
%
%   Example:
%       sys = rss(3);
%       h = stepplot(sys);
%       % Normalize responses
%       setoptions(h,'Normalize','on');
%	
%   See also STEP, TIMEOPTIONS, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%   Author(s): J.N. Little, 4-21-85
%   Revised:   A.C.W.Grace, 9-7-89, 5-21-92
%   Revised:   P. Gahinet, 4-18-96
%   Revised:   A. DiVergilio, 6-16-00
%   Revised:   B. Eryilmaz, 6-6-01
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:45 $

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
   [sysList,t] = DynamicSystem.checkStepInputs(sysList,Extras);
catch E
   throw(E)
end

% Derive plot I/O size
[InputName,OutputName,EmptySys] = mrgios(sysList.System);
if any(EmptySys)
   ctrlMsgUtils.warning('Control:analysis:PlotEmptyModel')
end

% Step response plot
% Create plot (visibility ='off')
try
   if isempty(ax)
      ax = gca;
   end
   h = ltiplot(ax,'step',InputName,OutputName,OptionsObject,cstprefs.tbxprefs);
catch E
   throw(E)
end

% Set global time focus for user-defined range/vector (sets preferred X limits)
if length(t) == 1
   h.setfocus([0, t],'sec')
elseif ~isempty(t)
   h.setfocus([t(1) t(end)],'sec')
end

% Create and configure responses
for ct=1:length(sysList)
   sysInfo = sysList(ct);
   if ~isempty(sysInfo.System) % skip empty systems
      % Link each response to system source
      src = resppack.ltisource(sysInfo.System, 'Name', sysInfo.Name);
      r = h.addresponse(src);
      DefinedCharacteristics = src.getCharacteristics('step');
      r.setCharacteristics(DefinedCharacteristics);
      r.DataFcn = {'timeresp' src 'step' r t};
      r.Context = struct('Type','step');
      % Styles and preferences
      initsysresp(r,'step',h.Options,sysInfo.Style)
   end
end

% Draw now
if strcmp(h.AxesGrid.NextPlot, 'replace')
   h.Visible = 'on';  % new plot created with Visible='off'
else
   draw(h)  % hold mode
end

% Right-click menus
ltiplotmenu(h, 'step');

if nargout
   h0 = h;
end
