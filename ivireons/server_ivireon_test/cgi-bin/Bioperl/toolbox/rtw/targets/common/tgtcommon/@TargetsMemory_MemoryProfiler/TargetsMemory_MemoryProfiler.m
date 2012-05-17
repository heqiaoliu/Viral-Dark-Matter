classdef TargetsMemory_MemoryProfiler < handle
% TARGETSMEMORY_MEMORYPROFILER - Abstract class for profiling Memory
% Buffers.
% 
% TargetsMemory_MemoryProfiler(memoryBuffers, resetWords)
%
% memoryBuffers: The Memory Buffers to profile.
%
% resetWords: Corresponding reset words for each Memory Buffer
%

% Copyright 2006 The MathWorks, Inc.

   % abstract properties - not fully implemented in MCOS yet
   properties(SetAccess = 'protected', Abstract=true)
      memoryBuffers;
      resetWords;
   end

   % Abstract methods - not fully implemented in MCOS yet
   methods(Access = 'protected', Abstract=true)
       words = read(this, memoryBuffer)
        % protected, abstract method to read a MemoryBuffer from 
        % target memory and return it as word values

       write(this, memoryBuffer, resetWord)
        % protected, abstract method to write a reset word to 
        % MemoryBuffer in target memory
   end
   
   % public methods
   methods
      function reset(this)
          % RESET - reset all memory buffers with the reset word
          %
          validateAbstractProperties(this);
          for i=1:length(this.memoryBuffers)
              memoryBuffer = this.memoryBuffers(i);
              resetWord = this.resetWords(i);
              this.write(memoryBuffer, resetWord);
          end
      end
      
      function info = profile(this)
          % PROFILE - profile all memory buffers
          %
          % profile

          validateAbstractProperties(this);
          % initialise to empty array
          info = [];
          for i=1:length(this.memoryBuffers)
              memoryBuffer = this.memoryBuffers(i);
              resetWord = this.resetWords(i);
              words = this.read(memoryBuffer);

              % find first non-signature word
              mismatches = (words ~= resetWord);
              % find word indices
              mismatchIndices = find(mismatches);
              if ~isempty(mismatchIndices)
                  switch memoryBuffer.growDirection
                      case 'down'
                          % memoryBuffer grows from high memory down to low memory
                          highMarker = mismatchIndices(1);
                          usedWords = length(words) - highMarker + 1;
                      case 'up'
                          % memoryBuffer grows from low memory up to high memory
                          highMarker = mismatchIndices(end);
                          usedWords = highMarker;
                    otherwise
                        TargetCommon.ProductInfo.error('targetsMemory', 'MemoryProfilerUnknowGrowDirection', memoryBuffer.growDirection);
                  end
              else
                  % no memoryBuffer usage
                  usedWords = 0;
              end

              pinfo = TargetsMemory_MemoryProfileInfo(memoryBuffer, usedWords, words);
              % add to the info array
              if isempty(info)
                  info = pinfo;
              else
                  info(end+1) = pinfo;
              end
          end
      end
   end
   
   % private methods
   methods (Access = 'private')
       function validateAbstractProperties(this)
           
          % check memoryBuffers is of the correct type
          memoryBufferClass = 'TargetsMemory_MemoryBuffer';
          if ~isa(this.memoryBuffers, memoryBufferClass)
            TargetCommon.ProductInfo.error('targetsMemory', 'MemoryProfilerInvalidClass', class(this.memoryBuffers), memoryBufferClass);
          end
          
          % there must be one reset word for each memoryBuffer
          if length(this.memoryBuffers) ~= length(this.resetWords)
            TargetCommon.ProductInfo.error('targetsMemory', 'MemoryProfilerResetWordsIncorrectSize');
          end
       end
   end
end
