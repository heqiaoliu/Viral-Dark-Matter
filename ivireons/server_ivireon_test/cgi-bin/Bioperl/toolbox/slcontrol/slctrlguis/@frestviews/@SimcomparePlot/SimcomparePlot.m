function p = SimcomparePlot(ax,sys,gridsize)
%  SIMCOMPAREPLOT  Constructor for @SimcomparePlot class
%
%

% Author(s): Erman Korkut 23-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/10/16 06:46:13 $

% Get plot object if exists
p = gcr(ax);

% Get plot add/replace status
NewPlot = strcmp(get(ax,'NextPlot'),'replace');

% Clear and reset axes if new plot
if NewPlot
  % Clear any existing response plot upfront (otherwise style
  % settings below get erased by CLA in respplot/check_hold)
  if ~isempty(p)
    cla(p.AxesGrid,handle(ax))  % speed optimization
  end
  
  % Release manual limits and hide axis for optimal performance
  % RE: Manual negative Xlim can cause warning for BODE (not reset by clear)
  set(ax,'Visible','off','XlimMode','auto','YlimMode','auto')
end

axopts = ltiplotoption('step',[],cstprefs.tbxprefs,1,[]);
frest.frestutils.initAxisSettings(ax,axopts);

% Create the class instance
p = frestviews.SimcomparePlot;

% Check for hold mode
[p,HeldRespFlag] = check_hold(p, ax, gridsize);
if HeldRespFlag
   % Adding to an existing response (h overwritten by that response's handle)
   % RE: Skip property settings as I/O-related data may be incorrectly sized (g118113)
   return
end

% Generic property init
init_prop(p, ax, gridsize);

% User-specified initial values (before listeners are installed...)
p.set('InputName', sys.InputName, 'OutputName', sys.OutputName);

% Initialize the handle graphics objects used in @timeplot class.
p.initialize(ax, gridsize);



end







