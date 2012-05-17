function rtwdemo_lct_makedemos(isPublishingArch)
%RTWDEMO_LCT_MAKEDEMOS make LCT demo S-Functions as part of mex phase

%   Copyright 2005-2009 The MathWorks, Inc.
%   $File: $
%   $Revision: 1.1.6.7 $
%   $Date: 2009/06/16 04:28:15 $

tempDir = '';
origDir = pwd;
try
    EXT=mexext;
    addpath(origDir);

    tempDir = tempname;
    mkdir(tempDir);
    cd(tempDir);

    % Make sure the building script runs in the base workspace
    % to avoid any resolution issue with Simulink Data objects
    evalin('base', 'rtwdemo_lct_builddemos;');

    disp ('### Copy and delete contents of tempdir')
    copyfile(['rtwdemo_sfun*.', EXT],origDir);
    copyfile('rtwmakecfg.m',origDir);
    % if it is the publishing platform, copy C, CPP and TLC files.
    if isPublishingArch
        copyfile('rtwdemo_sfun*.c',origDir);
        copyfile('rtwdemo_sfun*.cpp',origDir);        
        copyfile('rtwdemo_sfun*.tlc',origDir);
    end
    clear mex;
    delete([tempDir filesep '*']);        
    cd(origDir);
    rmdir(tempDir,'s')

    fid = fopen(['rtwdemo_lct.', EXT, '.ok'], 'w');
    fprintf(fid, ['LCT RTW demo build succeeded on ', EXT]);
    fclose(fid);
catch errMsg
    disp(errMsg.message);
    cd(origDir);
end
