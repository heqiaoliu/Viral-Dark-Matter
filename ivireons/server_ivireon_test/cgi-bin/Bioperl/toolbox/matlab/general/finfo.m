function [fileType, openAction, loadAction, description] = finfo(filename, ext)
% FINFO Identify file type against standard file handlers on path
%
%       [TYPE, OPENCMD, LOADCMD, DESCR] = finfo(FILENAME)
%
%       TYPE - contains type for FILENAME or 'unknown'.
%
%       OPENCMD - contains command to OPEN or EDIT the FILENAME or empty if
%                 no handler is found or FILENAME is not readable.
%
%       LOADCMD - contains command to LOAD data from FILENAME or empty if
%                 no handler is found or FILENAME is not readable.
%
%       DESCR   - contains description of FILENAME or error message if
%                 FILENAME is not readable.
%
% See OPEN, LOAD

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.19.4.15 $  $Date: 2009/01/23 21:37:10 $

if ~ischar(filename)
    error('MATLAB:finfo:InvalidType', 'FILENAME must be a string.');
end

if exist(filename,'file') == 0
    error('MATLAB:finfo:FileNotFound', 'File ''%s'' not found.', filename)
end

if nargin == 2 && ~ischar(ext)
    error('MATLAB:finfo:ExtensionMustBeAString', ...
        'File extension must be a string.');
end

% get file extension
if nargin == 1 || isempty(ext)
    [ext, description] = getExtension(filename);
else
    description = '';
end
ext = lower(ext);

% rip leading . from ext
if ~isempty(findstr(ext,'.'))
    ext = strtok(ext,'.');
end

% special case for .text files (textread will give false positive)
if strcmp(ext,'text')
    ext = '';
end

% check if open and load handlers exist
openAction = '';
loadAction = '';

% this setup will not allow users to override the default EXTread behavior
if ~isempty(ext)
    % known data formats go to uiimport and importdata
    if strncmp(ext, 'xls', 3)  ||  ...                               %Excel file extensions START with xls
        ~isempty(strmatch(ext, ...
                                 {'avi', ...                      % movie files
                                 'au' , 'snd', 'wav', ...         % audio files
                                 'csv', 'dat', 'dlm', 'tab', ...  % text files
                                  'wk1', ...                      % other worksheet files 
                                 'im'}, ...                       % image files (see getExtension below)
                         'exact'))
        openAction = 'uiimport';
        loadAction = 'importdata';
    else
        %special cases for DOC and PPT formats
        if strncmp(ext, 'doc', 3)
            openAction = 'opendoc';
        elseif strncmp(ext, 'ppt', 3)
            openAction = 'openppt';
        else
            % unknown data format, try to find handler on the path
            openAction = which(['open' ext]);
            loadAction = which([ext 'read']);
        end
    end
end

if ~isempty(openAction) || ~isempty(loadAction)
    fileType = ext;
else
    fileType = 'unknown';
end

% rip path stuff off commands
if ~isempty(openAction)
    [p,openAction] = fileparts(openAction);
end
if ~isempty(loadAction)
    [p,loadAction] = fileparts(loadAction);
end

% make nice description and validate file format
if nargout == 4 && isempty(description) % only fetch descr if necessary
    if (strncmp(ext, 'xls', 3))
        [status, description] = xlsfinfo(filename);
    elseif ~isempty(ext) && ~isempty(which([ext 'finfo']))
        [status, description] = feval([ext 'finfo'], filename);
    else
        % no finfo for this file, give back contents
        fid = fopen(filename);
        if fid > 0
            description = fread(fid,1024*1024,'*char')';
            fclose(fid);
        else
            description = 'File not found';
        end
        status = 'NotFound';
    end    
    if isempty(status)
            % the file finfo util sez this is a bogus file.
            % return valid file type but empty actions
            openAction = '';
            loadAction = '';
            % generate failure message, used by IMPORTDATA
            description = 'FileInterpretError'; 
    end
end

function [ext, description] = getExtension(filename)
%  try to get imfinfo (if file is image, use "im")

try
    s = imfinfo(filename);
catch exception %#ok
    [p,f,ext]=fileparts(filename);
    description = '';
    return;
end

ext = 'im';
if length(s) > 1
    description = sprintf('%s file with %d images.\n\nImporting first image only.\n\nUse IMREAD to read images 2 through %d.', upper(s(1).Format), length(s), length(s));
else
    description = sprintf('%d bit %s %s image%s', s.BitDepth, s.ColorType, ...
                          upper(s.Format));
end

