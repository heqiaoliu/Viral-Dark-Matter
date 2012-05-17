function makeInfo = rtwmakecfg()
%RTWMAKECFG adds include and source directories to RTW make files.
%   makeInfo=RTWMAKECFG returns a structured array containing build info.
%   Please refer to the rtwmakecfg API section in the Real-Time Workshop
%   Documentation for details on the format of this structure.
%

%   Copyright 2009 The MathWorks, Inc.

makeInfo = lct_rtwmakecfg();

if isempty(makeInfo.includePath) || isempty(makeInfo.includePath{1})
    makeInfo.includePath{1} = fullfile(matlabroot, 'toolbox', 'simulink', ...
        'simdemos', 'simfeatures','include');
    makeInfo.includePath{2} = fullfile(matlabroot, 'toolbox', 'simulink', ...
        'simdemos', 'simfeatures','tlc_c');
end

if isempty(makeInfo.sourcePath) || isempty(makeInfo.sourcePath{1})
    makeInfo.sourcePath{1} = fullfile(matlabroot, 'toolbox', 'simulink', ...
        'simdemos', 'simfeatures','src');
end
