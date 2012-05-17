function dataType = c_type_from_signed_and_nbits(signed, nbits)

%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/24 11:23:05 $

    if nbits <= 8
        if signed
    		dataType ='int8_T';
        else
    		dataType ='uint8_T';
        end
    elseif nbits <= 16
        if signed
    		dataType ='int16_T';
        else
    		dataType ='uint16_T';
        end
    else
        if signed
    		dataType ='int32_T';
        else
    		dataType ='uint32_T';
        end
    end
