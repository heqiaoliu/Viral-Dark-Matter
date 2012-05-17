function addconstr(this, Constr, varargin) 
% ADDCONSTR  method to add a requirement to a time plot
%
 
% Author(s): A. Stothert 20-Sep-2005
% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:37:52 $

if nargin > 2
   doInit = ~strcmp(varargin{1},'NoInitialization');
else
   doInit = true;
end

if doInit
   % REVISIT: should call grapheditor::addconstr to perform generic init
   Axes = this.AxesGrid;
   
   % Generic init (includes generic interface editor/constraint)
   initconstr(this,Constr)
   
   % Add related listeners
   L = handle.listener(Axes,Axes.findprop('XUnits'), 'PropertyPostSet', {@LocalSetUnits,Constr});
   Constr.addlisteners(L);
   
   % Activate (initializes graphics and targets constr. editor)
   Constr.Activated = 1;
   
   % Update limits
   Axes.send('ViewChanged')
end

%Add to list of requirements on the plot
this.Requirements = vertcat(this.Requirements,Constr);
end

function LocalSetUnits(eventSrc,eventData,Constr)
% Syncs constraint props with related Editor props
Constr.setDisplayUnits(eventSrc.Name,eventData.NewValue)
Constr.TextEditor.setDisplayUnits(lower(eventSrc.Name),eventData.NewValue)
% Update constraint display (and notify observers)
update(Constr)
end
