function autosave_status = enableAutoSave(this,autosave_status)
% ENABLEAUTOSAVE  Enable or disable autosave for Simulink.
%
 
% Author(s): John W. Glass 23-Jan-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.12.1 $ $Date: 2008/02/20 01:22:42 $

if ischar(autosave_status) && strcmp(autosave_status,'off')
    % Turn off the automatic saving of backups on "Model Update", since this
    % happens more than once during toolbox analysis.  If it was turned on
    % to start with, run it once now.
    autosave_status = get_param(0,'AutoSaveOptions');
    if autosave_status.SaveOnModelUpdate
        try
            % This can throw an error due to permissions.
            slInternal('autosave');
        catch Ex %#ok<NASGU>
            % Do nothing so that the error stack is maintained.
        end
    end

    % Turn off autosave
    set_param(0,'AutoSaveOptions',struct('SaveOnModelUpdate',false));
else
    % Restore the original value of the autosave options.
    set_param(0,'AutoSaveOptions',autosave_status);    
end