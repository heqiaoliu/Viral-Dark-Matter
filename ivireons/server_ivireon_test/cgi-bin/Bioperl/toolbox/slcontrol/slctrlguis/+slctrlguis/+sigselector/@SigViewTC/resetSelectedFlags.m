function outsigs = resetSelectedFlags(insigs)
%

% RESETSELECTEDFLAGS - utility function to be used in setItems
% method of selected signal viewer tool component. It sets all "Selected"
% fields to false. This is necessary in DDG as it does not allow
% pre-selection of tree nodes.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:07 $
outsigs = insigs;
for ct = 1:numel(outsigs)
    % Check if regular or bus signal
    if strcmp(class(outsigs{ct}),'slctrlguis.sigselector.SignalItem')
        % Regular signal
        outsigs{ct}.Selected = false;        
    elseif strcmp(class(outsigs{ct}),'slctrlguis.sigselector.BusItem')
        % Bus signal        
        hier = outsigs{ct}.Hierarchy;
        for ctc = 1:numel(hier)
            hier(ctc).Selected = false;
            % Recursive update children
            hier(ctc).Children = LocalBus(hier(ctc).Children);
        end
        % Write updated hierarchy back
        outsigs{ct}.Hierarchy = hier;
    else
        % Error
        DAStudio.error('Slcontrol:sigselector:TCInvalidSignals');
    end           
end
function input = LocalBus(input)
for ct = 1:numel(input)
    input(ct).Selected = false;
    if ~isempty(input(ct).Children)
        input(ct).Children = LocalBus(input(ct).Children);
    end
end
        
