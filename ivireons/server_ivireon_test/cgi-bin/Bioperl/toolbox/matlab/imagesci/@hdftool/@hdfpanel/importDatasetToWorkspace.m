function importDatasetToWorkspace(this)
%IMPORTDATASETTOWORKSPACE Import data to the MATLAB workspace.
%   This function relies heavily on the buildImportCommand() method
%   of the active panel.
%
%   Function arguments
%   ------------------
%   THIS: the hdfpanel object instance.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/07/28 14:29:12 $

    set(this.filetree.fileFrame.figureHandle, 'Pointer', 'watch');
    % Turn off warnings so that they won't be displayed in the command window.
    warnState = warning('off');
    try
        doImport(this);
    catch myException
	msg = massage_error_message(myException);
        errordlg(msg, 'Error executing HDFREAD');
    end
    warning(warnState);
    set(this.filetree.fileFrame.figureHandle, 'Pointer', 'arrow');

end


function doImport(this)
% A procedure to import data.
    lastwarn('');
    drawnow;

    prefs = this.filetree.fileFrame.prefs;
    
    % build the import command
    cmd = this.buildImportCommand(true);
    
    % return if cmd is empty
    if isempty(cmd)
        return
    end
    
    % check if we need to import the metadata
    mHandle = get(this.filetree,'hImportMetadata');
    isImportMetadata = get(mHandle,'Value');
    
    % get the data variable name
    varname = get(this.filetree,'wsvarname');
    
    % get all the workspace variable names
    wsVars = evalin('base','whos');
    wsVarnames = {wsVars.name};
    
    % check if data variable exists in the workspace
    varExists = any(strcmp(varname,wsVarnames),2);
    
    importedVariable = false;
    % if variable does not exits in the workspace
    % or the user clicks "Yes" in the overwrite prompt
    if isempty(varExists) || ~varExists || overWriteVar(varname)
        evalin('base',cmd);
        importedVariable = true;
    end
    
    readWarn = lastwarn;
    if ~isempty(readWarn)
        warndlg(readWarn, 'Warning!');
        return
    end
    
    % initiate the str to empty
    metaStr = '';
    
    % if user wants to import meta data
    if isImportMetadata
        % the info variable name
        infoVarname = sprintf('%s_info',varname);
        infoExists = any(strcmp(infoVarname,wsVarnames),2);
        
        if isempty(infoExists) || ~infoExists || overWriteVar(infoVarname)
            metadata = this.currentNode.nodeinfostruct;
            % Remove NodeType and NodePath, which are not part of the
            % hdfinfo structure.
            if isfield(metadata, 'NodeType')
                metadata = rmfield(metadata, 'NodeType');
            end
            if isfield(metadata, 'NodePath')
                metadata = rmfield(metadata, 'NodePath');
            end
            if isfield(metadata, 'vertical')
                metadata = rmfield(metadata, 'vertical');
            end
            metaStr = sprintf('and the metadata,\n%s\n',infoVarname);
            assignin('base', infoVarname, metadata);
            importedVariable = true;
        end
    end
    
    if importedVariable && prefs.confirmImport
        dlgStr = ['You have imported the data\n',...
                  '%s\n',...
                  '%s',...
                  'into the MATLAB Workspace.'];
        dlgStr = sprintf(dlgStr,varname,metaStr);
        helpdlg(dlgStr,'Import Message');
    end
    
    %=========================================================================
    function chk = overWriteVar(var)
        % Determine if we should overwrite a variable in the workspace.
        set(this.filetree.fileFrame.figureHandle, 'Pointer', 'arrow');
        chk = false;
        warnStr =['Variable %s already exists. Overwrite?'];
        warnStr = sprintf(warnStr,var);

        response = questdlg(warnStr,'Warning!','Yes','No','Yes');
        switch response
            case 'Yes'
                chk = true;
            case 'No'
                chk = false;
            otherwise
                chk = false;
        end
        set(this.filetree.fileFrame.figureHandle, 'Pointer', 'watch');
        drawnow;
    end
end    
    
%==============================================================================
function msg = massage_error_message(err)
% MASSAGE_ERROR_MESSAGE
%     MSG = MASSAGE_ERROR_MESSAGE(ERR) take an error structure (such as 
%     that produces by LASTERROR) and removes the location where the error
%     occurred.  This is done by searching for the final linefeed character
%     (ASCII code 10) and returning everything after that.  If there is no
%     newline character or if the last character is a newline, then the logic
%     fails and we return the entire error message.
%     
%
%     The reason for this is that otherwise, errordlg will show a message that
%     reads something like
%     
%         Error using ==> imagesci/private/hdfgridread>get_grid_regionid_from_time_period at 240
%         Generic failure of deftimeperiod
%
%     What really want is just
%
%         Generic failure of deftimeperiod
%


linefeed = findstr(err.message,char(10));
carriage_return = findstr(err.message,char(13));
delimiters = union(linefeed,carriage_return);

if isempty(delimiters)

	%
	% There were no carriage returns or line feeds.  Logic fails.
	msg = err.message;

elseif ( delimiters(end) == length(err.message) )

	%
	% Last character was a delimiter.  We can't go past it.
	msg = err.message;

else
	msg = err.message(delimiters(end)+1:end);
end

msg = sprintf ('Dataset import command failed.  %s', msg);

end
