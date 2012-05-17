function h0 = nyquistplot(varargin)
%NYQUISTPLOT  Nyquist frequency response of LTI models.
%
%   NYQUISTPLOT, an extension of NYQUIST, provides a command line interface
%   for customizing the plot appearance.
%
%   NYQUISTPLOT(SYS) draws the Nyquist plot of the LTI model SYS
%   (created with either TF, ZPK, SS, or FRD).  The frequency range 
%   and number of points are chosen automatically.  See BODE for  
%   details on the notion of frequency in discrete-time.
%
%   NYQUISTPLOT(SYS,{WMIN,WMAX}) draws the Nyquist plot for frequencies
%   between WMIN and WMAX (in radians/second).
%
%   NYQUISTPLOT(SYS,W) uses the user-supplied vector W of frequencies 
%   (in radian/second) at which the Nyquist response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   NYQUISTPLOT(SYS1,SYS2,...,W) plots the Nyquist response of multiple
%   LTI models SYS1,SYS2,... on a single plot.  The frequency vector
%   W is optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      nyquistplot(sys1,'r',sys2,'y--',sys3,'gx').
%
%   NYQUISTPLOT(AX,...) plots into the axes with handle AX.
%
%   NYQUISTPLOT(..., PLOTOPTIONS) plots the Nyquist response with the 
%   options specified in PLOTOPTIONS. See NYQUISTOPTIONS for more details. 
%
%   H = NYQUISTPLOT(...) returns the handle to the Nyquist plot. You can 
%   use this handle to customize the plot with the GETOPTIONS and 
%   SETOPTIONS commands.  See NYQUISTOPTIONS for a list of available plot 
%   options.
%
%   Example:
%       sys = rss(5);
%       h = nyquistplot(sys);
%       % Change units to Hz 
%       setoptions(h,'FreqUnits','Hz');
%
%   See also NYQUIST, NYQUISTOPTIONS, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%   Authors: P. Gahinet 6-21-96
%   Revised: A. DiVergilio, 6-16-00
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:16 $

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
   [sysList,w] = DynamicSystem.checkBodeInputs(sysList,Extras);
catch ME
   throw(ME)
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
   h = ltiplot(ax,'nyquist',InputName,OutputName,OptionsObject,cstprefs.tbxprefs);
catch E
   throw(E)
end

if isnumeric(w)
   % Unique frequencies, to avoid interpolation incompatibility
   % for other calculations. Resolution for G154921
   w = unique(w);
end

% Create responses
for ct=1:length(sysList)
   sysInfo = sysList(ct);
   if ~isempty(sysInfo.System) % skip empty systems
      src = resppack.ltisource(sysInfo.System,'Name',sysInfo.Name);
      r = h.addresponse(src);
      DefinedCharacteristics = src.getCharacteristics('nyquist');
      r.setCharacteristics(DefinedCharacteristics);
      r.DataFcn = {'nyquist' src r w};
      % Styles and preferences
      initsysresp(r,'nyquist',h.Options,sysInfo.Style)
   end
end

% Draw now
if strcmp(h.AxesGrid.NextPlot,'replace')
    h.Visible = 'on';  % new plot created with Visible='off'
else
    draw(h)  % hold mode
end

% Right-click menus
ltiplotmenu(h,'nyquist');

if nargout
    h0 = h;
end  
