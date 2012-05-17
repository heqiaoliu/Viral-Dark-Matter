function output = notify_legacyws(machineId, varname)

model  = sf('get', machineId, 'machine.name');
hdl    = get_param(model,'Object');
output = hdl.RegisterAccesstoLegacySymbol(varname);

