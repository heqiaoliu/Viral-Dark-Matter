function h0 = impulseplot(varargin)
%IMPULSEPLOT  Impulse response plot of LTI models.
%
%   IMPULSEPLOT, an extension of IMPULSE, provides a command line interface
%   for customizing the plot appearance.
%
%   IMPULSEPLOT(SYS) plots the impulse response of the LTI model SYS
%   (created with either TF, ZPK, or SS).  For multi-input models,
%   independent impulse commands are applied to each input channel.  The
%   time range and number of points are chosen automatically.  For
%   continuous systems with direct feedthrough, the infinite pulse at t=0
%   is disregarded.
%
%   IMPULSEPLOT(SYS,TFINAL) simulates the impulse response from t=0 to the 
%   final time t=TFINAL.  For discrete-time systems with unspecified 
%   sampling time, TFINAL is interpreted as the number of samples.
%
%   IMPULSEPLOT(SYS,T) uses the user-supplied time vector T for simulation. 
%   For discrete-time models, T should be of the form  Ti:Ts:Tf  
%   where Ts is the sample time.  For continuous-time models, 
%   T should be of the form  Ti:dt:Tf  where dt will become the sample 
%   time of a discrete approximation to the continuous system.  The
%   impulse is always assumed to arise at t=0 (regardless of Ti).
%
%   IMPULSEPLOT(SYS1,SYS2,...,T) plots the impulse response of multiple
%   LTI models SYS1,SYS2,... on a single plot.  The time vector T is 
%   optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      impulseplot(sys1,'r',sys2,'y--',sys3,'gx').
%
%   IMPULSEPLOT(AX,...) plots into the axes with handle AX.
%
%   IMPULSEPLOT(..., PLOTOPTIONS) plots the impulse response with 
%   the options specified in PLOTOPTIONS. See TIMEOPTIONS for more detail.
%
%   H = IMPULSEPLOT(...) returns the handle to the impulse response plot. 
%   You can use this handle to customize the plot with the GETOPTIONS and 
%   SETOPTIONS commands.  See TIMEOPTIONS for a list of available plot 
%   options.
%
%   Example:
%       sys = rss(3);
%       h = impulseplot(sys);
%       % Normalize responses
%       setoptions(h,'Normalize','on');
%
%   See also  IMPULSE, TIMEOPTIONS, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%	J.N. Little 4-21-85
%	Revised: 8-1-90  Clay M. Thompson, 2-20-92 ACWG, 10-1-94 
%	Revised: P. Gahinet, 4-24-96
%	Revised: A. DiVergilio, 6-16-00
%       Revised: B. Eryilmaz, 10-01-01
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:56 $

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

% Create plot
try
    if isempty(ax)
        ax = gca;
    end
    h = ltiplot(ax,'impulse',InputName,OutputName,OptionsObject,cstprefs.tbxprefs);
catch ME
    throw(ME)
end

% Set global time focus for user-defined range/vector (sets preferred X limits)
if length(t) == 1
    h.setfocus([0, t],'sec')
elseif ~isempty(t)
    h.setfocus([t(1) t(end)],'sec')
end

% Create responses
for ct = 1:length(sysList)
   sysInfo = sysList(ct);
   if ~isempty(sysInfo.System) % skip empty systems
      src = resppack.ltisource(sysInfo.System, 'Name', sysInfo.Name);
      r = h.addresponse(src);
      DefinedCharacteristics = src.getCharacteristics('impulse');
      r.setCharacteristics(DefinedCharacteristics);
      r.DataFcn = {'timeresp' src 'impulse' r t};
      r.Context = struct('Type','impulse');
      % Styles and preferences
      initsysresp(r,'impulse',h.Options,sysInfo.Style)
   end
end

% Draw now
if strcmp(h.AxesGrid.NextPlot,'replace')
    h.Visible = 'on';  % new plot created with Visible='off'
else
    draw(h)  % hold mode
end

% Right-click menus
ltiplotmenu(h, 'impulse');


if nargout
    h0 = h;
end
