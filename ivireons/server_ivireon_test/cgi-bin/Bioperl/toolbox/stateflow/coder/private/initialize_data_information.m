function initialize_data_information(dataList,dataNumbers,chart)
% INITIALIZE_DATA_INFORMATION(DATALIST,DATANUMBERS)


%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.43.4.11 $  $Date: 2009/06/16 05:46:20 $


	global gDataInfo

        if nargin < 3
            chart = [];
        end

	%%%% WISH: revamp the data and event numbering scheme such that we dont have to hard code
	%%%% the maximum number of machine parented data and events. machine parented data and
	%%%% events can have negative numbers.


	dataCount = length(dataList);
	gDataInfo.dataList(dataNumbers+1) = dataList;
	
	for i = 1:dataCount
		dataNumber = dataNumbers(i);
		data = dataList(i);
        dataParsedInfo = sf('DataParsedInfo', data);
		dataSizeArray = dataParsedInfo.size;

		gDataInfo.dataSizeArrays{dataNumber+1}  =  dataSizeArray;

		[gDataInfo.dataTypes{dataNumber+1}...
		,gDataInfo.sfDataTypes{dataNumber+1}...
		,gDataInfo.slDataTypes{dataNumber+1}] = data_type_conversion(data,dataSizeArray,chart);
	end

   return;

function [cDataType,...
          sfDataType,...
          slDataType] = data_type_conversion( data,dataSizeArray,chart)

    coderDataType = sf('CoderDataType',data);
	
    %%TODO: This should be fixed.  The container type must match the
    %%generated C type.  The code below does not work for multi-word.
    if strcmp(coderDataType,'fixpt')
        [exponent,slope,bias,nBits,isSigned] = sf('FixPtProps',data);
        containerSizes = [8,16,32];
        containerBits = min(containerSizes(nBits <= containerSizes));
        if isempty(containerBits)
            containerBits = 0;
        end
        if isSigned
            switch containerBits
                case  8, coderDataType = 'int8';
                case 16, coderDataType = 'int16';
                case 32, coderDataType = 'int32';
                otherwise, coderDataType = 'double';
            end
        else
            switch containerBits
                case  8, coderDataType = 'uint8';
                case 16, coderDataType = 'uint16';
                case 32, coderDataType = 'uint32';
                otherwise, coderDataType = 'double';
            end
        end
    end
    
	cDataType = c_type_from_sf_type(coderDataType,data);
	sfDataType= sf_type_enum_from_name(coderDataType);
	slDataType= sl_type_enum_from_name(coderDataType);
	
	


