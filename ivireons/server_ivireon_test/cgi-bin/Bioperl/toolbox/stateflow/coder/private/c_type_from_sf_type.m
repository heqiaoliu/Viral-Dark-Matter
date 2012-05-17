function dataType = c_type_from_sf_type(sfTypeName, data)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2008/06/20 09:00:56 $

	switch(lower(sfTypeName))
	case {'boolean','state','boolean (unsigned char)','boolean (1 bit)'}
		dataType ='boolean_T';
	case {'uint8','nibble (4 bits)','byte (unsigned char)'}
		dataType ='uint8_T';
	case {'uint16','word (unsigned short)'}
		dataType = 'uint16_T';	
	case {'uint32','word (unsigned long)'} 
		dataType = 'uint32_T';
	case {'int8','byte (signed char)'}
		dataType ='int8_T';
	case {'int16','integer (short)'}
		dataType = 'int16_T';
	case {'int32','integer (long)'}
		dataType ='int32_T';
	case {'single','real (float)'}
		dataType = 'real32_T';
	case {'double','real (double)',''}
		dataType = 'real_T';
	case {'ml'}
		dataType = 'const mxArray*';
    case {'enumerated'}
        hData = idToHandle(sfroot, data);
        dataType = hData.CompiledType;
	otherwise,
		dataType = 'real_T';
	end
