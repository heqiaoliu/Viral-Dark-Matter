%TARGETSUTILS_RTWTYPES contains logic to provide mapping between C types and RTW types
%   TARGETSUTILS_RTWTYPES contains logic to provide mapping between C types and
%   RTW types. It take a configuration set CONFIGSET which contains information 
%   about the target processor in the hardware imple. This file mirrors the 
%   logic used in: edit([matlabroot '\toolbox\rtw\rtw\private\getAnsiDataType.m'])

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/05/08 05:31:37 $

classdef TargetsUtils_RTWTypes < handle

  properties
    charName;
    charBytes;

    shortName;
    shortBytes;

    intName;
    intBytes;

    longName;
    longBytes;
  end

  methods

    function this = TargetsUtils_RTWTypes(configSet)
      
      % Configuration Set information for hardware implementation
      %
      % Parameters
      %
      % ProdBitPerChar - number of bits in a c char
      % ProdBitPerInt - number of bits in a c int
      % ProdBitPerLong - nunber of bits in a c long
      % ProdBitPerShort - number of bits in a c short
      % ProdEndianess - endian of target
      % ProdHWWordLengths - cell of {char short int long}
      % ProdWordSize - native word size of target in bits
      % ProdHWDeviceType - name of target as seen in hw imp drop down can be used to
      % set up the sizes above
      
      % get the sizes
      charSize = get_param(configSet, 'ProdBitPerChar');
      this.charBytes = charSize / 8;
      this.charName = 'char';
      %
      shortSize = get_param(configSet, 'ProdBitPerShort');
      this.shortBytes = shortSize / 8;
      this.shortName = 'short';
      %
      intSize = get_param(configSet, 'ProdBitPerInt');
      this.intBytes = intSize / 8;
      this.intName = 'int';
      %
      longSize = get_param(configSet, 'ProdBitPerLong');
      this.longBytes = longSize / 8;
      this.longName = 'long';
    end

    function [native cName size] = dataTypeLogic(this, dataType)
      switch dataType
        case {'uint64' 'int64'}
          requiredSize = 8;
          if requiredSize == this.longBytes
            native = true;
            cName = this.longName;
            size = this.longBytes;
          else
            native = false;
            cName = [];
            size = [];
          end
        case {'uint32' 'int32' 'uint16' 'int16' 'uint8' 'int8' 'boolean'}
          if strcmp(dataType, 'boolean')
            % boolean maps to uint8
            dataType = 'uint8';
          end
          [native cName size] = this.dataTypeMappingLogic(dataType);
      end

    end

    function [native cName size] = dataTypeMappingLogic(this, dataType, native)
      if nargin == 2
        native = true;
      end

      dtNames = {'int8' 'int16' 'int32'};
      dtSizes = [1 2 4];
      dtName = regexp(dataType, 'int.*', 'match');
      [member location] = ismember(dtName, dtNames);
      requiredSize = dtSizes(location);

      switch requiredSize
        % the ordering of these cases is important it dictates the priority of
        % the mapping
        case this.intBytes
          cName = this.intName;
          size = this.intBytes;
        case this.longBytes
          cName = this.longName;
          size = this.longBytes;
        case this.charBytes
          cName = this.charName;
          size = this.charBytes;
        case this.shortBytes
          cName = this.shortName;
          size = this.shortBytes;
        otherwise
          % size of the next largest datatype
          native = false;
          cName = [];
          size = [];
          location = location + 1;
          if location > length(dtNames)
            % we got to the bigest data type and did not find a match
            return;
          end
          dataType = dtNames{location};
          [native cName size] = this.dataTypeMappingLogic(dataType, native);
      end
    end

    function [native cName size] = getDataType(this, dataType)
      [native cName size] = this.dataTypeLogic(dataType);
    end

  end

end
