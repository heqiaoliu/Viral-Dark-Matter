function code_machine_source_file_sfun(fileNameInfo)
% CODE_MACHINE_SOURCE_FILE(FILENAMEINFO,MACHINE,TARGET)

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.21 $  $Date: 2010/03/15 23:51:18 $


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%  GLOBAL VARIABLES
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	global gMachineInfo  gTargetInfo

   machine = gMachineInfo.machineId;

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineSourceFile);
   sf_echo_generating('Coder',fileName);

   file = fopen(fileName,'Wt');
   if file<3
     construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
     return;
   end

fprintf(file,'/* Include files */\n');
    customCodeSettings = get_custom_code_settings(gMachineInfo.target,gMachineInfo.parentTarget);
    customCodeString = customCodeSettings.customCode;
	if(~isempty(customCodeString))
fprintf(file,'#define IN_SF_MACHINE_SOURCE 1\n');
	end
fprintf(file,'#include "%s"\n',fileNameInfo.machineHeaderFile);
	for i = 1:length(fileNameInfo.chartHeaderFiles)
        for j = 1:length(fileNameInfo.chartHeaderFiles{i})
fprintf(file,'#include "%s"\n',fileNameInfo.chartHeaderFiles{i}{j});
        end
    end

    if(~isempty(customCodeSettings.customSourceCode))
fprintf(file,'/* Custom Source Code */        \n');
fprintf(file,'%s\n',customCodeSettings.customSourceCode);
    end

	file = dump_module(fileName,file,machine,'source');
    if file < 3
      return;
    end

fprintf(file,'/* SFunction Glue Code */\n');
fprintf(file,'unsigned int sf_%s_method_dispatcher(SimStruct *simstructPtr, unsigned int chartFileNumber, const char* specsCksum, int_T method, void *data)\n',gMachineInfo.machineName);
fprintf(file,'{\n');
		for i = 1:length(gMachineInfo.charts)
            chart = gMachineInfo.charts(i);            
            chartFileNumber = sf('get',chart,'chart.chartFileNumber');
fprintf(file,'	if(chartFileNumber==%.17g) {\n',chartFileNumber);
            numSpecs = length(gMachineInfo.specializations{i});
            if numSpecs > 1
                for j = 1:numSpecs
                    chartUniqueName = sf('CodegenNameOf', chart, gMachineInfo.specializations{i}{j});
fprintf(file,'     if (!strcmp(specsCksum, "%s")) {\n',gMachineInfo.specializations{i}{j});
fprintf(file,'	        %s_method_dispatcher(simstructPtr, method, data);\n',chartUniqueName);
fprintf(file,'         return 1;\n');
fprintf(file,'     }\n');
                end
fprintf(file,'     return 0;\n');
            else
                chartUniqueName = sf('CodegenNameOf',chart);
fprintf(file,'	    %s_method_dispatcher(simstructPtr, method, data);\n',chartUniqueName);
fprintf(file,'     return 1;\n');
            end
fprintf(file,'	}\n');
		end
fprintf(file,'	return 0;\n');
fprintf(file,'}\n');

%%TLTODO: Dispatch following calls to specializations. sf('CodegenNameOf',chart,spec)
%%/* ProcessMexSfunctionCmdLineCall */
%%sf_process_check_sum_call
%%sf_process_testpoint_info_call (only if bus can be inherited at input)
%%sf_process_autoinheritance_call
%%sf_process_get_eml_resolved_functions_info_call

      if gTargetInfo.codingExtMode
