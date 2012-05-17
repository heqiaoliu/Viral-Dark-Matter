function [name, values] = loadconfigfile( filename )
; %#ok Undocumented
%Loads and verifies a configuration from the specified file.
%

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:58:19 $ 

% The format of the data stored in the .mat file is defined in exportToFile.m
try
    completeState = load(filename, '-mat');
catch err
    error('distcomp:configuration:invalidFile', ...
          'Failed to import configuration from the file %s due to the following error:\n%s\n', ...
          filename, err.message);
end

% Note that we're not actually making any use of the version string anymore, but
% the absence of this field still constitutes an invalid configuration .mat file.
try
    version = completeState.Version; %#ok<NASGU>
catch err
    error('distcomp:configuration:invalidFile', ...
          ['Could not find any version information when importing configuration ', ...
           'from the file: %s'], ...
          filename);
end

try
    name = completeState.Name;
catch err
    error('distcomp:configuration:invalidFile', ...
          'Could not find the configuration name when importing from the file: %s', ...
          filename);
end

try
    values = completeState.Values;
catch err
    error('distcomp:configuration:invalidFile', ...
          'Could not find the configuration values when importing from the file: %s', ...
          filename);
end

% VersionNumber was introduced into the .mat file in R2009b, so it may not exist as
% a field yet.
if isfield(completeState, 'VersionNumber')
    versionNumber = completeState.VersionNumber;
else
    % The configuration struct had no version associated with it - i.e. it was created
    % before R2009b (which was when the version was included).  We assume that the 
    % configuration came from R2009a (version 9).
    versionNumber = 9;
end

currVersionNumber = com.mathworks.toolbox.distcomp.util.Version.VERSION_NUM;
try
    if versionNumber ~= currVersionNumber
        values = distcomp.configuration.upgradeConfigValuesStructToCurrentVersion(values, versionNumber);
    end
catch err
    ex = MException('distcomp:configuration:invalidFile', ...
          'Failed to import configuration from the file %s due to an upgrade error.');
    ex = ex.addCause(err);
    throw(ex);
end