function addbodelisteners(Editor,sisodb)
%ADDBODELISTENERS  Installs listeners for Bode editors.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $ $Date: 2010/04/11 20:30:00 $

% Add generic editor listeners (@grapheditor) 
Editor.addlisteners;

% Add Bode-specific listeners
Axes = Editor.Axes;
p = [Editor.findprop('MagVisible') ; Editor.findprop('PhaseVisible')];
ps = [Axes.findprop('XScale') ; Axes.findprop('YScale')];
L1 = [handle.listener(Editor,p,'PropertyPostSet',@hgset_visible);...
        handle.listener(Axes,ps,'PropertyPostSet',@update)];
set(L1,'CallbackTarget',Editor)

% Listener to changes in data units or transforms 
% (side effect = DataChanged event issued by @axesgroup)
L2 = handle.listener(Axes,'DataChanged',{@LocalPostSetUnits Editor});

L3 = handle.listener(sisodb.Preferences, ...
    sisodb.Preferences.findprop('MultiModelFrequencySelectionData'),...
    'PropertyPostSet', {@LocalUpdateMultiModelFrequency Editor});


L4 = handle.listener(Editor, ...
    Editor.findprop('MultiModelFrequency'),...
    'PropertyPostSet', {@LocalUpdate Editor});

Editor.Listeners = [Editor.Listeners ; L1 ; L2; L3; L4];





%-------------------- Callback functions -------------------


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalPostSetUnits %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalPostSetUnits(hProp,eventdata,Editor)
% Called when changing units 
% Update labels
setlabels(Editor.Axes);

% Redraw plot 
update(Editor)


function LocalUpdateMultiModelFrequency(esrc,edata, Editor)  %#ok<INUSL>
Editor.MultiModelFrequency = edata.AffectedObject.getMultiModelFrequency;

function LocalUpdate(esrc,edata, Editor) %#ok<INUSL>
Editor.update;
