function bodemag(varargin)
%BODEMAG  Bode magnitude plot for linear systems.
%
%   BODEMAG(SYS) plots the magnitude of the frequency response of the
%   linear system SYS (Bode plot without the phase diagram). The frequency 
%   range and number of points are chosen automatically.
%
%   BODEMAG(SYS,{WMIN,WMAX}) draws the magnitude plot for frequencies
%   between WMIN and WMAX (in radians/second).
%
%   BODEMAG(SYS,W) uses the user-supplied vector W of frequencies, in
%   radian/second, at which the frequency response is to be evaluated.  
%
%   BODEMAG(SYS1,SYS2,...,W) shows the frequency response magnitude of
%   several linear models SYS1,SYS2,... on a single plot. The frequency 
%   vector W is optional. You can also specify a color, line style,  
%   and marker for each model, as in  
%      bodemag(sys1,'r',sys2,'y--',sys3,'gx').
%
%   For additional options for Bode magnitude plots, see BODEPLOT.
%
%   See also BODEPLOT, BODE, LTIVIEW.

%   Authors: P. Gahinet, A. DiVergilio
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:29 $
ni = nargin;
% Use argument name for systems without name
ArgNames = cell(ni,1);
for ct=1:ni
   ArgNames(ct) = {inputname(ct)};
end
varargin = argname2sysname(varargin,ArgNames);
% Set PhaseVisible = 'off'
idx = find(cellfun(@(arg) isa(arg,'plotopts.BodePlotOptions'),varargin));
if isempty(idx)
   Options = plotopts.BodePlotOptions;
   idx = nargin+1;
else
   Options = varargin{idx};
end
Options.PhaseVisible = 'off';
varargin{idx} = Options;

% Call BODEPLOT
try
   h = bodeplot(varargin{:});
catch E
   throw(E)
end

% Make GCA one of the visible axes (to ensure YLABEL, AXIS,... work properly)
ax = getaxes(h,'2d');
if ~any(handle(gca)==ax(1:2:end))
   set(ax(1).Parent,'CurrentAxes',ax(end-1))
end
