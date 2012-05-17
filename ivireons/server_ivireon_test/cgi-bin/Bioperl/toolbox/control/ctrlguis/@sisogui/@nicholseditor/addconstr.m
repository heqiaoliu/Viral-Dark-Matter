function addconstr(Editor, Constr)
%ADDCONSTR  Add constraint to editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.4 $  $Date: 2009/05/23 07:53:15 $

% REVISIT: should call grapheditor::addconstr to perform generic init
Axes = Editor.Axes;

% Generic init (includes generic interface editor/constraint)
initconstr(Editor,Constr)

% Add related listeners 
% Add related listeners 
pu = [Axes.findprop('XUnits');Axes.findprop('YUnits')];
L = handle.listener(Axes,pu,'PropertyPostSet', {@LocalSetUnits,Constr});
Constr.addlisteners(L);

% Activate (initializes graphics and targets constr. editor)
Constr.Activated = 1;

% Update limits
updateview(Editor)

% --------------------------- Local Functions ----------------------------------%

function LocalSetUnits(eventSrc,eventData,Constr)

whichUnits = eventSrc.Name;
NewValue = eventData.NewValue;
Constr.setDisplayUnits(whichUnits,NewValue)
Constr.TextEditor.setDisplayUnits(lower(whichUnits),NewValue)

% Update constraint display (and notify observers)
update(Constr)


