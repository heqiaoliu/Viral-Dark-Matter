function makeInfo=rtwmakecfg()
% rtwmakecfg - Demonstrates the use rtwmakecfg API on how to 
% add source directors, run-time library names to the generated
% makefile when using S-Functions.

%   Copyright 1994-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $

% Define the 'library'
makeInfo.Name = 'buildinfo_rtwmakecfg_build_info';

% Setup additional source files with its source path
makeInfo.sourcePath = {fullfile(matlabroot,'toolbox','rtw','rtwdemos',...
    'buildinfo_demo')};
makeInfo.sources = {'buildinfo_rtwmakecfg_src.c'};

% These are the source files used to build the model rtwdemo_buildInfo
buildlib_modules = {'sfun_rtwmakecfg_module_01', ...
                    'sfun_rtwmakecfg_module_02', ...
                    'sfun_rtwmakecfg_module_03'};


% Ensure that library files are compiled during the build process
makeInfo.precompile = 0;
makeInfo.library(1).Name     = 'buildinfo_rtwmakecfg_lib';
makeInfo.library(1).Location = fullfile(matlabroot,'toolbox','rtw',...
    'rtwdemos','buildinfo_demo');
makeInfo.library(1).Modules  = buildlib_modules;

