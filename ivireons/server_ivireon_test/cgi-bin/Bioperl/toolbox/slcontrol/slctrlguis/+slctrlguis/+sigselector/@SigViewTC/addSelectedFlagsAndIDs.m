function outsigs = addSelectedFlagsAndIDs(insigs)
%

% ADDSELECTEDFLAGSANDIDS - utility function to be used in setItems
% method of selected signal viewer tool component. It inserts "Selected"
% fields with false default value and an integer ID to be used in the tree
% widget.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:02 $
outsigs = insigs;
id = 1;
for ct = 1:numel(outsigs)
    % Check if regular or bus signal
    if strcmp(class(outsigs{ct}),'slctrlguis.sigselector.SignalItem')
        % Regular signal
        outsigs{ct}.TreeID = id; id = id + 1;        
    elseif strcmp(class(outsigs{ct}),'slctrlguis.sigselector.BusItem')
        % Bus signal               
        % Add selected and TreeID fields to the hierarchy
        hier = outsigs{ct}.Hierarchy;
        for ctc = 1:numel(hier)       
            uphier(ctc).SignalName = hier(ctc).SignalName;
            uphier(ctc).BusObject = hier(ctc).BusObject;
            % Selected field
            if ~isfield(hier(ctc),'Selected')
                uphier(ctc).Selected = false;
            else
                uphier(ctc).Selected = hier(ctc).Selected;
            end
            % Tree ID field
            uphier(ctc).TreeID = id;id = id + 1;
            % Recursive update children
            [uphier(ctc).Children,id] = LocalBus(hier(ctc).Children,id);
        end                
        % Write updated hierarchy back
        outsigs{ct}.Hierarchy = uphier;
    else
        % Error
        DAStudio.error('Slcontrol:sigselector:TCInvalidSignals');
    end           
end
function [out,id] = LocalBus(input,id)
out = [];
for ct = 1:numel(input)
    out(ct).SignalName = input(ct).SignalName;
    out(ct).BusObject = input(ct).BusObject;
    if isfield(input(ct),'Selected')
        out(ct).Selected = input(ct).Selected;
    else
        out(ct).Selected = false;
    end
    out(ct).TreeID = id; id = id + 1;
    if isempty(input(ct).Children)
        out(ct).Children = [];
    else
        [out(ct).Children,id] = LocalBus(input(ct).Children,id);
    end
end
        
