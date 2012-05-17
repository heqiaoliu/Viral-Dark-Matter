function rtwdemo_autosar_makedemos()
%RTWDEMO_AUTOSAR_MAKEDEMOS make AUTOSAR demo models from arxml files as part of mex phase

%   Copyright 2005-2009 The MathWorks, Inc.
%   $File: $
%   $Revision: 1.1.10.1 $
%   $Date: 2009/08/23 19:10:25 $

origDir = pwd;
try
    addpath(origDir);

    tempDir = tempname;
    mkdir(tempDir);
    cd(tempDir);

    % Make sure the building script runs in the base workspace
    % to avoid any resolution issue with Simulink Data objects
    filename = fullfile(matlabroot, 'toolbox', 'rtw', 'rtwdemos', 'rtwdemo_generate_autosar_csinterface.arxml');
    obj = arxml.importer(filename);
    obj.createOperationAsConfigurableSubsystems('/rtwdemo_autosar/csinterface', 'CreateSimulinkObject', false);
    
    save_system('rtwdemo_autosar_csinterface');
    close_system('rtwdemo_autosar_csinterface');
    close_system('rtwdemo_autosar_server_operation');
    
    disp ('### Coping and delete contents of tempdir')
    copyfile('rtwdemo_autosar_csinterface.mdl',origDir,'f');
    delete([tempDir filesep '*']);        
    cd(origDir);
    rmdir(tempDir,'s')

    fid = fopen('rtwdemo_autosar.ok', 'w');
    fprintf(fid, 'AUTOSAR RTW demo build');
    fclose(fid);
catch errMsg
    disp(errMsg.message);
    cd(origDir);
end
