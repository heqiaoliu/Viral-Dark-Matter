function [buildInfo mat_file_contents] = ...
    targets_load_buildinfo(buildInfoPath)
%TARGETS_LOAD_BUILDINFO Load contents of a buildInfo.mat file
%
%   [BUILD_INFO] = TARGETS_LOAD_BUILDINFO(BUILD_INFO_PATH) loads a MAT-file
%   containing a an RTW.BuildInfo and returns this object as
%   BUILD_INFO. BUILD_INFO_PATH must specify the full path to the MAT-file.
%
%   [BUILD_INFO, MAT_FILE_CONTENTS] = TARGETS_LOAD_BUILDINFO(BUILD_INFO_PATH)
%   additionally returns MAT_FILE_CONTENTS, the full contents of the MAT-file in
%   the form of a struct with fields for each variable in the file. In addition
%   to a buildInfo field, this struct may include a field for templateMakefile
%   specifying the full path to the Template Makefile associated with the build.
%

% Copyright 2006-2009 The MathWorks, Inc.

% check num args
error(nargchk(1, 1, nargin, 'struct'));

% check buildInfoPath is not empty
if isempty(buildInfoPath)
  rtw.pil.ProductInfo.error('pil', 'BuildInfoInvalid');
end

% basic existence check
if ~exist(buildInfoPath, 'file')
  rtw.pil.ProductInfo.error('pil', 'InvalidFile', buildInfoPath);
end
 
% check the filename is a .mat file
[~, file, ext] = fileparts(buildInfoPath);
filename = [file ext];
expectedext = '.mat';
if ~strcmpi(ext, expectedext)
  rtw.pil.ProductInfo.error('pil', 'InvalidFileType', filename, expectedext);
end
% load the BuildInfo object
mat_file_contents = load(buildInfoPath);
RTWBuildInfoClass = 'RTW.BuildInfo';
% check for a "buildInfo" field
if ~isfield(mat_file_contents, 'buildInfo')
    rtw.pil.ProductInfo.error('pil', 'BuildInfoFieldNotFound', buildInfoPath);
end
% get the buildInfo field
buildInfo = mat_file_contents.buildInfo;
% check the class is correct
if ~strcmp(class(buildInfo), RTWBuildInfoClass)
  rtw.pil.ProductInfo.error('pil', 'BuildInfoUnexpectedVariable', buildInfoPath, class(buildInfo), RTWBuildInfoClass);
end
