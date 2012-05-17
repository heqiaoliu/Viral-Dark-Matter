function addlisteners(Editor)
%ADDLISTENERS  Installs listeners for compensator editor.

%   Author(s): P. Gahinet
%   Revised: C. Buhr, R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.18.4.5 $ $Date: 2006/06/20 20:02:55 $

LoopData = Editor.LoopData;

% Listeners to @sisotool - Preferences.findprop
Listeners = handle.listener(Editor.Parent.Preferences, ...
         Editor.Parent.Preferences.findprop('FrequencyUnits'),...
        'PropertyPostSet', @LocalFreqUnitsChange);
   
% Listeners to @loopdata
%   1) FirstImport event: side effects of first import
%   2) ConfigChanged event: side effects of change of loopdata
%   3) LoopDataChanged event: side effects of change loopdata.C
Listeners = [Listeners ; ...
        handle.listener(LoopData,'FirstImport',@activate) ;...
        handle.listener(LoopData,'ConfigChanged',@LocalSync) ; ...
        handle.listener(LoopData,'LoopDataChanged',@LocalRefresh)];
    
set(Listeners,'CallbackTarget',Editor);
Editor.Listeners = Listeners;


%-------------------------Callback Functions------------------------

% ------------------------------------------------------------------------%
% Function: LocalFreqUnitsChange
% Purpose:  Call to refresh the editor for change in frequency units
% ------------------------------------------------------------------------%
function LocalFreqUnitsChange(Editor,event)
Editor.FrequencyUnits = Editor.Parent.Preferences.FrequencyUnits;
if isVisible(Editor)
    Editor.refreshpanel;
end

% ------------------------------------------------------------------------%
% Function: LocalSync
% Purpose:  Sync compensator list
% ------------------------------------------------------------------------%
function LocalSync(Editor,event)
% Resync gain list and compensator list with main database
Editor.importdata;
% refresh panel display
if isVisible(Editor)
    Editor.refreshpanel;
end

% ------------------------------------------------------------------------%
% Function: LocalRefresh
% Purpose:  Sync compensator data 
% ------------------------------------------------------------------------%
function LocalRefresh(Editor,event)
% Refresh pz editor and 
if isVisible(Editor)
    Scope = Editor.Loopdata.EventData.Scope;
    % if scope is a single compensator
    if strcmpi(Scope,'compensator')
        idxC = find(Editor.LoopData.EventData.Component,LoopData.C);
        % if the changed compensator is the same as the one currently
        % displayed, update the display; otherwise, ignore
        if isequal(Editor.idxC,idxC)
            Editor.refreshpanel;
        end
    % if scope is not a single compensator
    else
        Editor.refreshpanel;
    end
end

