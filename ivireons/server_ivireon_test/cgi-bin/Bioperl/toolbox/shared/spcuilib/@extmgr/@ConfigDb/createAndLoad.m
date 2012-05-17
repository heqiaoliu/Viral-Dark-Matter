function [hConfigDb,fileLoaded] = createAndLoad(cfgFile,hMessageLog)
%CREATEANDLOAD Load configuration file and return new database object.
%  CREATEANDLOAD(cfgFile) loads serialization of configuration database
%  from file cfgFile.  If no extension is specified in cfgFile, '.ext'
%  is automatically appended.  A success message is added to the message
%  log.  File must contain a variable named hConfigDb.
%
%  If cfgFile is not found, an empty database is returned, and a message
%  is added to the message log.
%
%  If cfgFile is empty, file load is not attempted, and no warning
%  messages will occur.
%
%  This is a STATIC METHOD and does NOT take the object as an argument.
%  It must be called using the full package.class name.  For example,
%     hConfigDb = extmgr.ConfigDb.createAndLoad('cfgFile.scf');

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/09/09 21:28:56 $

% Prepare for failure with empty database
hConfigDb = extmgr.ConfigDb;
fileLoaded = false;

% Allow empty or no string to return early without failure message
% But, fileLoaded will still be false.
if isempty(cfgFile)
    return;
end

if nargin < 2
    hMessageLog = [];
end

% Add .ext to filename if an extension is not specified
[~,~,e] = fileparts(cfgFile);
if isempty(e)
    cfgFile=[cfgFile '.cfg'];
end

% Verify file exists
if exist(cfgFile,'file')
    % Try to load configuration file
    try
        
        s = load(cfgFile,'-mat');
        
        if isfield(s,'hConfigDb')
            % Success
            fileLoaded = true;
            hConfigDb = s.hConfigDb;
            if ~isempty(hMessageLog)
                summary = 'Configuration file loaded.';
                details = sprintf(['%s<br>', ...
                    '<ul>' ...
                    '<li>File Name: %s' ...
                    '</ul><br>'], ...
                    summary, cfgFile);
                hMessageLog.add('Info','Configuration',summary,details);
            end
        else
            % Failed to find required variable
            if ~isempty(hMessageLog)
                summary = 'Invalid configuration file contents.';
                details = sprintf(['%s<br>' ...
                    '<ul>' ...
                    '<li>File Name: %s' ...
                    '</ul>' ...
                    'Failed to find variable "hConfigDb" in file.<br>'], ...
                    summary, cfgFile);
                hMessageLog.add('Fail','Configuration',summary,details);
            end
        end
    catch e
        % Failure during file load - wrong file type?
        if ~isempty(hMessageLog)
            summary = 'Invalid configuration file.';
            details = sprintf(['%s<br>' ...
                '<ul>' ...
                '<li>File Name: %s' ...
                '</ul>' ...
                '<b>Error message:</b><br>' ...
                '%s<br>'], ...
                summary, cfgFile, uiservices.cleanErrorMessage(e));
            hMessageLog.add('Fail','Configuration',summary,details);
        end
    end
else
    % Specified config file does not exist
    if ~isempty(hMessageLog)
        summary = 'Configuration file not found.';
        details = sprintf(['%s<br>', ...
            '<ul>' ...
            '<li>File Name: %s' ...
            '</ul>' ...
            'No extensions will be enabled.<br>', ...
            'Default values will be used for all extension properties.<br>'], ...
            summary,cfgFile);
        hMessageLog.add('Fail','Configuration',summary,details);
    end
end

% [EOF]
