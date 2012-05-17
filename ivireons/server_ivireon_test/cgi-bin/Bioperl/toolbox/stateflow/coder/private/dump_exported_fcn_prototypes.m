function dump_exported_fcn_prototypes(file)
	global gMachineInfo

	if(isempty(gMachineInfo.exportedFcnInfo))
		return;
	end
fprintf(file,'\n');
fprintf(file,' /* Global functions exported by all charts */\n');
	for i=1:length(gMachineInfo.exportedFcnInfo)
		dump_exported_fcn(gMachineInfo.exportedFcnInfo(i),file);
	end
fprintf(file,'\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function	dump_exported_fcn(exportedFcnInfo,file)

    outputDataInfo = exportedFcnInfo.outputDataInfo;
    inputDataInfo = exportedFcnInfo.inputDataInfo;

    if (~isempty(outputDataInfo) && ~isempty(outputDataInfo(1).size))
        inputDataInfo = [inputDataInfo outputDataInfo(1)];
        outputDataInfo = [];
    end

	if(isempty(outputDataInfo))
		outputTypeStr = 'void';
    elseif length(outputDataInfo) == 1
		outputTypeStr = type_name_from_info(outputDataInfo(1));
	else
		comma = '';
		outputTypeStr = '';
		for i =1:length(outputDataInfo)
		    if (~isempty(outputDataInfo(i).size))
		        deref = '*';
		    else
		        deref = '';
		    end
            % an additional '*' because output types are passed by pointer.
			outputTypeStr = [outputTypeStr,comma,type_name_from_info(outputDataInfo(i)),deref,'*'];
			comma = ',';
		end
	end

	if(isempty(inputDataInfo))
		inputTypeStr = 'void';
	else
		comma = '';
		inputTypeStr = '';
		for i =1:length(inputDataInfo)
		    if (~isempty(inputDataInfo(i).size))
		        deref = '*';
		    else
		        deref = '';
		    end
			inputTypeStr = [inputTypeStr,comma,type_name_from_info(inputDataInfo(i)),deref];
			comma = ',';
		end
	end

    if length(outputDataInfo) <= 1
fprintf(file,'extern %s %s(%s);\n',outputTypeStr,exportedFcnInfo.name,inputTypeStr);
    else
        if ~isempty(inputDataInfo)
fprintf(file,'extern void %s(%s,%s);\n',exportedFcnInfo.name,inputTypeStr,outputTypeStr);
        else
fprintf(file,'extern void %s(%s);\n',exportedFcnInfo.name,outputTypeStr);
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = type_name_from_info(dataInfo)

	switch(dataInfo.type)
	case 'fixpt'
		str = c_type_from_signed_and_nbits(dataInfo.isSigned, dataInfo.wordLength);
	otherwise,
		str = c_type_from_sf_type(dataInfo.type);
	end
