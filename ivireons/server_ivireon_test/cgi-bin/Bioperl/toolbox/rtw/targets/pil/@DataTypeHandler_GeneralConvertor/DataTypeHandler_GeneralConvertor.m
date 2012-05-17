%DATATYPEHANDLER_GENERALCONVERTOR class to provide data type conversions
%   DATATYPEHANDLER_GENERALCONVERTOR class to provide data type conversions for
%   machines with the following attributes word order equal to byte order on
%   target and host for all data types. Information about the data types is
%   taken from the hardware implementation settings in the config set CONFIGSET.
%   Additional information is required about the ADDRESSINGMODE of the
%   processor being either Byte or Word addressable.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 19:11:36 $

classdef DataTypeHandler_GeneralConvertor < handle

  properties(GetAccess = 'protected', SetAccess = 'protected')
    target;
    host;
    convertor;
    dataTypeCollection;
    mapGenerator;
    bufferDataType;
  end

  methods(Access = 'public')

    function this = DataTypeHandler_GeneralConvertor(varargin)
      % Define constructors
      sigs{1} = {'configSet' 'addressingMode'};
      sigs{2} = {'endian' 'addressingMode' 'wordSize'};

      % Parse arguments
      args = targets_parse_argument_pairs({sigs{1}{:} sigs{2}{:}}, varargin);

      n = targets_find_signature(sigs, args);

      switch n
        case 1
          target_endian = get_param(args.configSet, 'ProdEndianess');
          target_addressingMode = args.addressingMode;
          target_nativeWordSize = get_param(args.configSet, 'ProdWordSize');
          rtwTypesInfo = TargetsUtils_RTWTypes(args.configSet);
          dataTypeName = 'boolean';
          [boolean_native boolean_cName boolean_size] = rtwTypesInfo.getDataType(dataTypeName);
          dataTypeName = 'int8';
          [int8_native int8_cName int8_size] = rtwTypesInfo.getDataType(dataTypeName);
          dataTypeName = 'uint8';
          [uint8_native uint8_cName uint8_size] = rtwTypesInfo.getDataType(dataTypeName);
          dataTypeName = 'int16';
          [int16_native int16_cName int16_size] = rtwTypesInfo.getDataType(dataTypeName);
          dataTypeName = 'uint16';
          [uint16_native uint16_cName uint16_size] = rtwTypesInfo.getDataType(dataTypeName);
          dataTypeName = 'int32';
          [int32_native int32_cName int32_size] = rtwTypesInfo.getDataType(dataTypeName);
          dataTypeName = 'uint32';
          [uint32_native uint32_cName uint32_size] = rtwTypesInfo.getDataType(dataTypeName);
        case 2
          target_endian = args.endian;
          target_addressingMode = args.addressingMode;
          target_nativeWordSize = args.wordSize;
          boolean_size = 1;
          int8_size = 1;
          uint8_size = 1;
          int16_size = 2;
          uint16_size = 2;
          int32_size = 4;
          uint32_size = 4;

        otherwise
          error('DataTypeHandler_GeneralConvertor:Constructor', 'Unknown constructor, a recognised constructor signature was not found');
      end

      this.target = TargetsComms_Machine(target_nativeWordSize, target_endian, target_addressingMode);

      % Get info on host system
      hostinfo = hostcpuinfo();
      % Get endian of host machine
      if hostinfo(3) == 0
        host_endian = 'LittleEndian';
      elseif hostinfo(3) == 1
        host_endian = 'BigEndian';
      end
      % Assume native wordsize is the same as the size of an int
      host_nativeWordSize = hostinfo(6);
      % Assume word order host == byte order host, need to add word order to host
      this.host = TargetsComms_Machine(host_nativeWordSize, host_endian, 'Byte');

      this.dataTypeCollection = DataTypeHandler_DataTypeCollection();
      % Setup data types
      dataTypeSpec = DataTypeHandler_BuiltinDataType('boolean', boolean_size, target_endian);
      this.dataTypeCollection.addItem(dataTypeSpec);


      dataTypeSpec = DataTypeHandler_BuiltinDataType('int8', int8_size, target_endian);
      this.dataTypeCollection.addItem(dataTypeSpec);

      dataTypeSpec = DataTypeHandler_BuiltinDataType('uint8', uint8_size, target_endian);
      this.dataTypeCollection.addItem(dataTypeSpec);

      dataTypeSpec = DataTypeHandler_BuiltinDataType('int16', int16_size, target_endian);
      this.dataTypeCollection.addItem(dataTypeSpec);


      dataTypeSpec = DataTypeHandler_BuiltinDataType('uint16', uint16_size, target_endian);
      this.dataTypeCollection.addItem(dataTypeSpec);

      dataTypeSpec = DataTypeHandler_BuiltinDataType('int32', int32_size, target_endian);
      this.dataTypeCollection.addItem(dataTypeSpec);

      dataTypeSpec = DataTypeHandler_BuiltinDataType('uint32', uint32_size, target_endian);
      this.dataTypeCollection.addItem(dataTypeSpec);

      % We do not have any information about these data types these are
      % specified by IEEE standard
      dataTypeSpec = DataTypeHandler_BuiltinDataType('single', 4, target_endian);
      this.dataTypeCollection.addItem(dataTypeSpec);

      dataTypeSpec = DataTypeHandler_BuiltinDataType('double', 8, target_endian);
      this.dataTypeCollection.addItem(dataTypeSpec);

      % Generate the datatype maps
      this.mapGenerator = DataTypeHandler_MapGenerator(this.host, this.target);
      this.dataTypeCollection.setDataTypeMaps(this.mapGenerator);

      %
      byteAddressable = this.target.isByteAddressable();
      if byteAddressable
        this.bufferDataType = 'uint8';
      else
        switch target_nativeWordSize
          case 16
            this.bufferDataType = 'uint16';
          case 32
            this.bufferDataType = 'uint32';
          otherwise
            error('DataTypeHandler_GeneralConvertor:Property:TargetNativeWordSize', ...
              'Target native wordsize can not be represented using available data types.');
        end
      end

    end

    function addDatatype(this, name, size, wordOrder)
      dataTypeSpec = DataTypeHandler_BuiltinDataType(name, size, wordOrder);
      this.dataTypeCollection.addItem(dataTypeSpec);

      % Regenerate the data type maps as a datatype has been added
      this.mapGenerator = DataTypeHandler_MapGenerator(this.host, this.target);
      this.dataTypeCollection.setDataTypeMaps(this.mapGenerator);
    end

    function [targetLayout hostLayout] = convertHostData(this, hostData)
      hostDataClass = class(hostData);
      hostLayout = typecast(hostData, this.bufferDataType);
      targetLayout = this.convertor.convert(hostLayout, hostDataClass);
    end

    function [hostData hostLayout] = convertTargetData(this, targetData, dataTypeName)
      targetData = typecast(targetData, this.bufferDataType);
      hostLayout = this.convertor.convert(targetData, dataTypeName);
      hostData = typecast(hostLayout, dataTypeName);
    end

    function clearDatatypes(this)
      this.dataTypeCollection = DataTypeHandler_DataTypeCollection();
    end

    function display(this)
      disp(['Host machine specification:' sprintf('\n')]);
      this.host.disp();
      disp(['Target machine specification:' sprintf('\n')]);
      this.target.disp();
      disp(['Target data type configuration:' sprintf('\n')]);
      this.dataTypeCollection.disp();
    end

    function disp(this)
      this.display();
    end

  end
  
  methods
    
    function this = set.dataTypeCollection(this, dataTypeCollection)
      this.dataTypeCollection = dataTypeCollection;
      this.convertor = this.setConvertor(dataTypeCollection);
    end
  end

    methods(Access = 'protected')
    
    function convertor = setConvertor(this, dataTypeCollection)
      convertor = DataTypeHandler_DataConvertor(dataTypeCollection);
    end
    
  end

end
