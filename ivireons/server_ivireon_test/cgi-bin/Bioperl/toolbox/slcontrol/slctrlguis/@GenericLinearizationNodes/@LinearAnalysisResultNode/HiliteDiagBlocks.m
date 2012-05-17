function HiliteDiagBlocks(this,type)
% HiliteDiagBlocks - Highlights the blocks that were linearized using
% and have a diagnostic message.

% Copyright 2007 The MathWorks, Inc.

% Turn off the all highlighting
set_param(this.Model,'HiliteAncestors','off');

% Filter blocks not in the path if the user chooses
DiagnosticMessages = this.DiagnosticMessages;
if iscell(DiagnosticMessages) && (this.Dialog.getSelectedModelIndex > 0)
    DiagnosticMessages = DiagnosticMessages{this.Dialog.getSelectedModelIndex};
else iscell(DiagnosticMessages)
    DiagnosticMessages = DiagnosticMessages{1};
end
    
if ~this.Handles.DiagnosticsPanel.isFullModelSelected
    DiagnosticMessages = DiagnosticMessages([DiagnosticMessages.InPath]==1);
end

% Get the diagnostic message types
types = {DiagnosticMessages.Type};
if strcmp(type,'warning') 
    % Display blocks with warnings or who linearize exactly with a message.
    messages = {DiagnosticMessages.Message};
    pertblks = xor(strcmp(types,'warning'),strcmp(types,'exact'))&~strcmp(messages,'');
else
    pertblks = strcmp(types,type);
end

% Highlight the blocks in the linearization that are linearized using numerical perturbation.  
if any(pertblks)
    blks = DiagnosticMessages(pertblks);
    for ct = 1:numel(blks)
        try
            set_param(blks(ct).BlockName,'HiliteAncestors','find');
        catch
            str = sprintf('The block %s is no longer in the model',blks(ct).BlockName);
            errordlg(str,'Simulink Control Design')
        end
    end
end