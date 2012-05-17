classdef TargetsMemory_MemoryBuffer < handle
% TARGETSMEMORY_MEMORYBUFFER - Class representing a Memory Buffer, for
% example a stack.
% 
% TargetsMemory_MemoryBuffer(name, baseAddress, memSize, growDirection)
%
% name: The name of the Memory Buffer (string)
%
% baseAddress: Memory address defining the base of the buffer (numeric,
% must be representable as a uint32)
%
% memSize: Memory buffer size in memory units (numeric, must be
% representable as a uint32)
%
% growDirection: Memory buffer growth direction (string, "up" or "down")
%

% Copyright 2006 The MathWorks, Inc.

   properties(SetAccess = 'protected')
      % properties
      name;
      baseAddress;
      memSize;
      growDirection;
   end

   properties(SetAccess = 'private', Dependent = true)
       % derived properties - get only
       endAddress;
   end
   
   methods
      function this = TargetsMemory_MemoryBuffer(name, ...
                                                 baseAddress, ...
                                                 memSize, ...
                                                 growDirection)
         %
         % Class constructor 
         %
         
         % check num args
         error(nargchk(4, 4, nargin, 'struct'));
         
         this.name = name;

         % base address must be representable as a uint32 value
         if uint32(baseAddress) ~= baseAddress
           TargetCommon.ProductInfo.error('targetsMemory', 'MemoryBufferInvalidBaseAddress');
         else
            this.baseAddress = baseAddress;
         end
         % memory buffer size must be representable as a uint32 value
         if uint32(memSize) ~= memSize
           TargetCommon.ProductInfo.error('targetsMemory', 'MemoryBufferInvalidBufferSize');
         else
            this.memSize = memSize;
         end
         % memory buffer size should be > 0
         if memSize == 0
           TargetCommon.ProductInfo.error('targetsMemory', 'MemoryBufferBufferSizeNonZero');
         end
         
         % growDirection must be "up" or "down"
         growDirection = lower(growDirection);
         switch growDirection
            case {'up' 'down'}
               this.growDirection = growDirection;
           otherwise
             TargetCommon.ProductInfo.error('targetsMemory', 'MemoryBufferInvalidGrowDirection');
         end
         
         % make sure end address does not exceed 32-bits
         if uint32(this.endAddress) ~= this.endAddress
           TargetCommon.ProductInfo.error('targetsMemory', 'MemoryBufferInvalidAddress', dec2hex(this.endAddress));
         end
      end
      
	  function v = get.endAddress(this)
         % determine the memory buffer end address
         v = this.baseAddress + this.memSize - 1;
      end

	  function set.endAddress(this, v)
         % derived property can't be set in this implementation
         TargetCommon.ProductInfo.error('targetsMemory', 'MemoryBufferInvalidEndAddress');
      end
                 
      function hyperlinkText = getHyperlink(this)
          commandText = ['disp(sprintf(''' ...
                         this.getHyperlinkContent ...
                         '''))'];         
          hyperlinkText = targets_hyperlink_manager('new', this.name, commandText);
      end

      function disp(this)
        % display useful information about this object
        % only operate on scalar instances of the class
        if isscalar(this)
            % use the hyperlink
            disp(this.getHyperlink);
        else
            disp([class(this) ' (handle array)']);
        end
      end
      
      function display(this)
         % display useful information about this object
         this.disp;
      end
   end
   
   methods(Access = 'protected')
       % protected method can be overridden by sub class to provide
       % different content
       function content = getHyperlinkContent(this)
           ba = this.baseAddress;
           ea = this.endAddress;
           ms = this.memSize;
           content = ['         name: ' this.name '\n' ...
               '  baseAddress: 0x' num2str(dec2hex(ba)) ' (' num2str(ba) ' decimal)\n' ...
               '   endAddress: 0x' num2str(dec2hex(ea)) ' (' num2str(ea) ' decimal)\n' ...
               '      memSize: 0x' num2str(dec2hex(ms)) ' (' num2str(ms) ' decimal) memory units\n' ...
               'growDirection: ' this.growDirection '\n'];
       end
   end
end