fprintf(file,'unsigned int sf_%s_process_testpoint_info_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] )\n',gMachineInfo.machineName);
fprintf(file,'{\n');
fprintf(file,'#ifdef MATLAB_MEX_FILE\n');
fprintf(file,'	char commandName[32];\n');
fprintf(file,' char machineName[128];\n');
fprintf(file,'	if (nrhs < 3 || !mxIsChar(prhs[0]) || !mxIsChar(prhs[1])) return 0;\n');
fprintf(file,'%s\n',sf_comment('/* Possible call to get testpoint info. */'));
fprintf(file,'	mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'	commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'	if(strcmp(commandName,"get_testpoint_info")) return 0;\n');
fprintf(file,' mxGetString(prhs[1], machineName, sizeof(machineName)/sizeof(char));\n');
fprintf(file,'	machineName[(sizeof(machineName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'	if (!strcmp(machineName, "%s")) {\n',gMachineInfo.machineName);
fprintf(file,'	   unsigned int chartFileNumber;\n');
fprintf(file,'	   chartFileNumber = (unsigned int)mxGetScalar(prhs[2]);\n');
fprintf(file,'	   switch(chartFileNumber) {\n');
         for chart = gMachineInfo.charts
            chartUniqueName = sf('CodegenNameOf',chart);
            chartFileNumber = sf('get',chart,'chart.chartFileNumber');
fprintf(file,'	      case %.17g:\n',chartFileNumber);
fprintf(file,'	      {\n');
fprintf(file,'	         extern mxArray *sf_%s_get_testpoint_info(void);\n',chartUniqueName);
fprintf(file,'	         plhs[0] = sf_%s_get_testpoint_info();\n',chartUniqueName);
fprintf(file,'	         break;\n');
fprintf(file,'	      }\n');
fprintf(file,'\n');
         end
fprintf(file,'	      default:\n');
fprintf(file,'          plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);\n');
fprintf(file,'	   }\n');
fprintf(file,'    return 1;\n');
fprintf(file,' }\n');
fprintf(file,' return 0;\n');
fprintf(file,'#else\n');
fprintf(file,'	return 0;\n');
fprintf(file,'#endif\n');
fprintf(file,'}\n');
fprintf(file,'\n');
      end
 
fprintf(file,'unsigned int sf_%s_process_check_sum_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] )\n',gMachineInfo.machineName);
fprintf(file,'{\n');
fprintf(file,'#ifdef MATLAB_MEX_FILE\n');
fprintf(file,'	char commandName[20];\n');
fprintf(file,'	if (nrhs<1 || !mxIsChar(prhs[0]) ) return 0;\n');
fprintf(file,'%s\n',sf_comment('/* Possible call to get the checksum */'));
fprintf(file,'	mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'	commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'	if(strcmp(commandName,"sf_get_check_sum")) return 0;\n');
fprintf(file,'	plhs[0] = mxCreateDoubleMatrix( 1,4,mxREAL);\n');

		if gTargetInfo.codingLibrary
fprintf(file,'	if(nrhs>2 && mxIsChar(prhs[1])) {\n');
fprintf(file,'		mxGetString(prhs[1], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'		commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'		if(!strcmp(commandName,"library")) {\n');
fprintf(file,'			char machineName[100];\n');
fprintf(file,'			mxGetString(prhs[2], machineName,sizeof(machineName)/sizeof(char));\n');
fprintf(file,'			machineName[(sizeof(machineName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'			if(!strcmp(machineName,"%s")){\n',gMachineInfo.machineName);
fprintf(file,'             if(nrhs==3) {    \n');
			        checksumVector = sf('get',gMachineInfo.target,'target.checksumNew');
			        for i=1:4
fprintf(file,'				        ((real_T *)mxGetPr((plhs[0])))[%.17g] = (real_T)(%.17gU);\n',(i-1),checksumVector(i));
			        end
fprintf(file,'             }else if(nrhs==4) {\n');
fprintf(file,'			       unsigned int chartFileNumber;\n');
fprintf(file,'			       chartFileNumber = (unsigned int)mxGetScalar(prhs[3]);\n');
fprintf(file,'			       switch(chartFileNumber) {\n');
     			      for chart = gMachineInfo.charts
         	             chartUniqueName = sf('CodegenNameOf',chart);
				         chartFileNumber = sf('get',chart,'chart.chartFileNumber');
fprintf(file,'			      case %.17g:\n',chartFileNumber);
fprintf(file,'			      {\n');
fprintf(file,'				      extern void sf_%s_get_check_sum(mxArray *plhs[]);\n',chartUniqueName);
fprintf(file,'				      sf_%s_get_check_sum(plhs);\n',chartUniqueName);
fprintf(file,'				      break;\n');
fprintf(file,'			      }\n');
                      end
fprintf(file,'			      default:\n');
			        for i=1:4
fprintf(file,'				      ((real_T *)mxGetPr((plhs[0])))[%.17g] = (real_T)(0.0);\n',(i-1));
			        end
fprintf(file,'                }\n');
fprintf(file,'             }else{\n');
fprintf(file,'                 return 0;\n');
fprintf(file,'             }\n');
fprintf(file,'			}else{\n');
fprintf(file,'				return 0;\n');
fprintf(file,'			}\n');
fprintf(file,'		}else {\n');
fprintf(file,'			return 0;\n');
fprintf(file,'		}\n');
fprintf(file,'	}else {\n');
fprintf(file,'		return 0;\n');
fprintf(file,'	}\n');
fprintf(file,'\n');
    else
fprintf(file,'	if(nrhs>1 && mxIsChar(prhs[1])) {\n');
fprintf(file,'		mxGetString(prhs[1], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'		commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'		if(!strcmp(commandName,"machine")) {\n');
			checksumVector = sf('get',gMachineInfo.machineId,'machine.checksum');
			for i=1:4
fprintf(file,'			((real_T *)mxGetPr((plhs[0])))[%.17g] = (real_T)(%.17gU);\n',(i-1),checksumVector(i));
		   end
fprintf(file,'		}else if(!strcmp(commandName,"exportedFcn")) {\n');
			checksumVector = sf('get',gMachineInfo.machineId,'machine.exportedFcnChecksum');
			for i=1:4
fprintf(file,'			((real_T *)mxGetPr((plhs[0])))[%.17g] = (real_T)(%.17gU);\n',(i-1),checksumVector(i));
			end
fprintf(file,'		}else if(!strcmp(commandName,"makefile")) {\n');
			checksumVector = sf('get',gMachineInfo.machineId,'machine.makefileChecksum');
			for i=1:4
fprintf(file,'			((real_T *)mxGetPr((plhs[0])))[%.17g] = (real_T)(%.17gU);\n',(i-1),checksumVector(i));
			end
fprintf(file,'		}else if(nrhs==3 && !strcmp(commandName,"chart")) {\n');
fprintf(file,'			unsigned int chartFileNumber;\n');
fprintf(file,'			chartFileNumber = (unsigned int)mxGetScalar(prhs[2]);\n');
fprintf(file,'			switch(chartFileNumber) {\n');
			for chart = gMachineInfo.charts
         	chartUniqueName = sf('CodegenNameOf',chart);
				chartFileNumber = sf('get',chart,'chart.chartFileNumber');
fprintf(file,'			case %.17g:\n',chartFileNumber);
fprintf(file,'			{\n');
fprintf(file,'				extern void sf_%s_get_check_sum(mxArray *plhs[]);\n',chartUniqueName);
fprintf(file,'				sf_%s_get_check_sum(plhs);\n',chartUniqueName);
fprintf(file,'				break;\n');
fprintf(file,'			}\n');
fprintf(file,'\n');
			end
fprintf(file,'			default:\n');
			for i=1:4
fprintf(file,'				((real_T *)mxGetPr((plhs[0])))[%.17g] = (real_T)(0.0);\n',(i-1));
			end
fprintf(file,'			}\n');
fprintf(file,'		}else if(!strcmp(commandName,"target")) {\n');
			checksumVector = sf('get',gMachineInfo.target,'target.checksumSelf');
			for i=1:4
fprintf(file,'			((real_T *)mxGetPr((plhs[0])))[%.17g] = (real_T)(%.17gU);\n',(i-1),checksumVector(i));
			end
fprintf(file,'		}else {\n');
fprintf(file,'			return 0;\n');
fprintf(file,'		}\n');
fprintf(file,'	} else{\n');
			checksumVector = sf('get',gMachineInfo.target,'target.checksumNew');
			for i=1:4
fprintf(file,'				((real_T *)mxGetPr((plhs[0])))[%.17g] = (real_T)(%.17gU);\n',(i-1),checksumVector(i));
			end
fprintf(file,'	}\n');
		end
fprintf(file,'	return 1;\n');
fprintf(file,'#else\n');
fprintf(file,'	return 0;\n');
fprintf(file,'#endif\n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'unsigned int sf_%s_autoinheritance_info( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] )\n',gMachineInfo.machineName);
fprintf(file,'{\n');
fprintf(file,'#ifdef MATLAB_MEX_FILE\n');
fprintf(file,'	char commandName[32];\n');
fprintf(file,'	if (nrhs<2 || !mxIsChar(prhs[0]) ) return 0;\n');
fprintf(file,'%s\n',sf_comment('/* Possible call to get the autoinheritance_info */'));
fprintf(file,'	mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'	commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'	if(strcmp(commandName,"get_autoinheritance_info")) return 0;\n');
fprintf(file,'{\n');
fprintf(file,'			unsigned int chartFileNumber;\n');
fprintf(file,'			chartFileNumber = (unsigned int)mxGetScalar(prhs[1]);\n');
fprintf(file,'			switch(chartFileNumber) {\n');
			for chart = gMachineInfo.charts
         	chartUniqueName = sf('CodegenNameOf',chart);
			chartFileNumber = sf('get',chart,'chart.chartFileNumber');
fprintf(file,'			case %.17g:\n',chartFileNumber);
fprintf(file,'			{\n');
fprintf(file,'				extern mxArray *sf_%s_get_autoinheritance_info(void);\n',chartUniqueName);
fprintf(file,'				plhs[0] = sf_%s_get_autoinheritance_info();\n',chartUniqueName);
fprintf(file,'				break;\n');
fprintf(file,'			}\n');
fprintf(file,'\n');
			end
fprintf(file,'			default:\n');
fprintf(file,'             plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);\n');
fprintf(file,'			}\n');
fprintf(file,'}\n');
fprintf(file,'	return 1;\n');
fprintf(file,'#else\n');
fprintf(file,'	return 0;\n');
fprintf(file,'#endif\n');
fprintf(file,'}\n');

fprintf(file,'unsigned int sf_%s_get_eml_resolved_functions_info( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] )\n',gMachineInfo.machineName);
fprintf(file,'{\n');
fprintf(file,'#ifdef MATLAB_MEX_FILE\n');
fprintf(file,'	char commandName[64];\n');
fprintf(file,'	if (nrhs<2 || !mxIsChar(prhs[0])) return 0;\n');
fprintf(file,'%s\n',sf_comment('/* Possible call to get the get_eml_resolved_functions_info */'));
fprintf(file,'	mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'	commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'	if(strcmp(commandName,"get_eml_resolved_functions_info")) return 0;\n');
fprintf(file,'{\n');
fprintf(file,'			unsigned int chartFileNumber;\n');
fprintf(file,'			chartFileNumber = (unsigned int)mxGetScalar(prhs[1]);\n');
fprintf(file,'			switch(chartFileNumber) {\n');
			for chart = gMachineInfo.charts
         	chartUniqueName = sf('CodegenNameOf',chart);
			chartFileNumber = sf('get',chart,'chart.chartFileNumber');
fprintf(file,'			case %.17g:\n',chartFileNumber);
fprintf(file,'			{\n');
fprintf(file,'				extern const mxArray *sf_%s_get_eml_resolved_functions_info(void);\n',chartUniqueName);
fprintf(file,'             mxArray *persistentMxArray = (mxArray *)sf_%s_get_eml_resolved_functions_info();\n',chartUniqueName);
fprintf(file,'				plhs[0] = mxDuplicateArray(persistentMxArray);\n');
fprintf(file,'             mxDestroyArray(persistentMxArray);\n');
fprintf(file,'				break;\n');
fprintf(file,'			}\n');
fprintf(file,'\n');
			end
fprintf(file,'			default:\n');
fprintf(file,'             plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);\n');
fprintf(file,'			}\n');
fprintf(file,'}\n');
fprintf(file,'	return 1;\n');
fprintf(file,'#else\n');
fprintf(file,'	return 0;\n');
fprintf(file,'#endif\n');
fprintf(file,'}\n');

   if gTargetInfo.codingDebug
fprintf(file,'void  %s_debug_initialize(void)\n',gMachineInfo.machineName);
fprintf(file,'{\n');
	   code_machine_debug_initialization(file);
fprintf(file,'}\n');
	end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Exported data registration
    %%%% We want to generate a function looking like:
    %%%%
    %%%% void machinename_register_exported_symbols(SimStruct* S)
    %%%% {
    %%%%    ssRegMdlInfo(S, "x1", MDL_INFO_ID_MACHINE_EXPORTED, 0, 0, (void*) NULL);     
    %%%%    ssRegMdlInfo(S, "x2", MDL_INFO_ID_MACHINE_EXPORTED, 0, 0, (void*) NULL);     
    %%%%    ssRegMdlInfo(S, "x3", MDL_INFO_ID_MACHINE_EXPORTED, 0, 0, (void*) NULL);     
    %%%%    ssRegMdlInfo(S, "x4", MDL_INFO_ID_MACHINE_EXPORTED, 0, 0, (void*) NULL);     
    %%%% } 
    %%%% 
    %%%% This will register all exported data with simulink and if there is a name
    %%%% clash it will be detected by simulink and an error will be reported
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

fprintf(file,'\n');
fprintf(file,'  void %s_register_exported_symbols(SimStruct* S)\n',gMachineInfo.machineName);
fprintf(file,'  {\n');
       for i=1:length(gMachineInfo.exportedData)
           exportedId = gMachineInfo.exportedData(i);
           exportedDataName = sf('get',exportedId,'data.name');
fprintf(file,'        ssRegMdlInfo(S, "%s", MDL_INFO_ID_MACHINE_EXPORTED, 0, 0, (void*) NULL);   \n',exportedDataName);
       end
fprintf(file,'}\n');

	fclose(file);
	try_indenting_file(fileName);

