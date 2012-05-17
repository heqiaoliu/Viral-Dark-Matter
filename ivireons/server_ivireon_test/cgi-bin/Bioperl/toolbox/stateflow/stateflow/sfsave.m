function sfsave(machine, saveAs,~)
%SFSAVE Saves a machine.
%        SFSAVE saves the current machine.
%        SFSAVE(  'MODEL_NAME' ) saves the specified model.
%        SFSAVE(  'MODEL_NAME', 'SAVEASNAME' ) saves the given model with a new name.
%        SFSAVE( 'MODEL_NAME' ) saves the specified model.
%        SFSAVE( 'DEFAULTS' ) saves the current environment defaults settings
%        in the defaults file.
%
%        See also SF, SFNEW, SFOPEN, SFCLOSE, SFPRINT, SFEXIT.

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.20.2.17 $  $Date: 2010/02/25 08:39:27 $

switch nargin,
    case 0,
        % No inputs.  Save current system, if there is one.
        currentSys = gcs;
        if (exist(currentSys)~=4) %#ok
            % No system open.  Abort.
            return;
        end
        modelH = get_param(currentSys,'handle');
        open_system(currentSys);
        saveAs = [];
        interactiveSave = false;
    case 1,
        % One input.  Save specified system.
        modelH = resolve_model_handle(machine);
        saveAs = [];
        interactiveSave = false;
    case 2,
        % Two inputs. Save specified system with specified name.
        modelH = resolve_model_handle(machine);
        interactiveSave = false;
    case 3,
        % Three inputs. "Interactive" mode.  If a non-empty "save as"
        % name is supplied, or if this is a new model, we'll show a
        % "Save As" dialog (regardless of the actual value of the third input!)
        modelH = resolve_model_handle(machine);
        interactiveSave = true;
    otherwise,
        help('sfsave');
        return;
end;

if isempty(modelH)
    % We saved the defaults file.  No need to do anything else.
    return;
end

% Check for valid Stateflow machine and license.
bd = get_bd_from_modelH(modelH);
machineFromModel = sf('Private', 'model2machine', bd);
if ~isempty(machineFromModel) && ~has_license(machineFromModel.id)
    return;
end

fileName  = char(get_param(modelH, 'Filename'));
modelName = char(get_param(modelH, 'Name'));

% Make sure we have a valid name with which to save.
if isempty(saveAs)
    if isempty(fileName)
        % No name supplied, and this is a new model.
        saveAs = modelName;
    else
        % No name supplied.  Use the existing file.
        saveAs = fileName;
        % There's no need to show a "Save As" dialog
        % here, even if we had been planning to.
        interactiveSave = false;
    end
end

% Append the ".mdl" extension if it isn't there already
if isempty(regexp(saveAs,'\.mdl$', 'once')),
    saveAs = [saveAs,'.mdl'];
end;

% If an interactive save was requested, prompt the user to choose a file name
if interactiveSave
    [f,p] = uiputfile(saveAs, modelName);
    if f==0
        return;
    end
    f = fullfile(p,f);
    force = true;
else
    f = saveAs;
    force = false;
end

% For non-interactive case, Simulink handles shadowing fine
% If the file already exists than this operation isn't introducing
% shadowing.
if(interactiveSave && ~exist(f,'file'))
    % For interactive case, we need to deal with shadowing NOW
    token = regexp(f, '(\w*).mdl$', 'tokens');
    if(length(token) == 1)
        extractedName = char(token{1});
        shadowLevel = exist(extractedName); %#ok

        % Shadowing an M-file, Mex, Mdl, Built-in, P-file respectively
        % G420807: special case the new simulink models using which()
        if(shadowLevel > 1 && shadowLevel < 7 && ~strcmpi(which(extractedName),'new Simulink model'))
            % Interactive: show error dialog and try save again
            
            msg = sprintf(xlate('Model name "%s" is shadowing another name in the MATLAB workspace or path. This can cause problems.\n\n'), extractedName);
            msg = sprintf(xlate('%sShadowed names:\n'), msg);
            shadowCells = which(extractedName, '-ALL');
            for i=1:length(shadowCells)
                msg = sprintf('%s%s\n', msg, shadowCells{i});
            end;
            msg = sprintf(xlate('%s\nClick on Save to continue or Cancel to choose another name.'), msg);

            % Show dialog: Save = Continue saving
            %              Cancel = Start save process over again
            button = questdlg(msg, xlate('Shadowed Model Name'), ...
                xlate('Save'), xlate('Cancel'), xlate('Save'));
            if strcmp(button, xlate('Cancel')) == 1
                sfsave(machine, saveAs, interactiveSave);
                return;
            end
        end
    end
end
% Save.
i_save(modelH, modelName, f, force);

%-------------------------------------------------------------------------------------
function modelH = resolve_model_handle(machine)
%
% Find the correspoding model for machine regardless of its type
%
modelH = [];
switch ml_type(machine)
    case 'string'
        if strcmp(machine, 'defaults')
            sfinit('save_defaults');
            return;
        else
            modelH = find_system('Name', machine);
        end;
    case 'sf_handle'
        modelH = sf('get',machine,'.simulinkModel');
    case 'sl_handle'
        modelH = machine;
    otherwise
        error('Stateflow:UnexpectedError','Bad arg(s) passed to sfsave()');
end

%-------------------------------------------------------------------------------------
function hasLicense = has_license(machineId)
hasLicense = 1;
if ~sf('License', 'basic', machineId),
    hasLicense = 0;
    sf_demo_disclaimer;
    return;
end;

%-------------------------------------------------------------------------------------
function bd = get_bd_from_modelH(modelH)
bd = get_param(modelH, 'Object');
if (iscell(bd))
    bd = bd{1};
end

%-------------------------------------------------------------------------------------
function i_save(modelH,mdlname,filename,force)

if  same_file(modelH,filename)
    % We're saving to the existing file.  Do not specifiy the file
    % name to save_system or it will treat this as a "Save As"
    % operation and skip the time-stamp check.
    filename = [];
end

try
    save_system(mdlname,filename,'OverwriteIfChangedOnDisk',force);
    err = [];
catch e
    err = e;
end

if ~isempty(err)
    if strcmp(err.identifier,'Simulink:Commands:SaveSysMdlFileChangedOnDisk')
        % This will only happen when "filename" is empty
        message = [ 'The file containing block diagram ''%s'' was changed on '...
            'disk after it was loaded by Stateflow.  You can overwrite '...
            'these changes, or save this diagram with a new name.'];
        message = sprintf(message,mdlname);
        saveas = 'Save with New Name';
        overwrite = 'Overwrite';
        answer = questdlg(message,'File Changed on Disk',...
            saveas, overwrite, 'Cancel',...
            'Cancel');
        if strcmp(answer,overwrite)
            % Attempt to overwrite the changes.
            try
                i_save(modelH,mdlname,[],true);
                err = [];
            catch e
                err = e;
            end
        elseif strcmp(answer,saveas)
            % Start interactive "Save As" operation
            sfsave(mdlname,mdlname,1);
            return;
        else
            % Cancel
            return;
        end
    end
end

if ~isempty(err)
    errordlg(err.message,'Error','modal');
    rethrow(err);
end

% Return true if the newFile name is the same as the existing file name.
function b = same_file(modelH, newFile)

if ispc
    % case-insensitive filename comparison on Windows
    compfn = @strcmpi;
else
    compfn = @strcmp;
end
oldFile = get_param(modelH,'FileName');
b = compfn(oldFile,newFile);
