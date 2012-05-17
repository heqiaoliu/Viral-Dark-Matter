function val = pSetFileDependencies(job, val)
; %#ok Undocumented
%PSETTIMEOUT A short description of the function
%
%  VAL = PSETFILEDEPENDENCIES(JOB, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.8 $    $Date: 2009/02/06 14:16:50 $ 

if job.IsBeingConstructed
    % Whilst the job is being constructed we need to ensure that we concatenate
    % the FileDependencies rather than overwrite the existing ones. We can safely
    % store the values in the actual field until after construction.
    
    % The post function is stored with the value to set 
    postFcn = @iPostConstructionSetFileDependencies;
    % Have we already set this post construction function once?
    [index, oldVal, oldConfig] = job.pFindPostConstructionFcn(postFcn);
    % Which configuration is being used to set us
    newConfig = job.ConfigurationCurrentlyBeingSet;
    if isempty(index)
        job.pAddPostConstructionFcn(postFcn, val, newConfig);
    else
        newConfig = distcomp.configurableobject.pGetConfigNameFromConfigPair(oldConfig, newConfig);
        job.pModifyPostConstructionFcn(index, postFcn, [oldVal ; val], newConfig);
    end
    val = {};
    return
end

import com.mathworks.toolbox.distcomp.util.ByteBufferItem
proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    % Remove any empty entries from the cell array val as zip cannot deal
    % with them
    nonEmptyEntries = ~cellfun('isempty', val);
    val = val(nonEmptyEntries);
    if ~isempty(val)
        [filedata, val] = iZipFiles(val);
        % Need to ensure the cell array of strings is 1 x nStrings
        % otherwise the java layer gets upset
        val = reshape(val, 1, numel(val));
    else
        filedata = int8([]);
        % Need to make a 1 x 0 array of java.lang.String[][]
        val = javaArray('java.lang.String', 1, 1);
        val(1) = '';
    end
    try
        itemArray = dctJavaArray(ByteBufferItem(distcompMxArray2ByteBuffer(filedata)), ...
            'com.mathworks.toolbox.distcomp.util.LargeDataItem');
        proxyJob.setFileDepData(job.UUID, itemArray);
        proxyJob.setFileDepPathList(job.UUID, val);
    catch err
    	throw(distcomp.handleJavaException(job, err));
    end
end
% Do not hold anything locally
val = {};

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function iPostConstructionSetFileDependencies(job, val, config)
% Actually set the file dependencies
pSetPropertyAndConfiguration(job, 'FileDependencies', val, config);


% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function [zipbytes, files] = iZipFiles(files)
% PREADFILES - read files on disk into a uint8 array that can then be
% written to a temp directory using the writeFiles command.  The files and
% rootdir arguments behave the same way as they do in the ZIP command.

for i = 1:numel(files)
    fullPath = which(files{i});
    if ~isempty(fullPath)
        files{i} = fullPath;
    end
end

files = iAddAuthFilesIfDeployed( files );
% Make sure that no directories end in a file seperator as the behaviour of
% zip with absolute or relative paths is different under these circumstances 
files = regexprep(files, [filesep '$'], '');

zipname = [tempname '.zip'];
zip(zipname,files);
try
    fid = fopen(zipname,'r');
    zipbytes = fread(fid,'int8=>int8');
    fclose(fid);
catch err
    delete(zipname);
    rethrow(err);
end

warningState = warning('off', 'MATLAB:DELETE:Permission');
delete(zipname);       
warning(warningState);
% If the zipfile still exists then lets delete it later
if exist(zipname, 'file') && usejava('jvm')
    file = java.io.File(zipname);
    com.mathworks.toolbox.distcomp.util.FileDeleter.getInstance.deleteFileLater(file);
end

     
function files = iAddAuthFilesIfDeployed( files )
% IADDAUTHFILESIFDEPLOYED 
if isdeployed
    authFiles = cell( size( files ) );
    numAuthFiles = 0;
    for n = 1:numel( files )
        thisFile = files{n};
        % Does this file have a .auth file?
        % foo.mexext ---> foo_mexext.auth
        [location, name, ext] = fileparts( thisFile );
        possibleAuthFile = fullfile( location, [name, '_', ext(2:end), '.auth'] );
        % If the file exists, we'll add it to the FileDependencies as well.
        if exist( possibleAuthFile , 'file' )
            numAuthFiles = numAuthFiles + 1;
            authFiles{numAuthFiles} = possibleAuthFile;
        end
    end
    files = [files(:); authFiles(1:numAuthFiles)];
end

