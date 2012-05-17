classdef TargetsMemory_MemoryProfileInfo < handle
% TARGETSMEMORY_MEMORYPROFILEINFO - Class representing memory profiling 
% results for a Memory Buffer.
% 
% TargetsMemory_MemoryProfileInfo(memoryBuffer, wordsUsed, memoryWords)
%
% memoryBuffer: MemoryBuffer class defining the memory region that was
%               profiled.
%
% wordsUsed: The number of words used at the last profile point.
%
% memoryWords: The memory words of the memory region at the last profile
%              point.
%

% Copyright 2006-2007 The MathWorks, Inc.

   properties(SetAccess = 'protected')
      % properties
      memoryBuffer;
      wordsUsed;
      memoryWords;
   end

   properties(SetAccess = 'private', Dependent = true)
       % derived properties - get only
       memoryLength;
       percentageUse;
   end
   
   methods
      function this = TargetsMemory_MemoryProfileInfo(memoryBuffer, ...
                                                      wordsUsed, ...
                                                      memoryWords)
         %
         % Class constructor 
         %
         
         % check num args
         error(nargchk(3, 3, nargin, 'struct'));
         
         this.memoryBuffer = memoryBuffer;
         this.wordsUsed = wordsUsed;
         this.memoryWords = memoryWords;
      end
      
      function v = get.memoryLength(this)
         % determine the memory length
         v = length(this.memoryWords);
      end

	  function set.memoryLength(this, v)
         % derived property can't be set in this implementation
         TargetCommon.ProductInfo.error('targetsMemory', 'MemoryProfileInfoInvalidMemoryLength');
      end
      
      function v = get.percentageUse(this)
         % determine the percentage memory use
         v = (this.wordsUsed / this.memoryLength) * 100;
         % round to 2 decimal places
         v = str2double(sprintf('%.2f', v));
      end

	  function set.percentageUse(this, v)
         % derived property can't be set in this implementation
         TargetCommon.ProductInfo.error('targetsMemory', 'MemoryProfileInfoInvalidPercentageUse');
      end
      
      function disp(this)
        % display useful information about this object
        % only operate on scalar instances of the class
        if isscalar(this)
            % get the memory buffer hyperlink
            memoryBufferHyperlink = this.memoryBuffer.getHyperlink;
            disp([memoryBufferHyperlink ': ' ...
                  num2str(this.wordsUsed) '/' ...
                  num2str(this.memoryLength) ' (' ...
                  num2str(this.percentageUse) '%) words used.']);
        else
            disp([class(this) ' (handle array)']);
            disp(' ');
        end
      end
      
      function display(this)
         % display useful information about this object
         this.disp;
      end
   end
end
