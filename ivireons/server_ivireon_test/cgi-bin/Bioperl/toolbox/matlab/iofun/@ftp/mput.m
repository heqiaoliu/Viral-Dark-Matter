function location = mput(h,str)
%MPUT Upload to an FTP site.
%    MPUT(FTP,FILENAME) uploads a file.
%
%    MPUT(FTP,DIRECTORY) uploads a directory and its contents.
%
%    MPUT(FTP,WILDCARD) uploads a set of files or directories specified
%    by a wildcard.
%
%    All of these calling forms return a cell array listing the full path to the
%    uploaded files on the server.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2008 The MathWorks, Inc.
% $Revision: 1.1.4.3 $  $Date: 2008/12/08 21:54:48 $

% Make sure we're still connected.
connect(h)

% Figure out where the files live.
[localDir,file,ext] = fileparts(str);
filename = [file ext];
if isempty(localDir)
    localDir = pwd;
end
remoteDir = char(h.jobject.printWorkingDirectory);

% Set ascii/binary
switch char(h.type.toString)
    case 'binary'
        h.jobject.setFileType(h.jobject.BINARY_FILE_TYPE);
    otherwise
        h.jobject.setFileType(h.jobject.ASCII_FILE_TYPE);
end

if strfind(filename,'*')
    % Upload any files and directories that match the wildcard.
    d=dir(fullfile(localDir,filename));
    listing = {d.name};
else
    listing = {filename};
end

location = {};
iListing = 0;
while (iListing < length(listing))
    iListing = iListing+1;
    name = listing{iListing};
    localName = strrep(fullfile(localDir,name),'/',filesep);
    if isdir(localName)
        mkdir(h,name);
        d = dir(localName);
        for i = 1:length(d)
            next = d(i).name;
            if isequal(next,'.') || isequal(next,'..')
                % skip
            else
                listing{end+1} = [name '/' next];
            end
        end
    else
        % Check for the file.
        fileObject = java.io.File(localName);
        if ~fileObject.exists
            error('MATLAB:ftp:NotFound','File "%s" not found.',localName)
        end

        % Upload this file.
        fis = java.io.FileInputStream(fileObject);
        status = h.jobject.storeFile(name,fis);
        fis.close;

        % Error if the upload failed.
        if (status == 0)
            code = h.jobject.getReplyCode;
            switch code
                case 550
                    error('MATLAB:ftp:UploadFailed','Could not upload "%s".',name);
                case 553
                    error('MATLAB:ftp:BadFilename','Illegal file name "%s".',name);
                otherwise
                    error('MATLAB:ftp:FtpError','FTP Error "%.0f".',code);
            end
        end

        % Build the list of files uploaded.
        location{end+1,1} = [remoteDir '/' name];
    end
end
