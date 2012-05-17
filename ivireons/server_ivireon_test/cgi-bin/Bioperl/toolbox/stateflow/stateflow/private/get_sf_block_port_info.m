function portInfo = get_sf_block_port_info(sfunId,varargin)

% Copyright 2003-2010 The MathWorks, Inc.

blockPath = get_param(sfunId, 'parent');
blockH = get_param(blockPath,'handle');
chartId = block2chart(blockPath);
machineId = sf('get',chartId,'chart.machine');

mainMachineName = sf('get', machineId, 'machine.name');
machineName = mainMachineName;

if(sf('get',machineId,'machine.isLibrary'))
   % We may want to check for G453147
   mainModel = bdroot(blockPath);
   linkMachineId = machineId;
   mainMachineId = sf('find','all','machine.name',mainModel);
   mainMachineName = sf('get', mainMachineId, 'machine.name');
   sfLinks = sf('get',mainMachineId,'machine.sfLinks');

   if(isempty(find(sfLinks==blockH, 1)))
       % G453147: This means, blockH is a rogue SF/eML block magically
       % appeared in the middle of compilation. Let's make sure
       % the compiled info for the machine containing this chart 
       % is initialized properly
       linkMachines = get_link_machine_list(mainMachineId, 'sfun');
       libMachineName = sf('get',linkMachineId,'machine.name');
       if(~any(strcmp(linkMachines,libMachineName)))
           sf('Cg','reset_all_chart_compiled_info_in_machine',linkMachineId);
           sf('Cg', 'construct_type_container_context', linkMachineId);
           sf('set',linkMachineId,'machine.mainMachine',mainMachineId);
       end
   end
end

% Create build directory.
[~, dirArray] = get_sf_proj(pwd,mainMachineName,machineName,'','');
dirArray(strcmp(dirArray, '')) = [];
buildDirectoryPath = create_directory_path(dirArray{:});

try
    portInfo = sf('Cg','get_chart_compiled_info',chartId,blockH,...
                                        buildDirectoryPath,varargin{:});
catch %#ok<CTCH>
    portInfo = [];
end

