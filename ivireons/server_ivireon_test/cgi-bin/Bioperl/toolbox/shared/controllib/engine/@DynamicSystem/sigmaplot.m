function h0 = sigmaplot(varargin)
%   SIGMAPLOT  Singular value plot of LTI models.
%
%   SIGMAPLOT, an extension of SIGMA, provides a command line interface for   
%   customizing the plot appearance.
%
%   SIGMAPLOT(SYS) produces a singular value (SV) plot of the frequency 
%   response of the LTI model SYS (created with TF, ZPK, SS, or FRD).  
%   The frequency range and number of points are chosen automatically.  
%   See BODE for details on the notion of frequency in discrete time.
%
%   SIGMAPLOT(SYS,{WMIN,WMAX}) draws the SV plot for frequencies ranging
%   between WMIN and WMAX (in radian/second).
%
%   SIGMAPLOT(SYS,W) uses the user-supplied vector W of frequencies, in
%   radians/second, at which the frequency response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   SIGMAPLOT(SYS,W,TYPE) or SIGMAPLOT(SYS,[],TYPE) draws the following
%   modified SV plots depending on the value of TYPE:
%          TYPE = 1     -->     SV of  inv(SYS)
%          TYPE = 2     -->     SV of  I + SYS
%          TYPE = 3     -->     SV of  I + inv(SYS) 
%   SYS should be a square system when using this syntax.
%
%   SIGMAPLOT(AX,...) plots into the axes with handle AX.
%
%   SIGMAPLOT(..., PLOTOPTIONS) plots the singular values with the options
%   specified in PLOTOPTIONS. See SIGMAOPTIONS for more details. 
%
%   H = SIGMAPLOT(...) returns the handle to the singular value plot. You 
%   can use this handle to customize the plot with the GETOPTIONS and 
%   SETOPTIONS commands.  See SIGMAOPTIONS for a list of available plot 
%   options.
%
%   Example:
%       sys = rss(5);
%       h = sigmaplot(sys);
%       % Change units to Hz 
%       setoptions(h,'FreqUnits','Hz');
%   
%   See also SIGMA, SIGMAOPTIONS, WRFC/SETOPTIONS, WRFC/GETOPTIONS.

%	Andrew Grace  7-10-90
%	Revised ACWG 6-21-92
%	Revised by Richard Chiang 5-20-92
%	Revised by W.Wang 7-20-92
%       Revised P. Gahinet 5-7-96
%       Revised A. DiVergilio 6-16-00
%       Revised K. Subbarao 10-11-01
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:38 $

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
   [sysList,w,type] = DynamicSystem.checkSigmaInputs(sysList,Extras);
catch ME
   throw(ME)
end

% Create plot
if isempty(ax)
   ax = gca;
end
h = ltiplot(ax,'sigma',[],[],OptionsObject,cstprefs.tbxprefs);

% Set global frequency focus for user-defined range/vector (specifies preferred limits)
if iscell(w)
    h.setfocus([w{:}],'rad/sec')
elseif ~isempty(w)
    w = unique(w); % (g212788)
    h.setfocus([w(1) w(end)],'rad/sec')
end

% Create responses
NameForms = {'inv(%s)' , '1+%s' , '1+inv(%s)'};
for ct=1:length(sysList)
   sysInfo = sysList(ct);
   if ~isempty(sysInfo.System) % skip empty systems
      src = resppack.ltisource(sysInfo.System,'Name',sysInfo.Name);
      r = h.addresponse(src);
      DefinedCharacteristics = src.getCharacteristics('sigma');
      r.setCharacteristics(DefinedCharacteristics);
      % Handle special types
      if type>0
         % Doctor response name
         r.Name = sprintf(NameForms{type},r.Name);
         src.Name = r.Name;  % used by data tips
      end
      r.DataFcn = {'sigma' src r w type};
      % Styles and preferences
      initsysresp(r,'sigma',h.Options,sysInfo.Style)
   end
end

% Draw now
if strcmp(h.AxesGrid.NextPlot,'replace')
   h.Visible = 'on';  % new plot created with Visible='off'
else
   draw(h)  % hold mode
end

% Right-click menus
ltiplotmenu(h,'sigma');

if nargout
   h0 = h;
end


