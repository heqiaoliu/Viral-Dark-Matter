function fullPath = settingsFilename(rawStr, conflictMode, fileExt, ...
        modelH, showUI, makeDir, opts, dialogTitle)
%   Copyright 2006-2010 The MathWorks, Inc.

    if nargin<5
        showUI = false;
    end

    if nargin<6
        makeDir = false;
    end

    if nargin<7
        opts = [];
    end
    
    if nargin<8
        dialogTitle = 'Simulink Design Verifier';
    end   

    if ischar(modelH)
        modelName = modelH;
        if isempty(opts)
            settings = sldvdefaultoptions;
        else
            settings = opts;
        end
    else
        modelName = get_param(modelH,'Name');
        if exist('sldvprivate', 'file')==2 && isempty(opts)
            testcomp = Sldv.Token.get.getTestComponent;
            settings = testcomp.activeSettings;
        else
            settings = opts;
        end
    end
    currDir = pwd;

    % Expand with the model name and correct any separator problems
    rawStr = strrep(rawStr, '$ModelName$', modelName);
    rawStr = strrep(rawStr, '\', filesep);
    rawStr = strrep(rawStr, '/', filesep);

    % Determine the correct path
    [rawPath, rawName, rawExt] = fileparts(rawStr);

    % Determine the needed extension
    if isempty(rawExt)
        actExt = fileExt;
    else
        actExt = rawExt;
        if ~strcmp(rawExt,fileExt)
            if strcmp(fileExt,'.mdl')
                % Models must use the extension .mdl or they can not
                % be read by Simulink
                actExt = '.mdl';
            end
        end
    end

    % Determine the path based on the current settings
    if ~isempty(rawPath) && is_abs_path(rawPath)
        actPath = rawPath;
    else
        % Expand with the model name and correct any separator problems
        outDir = strrep(settings.OutputDir, '$ModelName$', modelName);
        outDir = strrep(outDir, '\', filesep);
        outDir = strrep(outDir, '/', filesep);

        if is_abs_path(outDir)
            actPath = fullfile(outDir,rawPath);
        else
            actPath = fullfile(currDir,outDir,rawPath);
        end
    end

    actPath = rmiut.simplifypath(actPath,filesep);

    % Create the output directory if needed
    if ~exist(actPath,'dir') && makeDir
        try
            if ispc
                if strcmp(actPath(1:2),'\\')
                    mkdir(actPath);
                else
                    mkdir(actPath(1:3),actPath(4:end));
                end
            else
                mkdir(actPath(1),actPath(2:end));
            end
        catch Mex %#ok<NASGU>
            errStr = ['Fail to create directory ',actPath,'. Permission denied.'];
            if showUI
                sldvshareprivate('local_error_dlg',errStr,dialogTitle);
            else
                error('SLDV:Settings:OutDirCantCreate', '%s', errStr);
            end
        end
    end
    if exist(actPath, 'dir')
        [~, attr] = fileattrib(actPath);
        if (~attr.UserWrite)
            errStr = [actPath ' directory is read only' ];
            if showUI
                sldvshareprivate('local_error_dlg',errStr,dialogTitle);
            else
                error('SLDV:Settings:OutDirRO', '%s', errStr);
            end
        end
    end

    fileName = [rawName actExt];
    fullPath = fullfile(actPath, fileName);


    % See if the name should be incremented to resolve conflicts
    if exist(fullPath,'file')
        switch(conflictMode)
            case 'on',
                fullPath = unique_file_name_using_numbers(actPath,fileName,actExt);
            case 'off'
                delete(fullPath);
        end

    end
    fullPath = rmiut.simplifypath(fullPath, filesep);
end
    

function fullPath = unique_file_name_using_numbers(path,name,ext)

    baseName = strtok(name,'.');
    
    if (any(baseName(end)=='0123456789'))
        baseName = [baseName '_'];
    end
	charIdx = length(baseName)+1;
	existFiles = dir(fullfile(path,[baseName '*' ext]));

	number = 1;

	if ~isempty(existFiles)
		for fileIdx = 1:length(existFiles)
           [cPath cName cExt] = fileparts(existFiles(fileIdx).name); %#ok
			suffix = cName(charIdx:end);
			numValue = str2num(suffix); %#ok
			if ~isempty(numValue) && numValue>=number
				number = numValue+1;
			end
		end
	end    
    
    fileName = [baseName num2str(number) ext];
    fullPath = fullfile(path,fileName);
end
    
function out = is_abs_path(str)
    % Determine if this an absolute path
    if ispc
        out = ~isempty(str) && any(str==':');    
    else
        out = ~isempty(str) && str(1)=='/';            
    end
end
% LocalWords:  RO SLDV dlg simplifypath testcomponent
