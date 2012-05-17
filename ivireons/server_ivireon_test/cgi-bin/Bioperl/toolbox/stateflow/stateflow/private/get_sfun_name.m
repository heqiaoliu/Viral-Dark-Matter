function sfunName = get_sfun_name(mainMachineId,targetName)
machineName = sf('get',mainMachineId,'machine.name');
sfunName = [machineName '_' targetName];
