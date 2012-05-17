%TARGETSCOMMS_MACHINE class to hold information about a machine
%   TARGETSCOMMS_MACHINE class to hold information about a machine. It has the
%   following inputs WORDLENGTH is the native word size of the machine BYTEORDER
%   is the endian of the machine
%   , , ADDRESSINGMODE

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 19:11:40 $

classdef TargetsComms_Machine < handle
  
  properties(SetAccess = 'protected', GetAccess = 'public')
    wordLength; % in bits
    byteOrder; % BigEndian, LittleEndian
    addressingMode; % Word, Byte  
  end
  
  methods(Access = 'public')
    
    function this = TargetsComms_Machine(wordLength, byteOrder, addressingMode)
      this.wordLength = wordLength;
      this.byteOrder = byteOrder;
      this.addressingMode = addressingMode;
    end
    
    function byteAddressable = isByteAddressable(this)
      if strcmp(this.addressingMode, 'Byte')
        byteAddressable = true;
      else
        byteAddressable = false;
      end
    end
    
    function display(this)
      disp(['Machine endian: ' this.byteOrder]);
      disp(['Addressing mode: ' this.addressingMode]);
      disp(['Native word size: ' sprintf('%d\n', this.wordLength)]);
    end
    
    function disp(this)
      this.display();
    end
    
  end
  
  methods

    function this = set.byteOrder(this, byteOrder)
      valid = strcmp(byteOrder, {'BigEndian', 'LittleEndian'});
      if any(valid)
        this.byteOrder = byteOrder;
      else
        error('TargetsComms_Machine:Property:byteOrder', 'Byte order must be one of ''BigEndian'' or ''LittleEndian''');
      end
    end
    
    function this = set.addressingMode(this, addressingMode)
      valid = strcmp(addressingMode, {'Byte', 'Word'});
      if any(valid)
        this.addressingMode = addressingMode;
      else
        error('TargetsComms_Machine:Property:addressingMode', 'Addressing mode must be one of ''Byte'' or ''Word''');
      end      
    end
    
  end
  
end
