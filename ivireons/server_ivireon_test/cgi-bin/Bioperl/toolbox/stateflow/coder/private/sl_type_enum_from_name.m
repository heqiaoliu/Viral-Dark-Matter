function slTypeEnum = sl_type_enum_from_name(dataType)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2008/06/20 09:01:08 $

	switch(lower(dataType))
	case {'boolean','state'}
		slTypeEnum = 'SS_BOOLEAN';
	case 'uint8'
		slTypeEnum = 'SS_UINT8';
	case 'uint16'
		slTypeEnum = 'SS_UINT16';
	case 'uint32'
		slTypeEnum = 'SS_UINT32';
	case 'int8'
		slTypeEnum = 'SS_INT8';
	case 'int16'
		slTypeEnum = 'SS_INT16';
	case 'int32'
		slTypeEnum = 'SS_INT32';
	case 'single'
		slTypeEnum = 'SS_SINGLE';
	case 'double'
		slTypeEnum = 'SS_DOUBLE';
    case 'enumerated'
        slTypeEnum = 'SS_ENUM_TYPE';
	otherwise,
		slTypeEnum = 'SS_DOUBLE';
	end
