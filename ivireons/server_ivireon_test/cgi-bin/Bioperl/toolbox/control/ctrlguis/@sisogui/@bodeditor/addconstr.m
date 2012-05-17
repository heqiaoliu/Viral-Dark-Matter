function addconstr(Editor, Constr)
%ADDCONSTR  Add Generic constraint to editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2009/05/23 07:53:13 $

% REVISIT: should call grapheditor::addconstr to perform generic init
LoopData = Editor.LoopData;
Axes = Editor.Axes;

% Generic init (includes generic interface editor/constraint)
initconstr(Editor,Constr)

% Add related listeners 
pu = [Axes.findprop('XUnits');Axes.findprop('YUnits')];
L = [handle.listener(LoopData,LoopData.findprop('Ts'),'PropertyPostSet',{@LocalUpdate,Constr});...
      handle.listener(Axes,pu,'PropertyPostSet', {@LocalSetUnits,Constr})];
Constr.addlisteners(L);

% Activate (initializes graphics and targets constr. editor)
Constr.Activated = 1;

% Update limits
updateview(Editor)

% --------------------------- Local Functions ----------------------------------%

function LocalUpdate(eventSrc,eventData,Constr)
% Syncs constraint props with related Editor props
set(Constr,eventSrc.Name,eventData.NewValue)
% Update constraint display (and notify observers)
update(Constr)

function LocalSetUnits(eventSrc,eventData,Constr)
% Syncs constraint props with related Editor props

whichUnits = eventSrc.Name;
NewValue = eventData.NewValue;
switch lower(whichUnits)
   case 'xunits'
      if isprop(Constr,'FrequencyUnits')
         Constr.setDisplayUnits(whichUnits,NewValue)
         Constr.TextEditor.setDisplayUnits(lower(whichUnits),NewValue)
      end
   case 'yunits'
      if isprop(Constr,'MagnitudeUnits')
         Constr.setDisplayUnits(whichUnits,NewValue{1});
         Constr.TextEditor.setDisplayUnits(lower(whichUnits),NewValue{1})
      end
      if isprop(Constr,'PhaseUnits')
         %Gain/phase margin requirement, x=phase, y=gain as on Nichols
         %plot
         Constr.setDisplayUnits('xunits',NewValue{2});
         Constr.TextEditor.setDisplayUnits('xunits',NewValue{2})
      end
end

% Update constraint display (and notify observers)
update(Constr)

