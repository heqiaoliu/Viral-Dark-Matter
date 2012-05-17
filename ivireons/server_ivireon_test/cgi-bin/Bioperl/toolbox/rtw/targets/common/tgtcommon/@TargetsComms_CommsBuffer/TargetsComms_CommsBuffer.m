%TARGETSCOMMS_COMMSBUFFER class to create a buffer with specific units and size
%   TARGETSCOMMS_COMMSBUFFER class to create a buffer to handle data in specific
%   units and size. Inputs are BUFFERDATATYPE which is  the storage units used 
%   by the buffer. BUFFERSIZE is the number of storage units returned when 
%   calling the getBuffer method.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/12/14 14:58:25 $

classdef TargetsComms_CommsBuffer < handle
  
  properties(SetAccess = 'protected', GetAccess = 'protected')
    bufferDataType;
    bufferSize;
    internalBuffer = [];
    lastIdx = 0;
    bufferLen;
  end
  
  properties(Dependent = true)
    buffer;
  end
  
  methods(Access = 'public')
    
    function this = TargetsComms_CommsBuffer(bufferDataType, bufferSize)
      this.bufferDataType = bufferDataType;
      this.bufferSize = bufferSize;
    end
  end
  
  methods
          
    function this = set.buffer(this, data)
      bufferData = typecast(data, this.bufferDataType);
      this.internalBuffer = [this.internalBuffer bufferData];
      this.bufferLen = length(this.internalBuffer);
    end
  end

  methods
    function buffer = get.buffer(this)
      buffer = this.getBuffer();
    end
  end
  
  methods(Access = 'public')

    function [buffer isLast] = getBuffer(this)
      if this.bufferLen > (this.lastIdx + this.bufferSize)
        isLast = false;
        buffer = this.internalBuffer((this.lastIdx + 1):(this.lastIdx + this.bufferSize));
        this.lastIdx = this.lastIdx + this.bufferSize;
      else
        isLast = true;
        buffer = this.internalBuffer((this.lastIdx + 1):end);
      end
    end
    
  end
  
end
