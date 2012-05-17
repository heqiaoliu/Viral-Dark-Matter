function addconstr(Editor,Constr)
%ADDCONSTR  Add Root-Locus constraint to editor.

%   Author(s): N. Hickey, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.14.4.1 $  $Date: 2009/05/23 07:53:19 $

FreqUnitFlag = ~isempty(Constr.findprop('FrequencyUnits'));
LoopData = Editor.LoopData;

% Generic init (includes generic interface editor/constraint)
initconstr(Editor,Constr)

% Initialize editor-specific properties
Constr.Ts = LoopData.Ts;

% Add related listeners 
L = handle.listener(LoopData, LoopData.findprop('Ts'), ...
			     'PropertyPostSet', {@LocalUpdateTS,Constr});
if FreqUnitFlag
  L = [L ; handle.listener(Editor, Editor.findprop('FrequencyUnits'), ...
	       'PropertyPostSet', {@LocalUpdateUnits,Constr})];
end
Constr.addlisteners(L);

% Activate (initializes graphics and targets constr. editor)
Constr.Activated = 1;

% Update limits
updateview(Editor);
end


%-------------------- Local functions ---------------------------------

function LocalUpdateUnits(~,eventData,Constr)
% Syncs constraint props with related Editor props
Constr.TextEditor.setDisplayUnits('xunits',eventData.NewValue)
Constr.setDisplayUnits('xUnits',eventData.NewValue)
% Update constraint display (and notify observers)
update(Constr)
end

function LocalUpdateTS(~,eventData,Constr)
% Syncs constraint props with related Editor props
Constr.Ts = eventData.NewValue;
% Update constraint display (and notify observers)
update(Constr)
end