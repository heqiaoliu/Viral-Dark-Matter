function copy_target_props_in_configset(targetName, srcMachineId, dstMachineId)

%   Copyright 2008-2009 The MathWorks, Inc.

srcCS = getActiveConfigSet(sf('get', srcMachineId, 'machine.name'));
dstCS = getActiveConfigSet(sf('get', dstMachineId, 'machine.name'));

switch(targetName)
  case 'sfun'
    copy_one_field(srcCS, dstCS, 'SimUseLocalCustomCode');
    copy_one_field(srcCS, dstCS, 'SimCustomHeaderCode');
    copy_one_field(srcCS, dstCS, 'SimCustomSourceCode');
    copy_one_field(srcCS, dstCS, 'SimCustomInitializer');
    copy_one_field(srcCS, dstCS, 'SimCustomTerminator');
    copy_one_field(srcCS, dstCS, 'SimReservedNameArray');
    copy_one_field(srcCS, dstCS, 'SimUserIncludeDirs');
    copy_one_field(srcCS, dstCS, 'SimUserLibraries');
    copy_one_field(srcCS, dstCS, 'SimUserSources');
    copy_one_field(srcCS, dstCS, 'SFSimEnableDebug');
    copy_one_field(srcCS, dstCS, 'SFSimOverflowDetection');
    copy_one_field(srcCS, dstCS, 'SFSimEcho');
    copy_one_field(srcCS, dstCS, 'SimBlas');
    copy_one_field(srcCS, dstCS, 'SimIntegrity');
    copy_one_field(srcCS, dstCS, 'SimExtrinsic');
    copy_one_field(srcCS, dstCS, 'SimCtrlC');

  case 'rtw'
    copy_one_field(srcCS, dstCS, 'RTWUseSimCustomCode');
    if ~strcmp(get_param(dstCS, 'RTWUseSimCustomCode'), 'on')
        copy_one_field(srcCS, dstCS, 'RTWUseLocalCustomCode');
        copy_one_field(srcCS, dstCS, 'CustomHeaderCode');
        copy_one_field(srcCS, dstCS, 'CustomSourceCode');
        copy_one_field(srcCS, dstCS, 'CustomInitializer');
        copy_one_field(srcCS, dstCS, 'CustomTerminator');    
        copy_one_field(srcCS, dstCS, 'CustomInclude');
        copy_one_field(srcCS, dstCS, 'CustomLibrary');
        copy_one_field(srcCS, dstCS, 'CustomSource');
    end

    copy_one_field(srcCS, dstCS, 'UseSimReservedNames');
    if ~strcmp(get_param(dstCS, 'UseSimReservedNames'), 'on')
        copy_one_field(srcCS, dstCS, 'ReservedNameArray');
    end

    copy_one_field(srcCS, dstCS, 'GenerateComments');
    copy_one_field(srcCS, dstCS, 'DataBitsets');
    copy_one_field(srcCS, dstCS, 'StateBitsets');

  otherwise
    error('Stateflow:UnexpectedError','Unexpected target name.');
end

copy_one_field(srcCS, dstCS, 'Description');

function copy_one_field(srcCS, dstCS, fieldName)
  dstCS.set_param(fieldName, srcCS.get_param(fieldName));
