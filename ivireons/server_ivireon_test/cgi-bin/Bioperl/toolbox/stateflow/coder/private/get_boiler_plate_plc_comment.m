function str = get_boiler_plate_plc_comment(objectType,objectId)

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/07/03 14:42:14 $

	global gTargetInfo

   if ~gTargetInfo.codingPLC
      str = '';
      return;
   end
   
SF_CODER_STR='';

SF_CODER_STR=[SF_CODER_STR,sprintf('(**********************************************************************\n')];
		switch(objectType)
		case 'sf_chart'
SF_CODER_STR=[SF_CODER_STR,sprintf(' * Stateflow PLC code generation for chart:\n')];
		case 'eml_chart'
SF_CODER_STR=[SF_CODER_STR,sprintf(' * Embedded MATLAB Function PLC code generation for Block:\n')];
		end
SF_CODER_STR=[SF_CODER_STR,sprintf(' *    %s\n',sf('FullNameOf',chartId,'/'))];
SF_CODER_STR=[SF_CODER_STR,sprintf(' *\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf(' * Target language                      : ST\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf(' * Date of code generation              : %s\n',sf('Private','sf_date_str'))];
SF_CODER_STR=[SF_CODER_STR,sprintf(' *\n')];
SF_CODER_STR=[SF_CODER_STR,sprintf(' **********************************************************************)\n')];
	
str = SF_CODER_STR;
