function [copySuccess, errMsg] = rtw_copy_file(src,dst)
% RTW_COPY_FILE: Copy source file to destination file. 

% Copyright 2003-2008 The MathWorks, Inc.

errMsg = '';
if (exist(src,'file') ~= 2)
    copySuccess = 0;
    errMsg = DAStudio.message('RTW:utility:fileDoesNotExist',src);
    return;
end

if ispc
    [s r] = dos(['copy "', src, '" "', dst, '"']);
else
    [s r] = unix(['\cp "', src, '" "', dst, '"']);
end

copySuccess = exist(dst,'file');

% the dest could be a directory, in that case try to get the filename and verify
% that it exists in the dst dir.
if (copySuccess == 7)
    [path, filename, ext] = fileparts(src);
    copySuccess = exist(fullfile(dst,[filename ext]),'file');
end

if(copySuccess ~= 2) 
    errMsg = DAStudio.message('RTW:utility:fileCopyFailed',src,dst, r);
end
