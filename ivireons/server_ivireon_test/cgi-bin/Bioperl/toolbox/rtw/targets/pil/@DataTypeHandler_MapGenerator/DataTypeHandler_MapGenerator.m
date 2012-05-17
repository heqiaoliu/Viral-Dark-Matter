%DATATYPEHANDLER_MAPGENERATOR class to generate array index mappings to reorder bytes
%   DATATYPEHANDLER_MAPGENERATOR class to generate array index mappings to
%   reorder bytes. Takes two machine objects representing the HOST and TARGET

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 19:11:37 $

classdef DataTypeHandler_MapGenerator < handle
  
  properties(SetAccess = 'public', GetAccess = 'protected')
    host;
    target;
  end

  properties(SetAccess = 'protected', GetAccess = 'protected')
    swapByteOrder = false;
  end
  
  methods(Access = 'public')

    function this = DataTypeHandler_MapGenerator(host, target)
      this.host = host;
      this.target = target;
      this.needToSwapByteOrder();
    end
  end
  
  methods

    function this = set.host(this, host)
      if isa(host, 'TargetsComms_Machine')
        this.host = host;
      else
        error('DataTypeHandler_MapGenerator:Property:host', 'Host must be an object of or an object of a subclass of TargetsComms_Machine');
      end
    end

    function this = set.target(this, target)
      if isa(target, 'TargetsComms_Machine')
        this.target = target;
      else
        error('DataTypeHandler_MapGenerator:Property:target', 'Target must be an object of or an object of a subclass of TargetsComms_Machine');
      end
    end
  end
  
   methods(Access = 'public')

    function map = getMap(this, size, wordOrder)
      % code to generate the map
      dataTypeBits = size * 8;
      numWords = this.getNumWords(dataTypeBits);
      swapWordOrder = this.needToSwapWordOrder(wordOrder);
      % calculate the number of bytes in a word
      wordLenBytes = size / numWords;
      map = this.genMap(swapWordOrder, this.swapByteOrder, size, numWords, wordLenBytes);
    end

  end  
  
  methods(Access = 'protected')

    function needToSwapByteOrder(this)
      %       % determine if we need to swap the byte order of the datatype
      %       needToSwap = false;
      %       switch byteOrder
      %         case 'BigEndian'
      %           % different to host byte order
      %           needToSwap = true;
      %         case 'LittleEndian'
      %           % same as host byte order
      %           needToSwap = false;
      %         case 'Unspecified'
      %           % 8-bit word size need not specify byte order
      %           needToSwap = false;
      %         otherwise
      %           error(['Unknown byte order: ' byteOrder]);
      %       end
      if this.target.isByteAddressable
        if ~(strcmp(this.host.byteOrder, this.target.byteOrder))
          % host and target are different
          this.swapByteOrder = true;
        elseif strcmp(this.host.byteOrder, this.target.byteOrder)
          % host and target are the same
          this.swapByteOrder = false;
        end
      else
        this.swapByteOrder = false;
      end
    end
    
    % This is only important when the datatype is bigger that 1 word
    % Still need to fix this host and tgt side could be different for now
    % we assume that on the host word order is == to byte order
    function swapWordOrder = needToSwapWordOrder(this, wordOrder)
      %       swapWordOrder = false;
      %       switch wordOrder
      %         case 'BigEndian'
      %           % different to host word order
      %           swapWordOrder = true;
      %         case 'LittleEndian'
      %           % same as host word order
      %           swapWordOrder = false;
      %         otherwise
      %           error(['Unknown word order: ' wordOrder]);
      %       end
      swapWordOrder = false;
      if ~(strcmp(this.host.byteOrder, wordOrder))
        % host and target are different
        swapWordOrder = true;
      elseif strcmp(this.host.byteOrder, wordOrder)
        % host and target are the same
        swapWordOrder = false;
      end
    end

    function numWords = getNumWords(this, dataTypeBits)
      if dataTypeBits > this.target.wordLength
                % make sure that datatype size is an exact multiple of the wordlength
        if mod(dataTypeBits, this.target.wordLength) ~= 0
          error('DataTypeHandler_MapGenerator:getNumWords:MultiwordDataTypeSize', ...
            ['Multi-word datatype (' dataTypeName ') size is not ' ...
            'an exact multiple of the target word size: ' num2str(this.target.wordLength)]);
        end
        % calculate the number of words in the datatype
        numWords = dataTypeBits / this.target.wordLength;
      else
        numWords = 1;
      end      
    end    
    
    function map = genMap(this, swapWordOrder, swapByteOrder, dataTypeBytes, numWords, wordLenBytes)
      % Examples:
      %
      % Original byte order definitions:
      %
      % 16-bit word, 8 datatype bytes = | 1 2 | 3 4 | 5 6 | 7 8 |
      % 32-bit word, 8 datatype bytes = | 1 2   3 4 | 5 6   7 8 |
      % 16-bit word, 6 datatype bytes = | 1 2 | 3 4 | 5 6 |
      % 32-bit word, 6 datatype bytes = | 1 2 3 4 | 5 6 X X | => ILLEGAL
      % 16-bit word, 4 datatype bytes = | 1 2 | 3 4 |
      % 32-bit word, 4 datatype bytes = | 1 2   3 4 |
      % 32-bit word, 2 datatype bytes = | 1 2 |
      %
      map = [];
      if swapWordOrder && swapByteOrder
        % We have a multi-word datatype

        % Required reordered byte order:
        %
        % 16-bit, 8 bytes => | 8 7 | 6 5 | 4 3 | 2 1 |
        % 32-bit, 8 bytes => | 8 7   6 5 | 4 3   2 1 |
        % 16-bit, 6 bytes => | 6 5 | 4 3 | 2 1 |
        % 16-bit, 4 bytes => | 4 3 | 2 1 |
        %
        map = dataTypeBytes:-1:1;
      elseif swapWordOrder
        % We have a multi-word datatype
        % datatype size is an exact multiple of the word length

        if (this.target.isByteAddressable())

          % Required reordered byte order:
          %
          % 16-bit (2 bytes), 8 bytes => | 7 8 | 5 6 | 3 4 | 1 2 |
          % 32-bit (4 bytes), 8 bytes => | 5 6   7 8 | 1 2   3 4 |
          % 16-bit (2 bytes), 6 bytes => | 5 6 | 3 4 | 1 2 |
          % 16-bit (2 bytes), 4 bytes => | 3 4 | 1 2 |
          for word=1:numWords
            for byte = 1:wordLenBytes
              map(end+1) = dataTypeBytes - (wordLenBytes * word) + byte;
            end
          end

        else

          % Required reordered word order:
          %
          % 16-bit, 8 bytes => | 4 | 3 | 2 | 1 |
          % 32-bit, 8 bytes => | 2 | 1 |
          % 16-bit, 6 bytes => | 3 | 2 | 1 |
          % 16-bit, 4 bytes => | 2 | 1 |
          map = numWords:-1:1;

        end

      elseif swapByteOrder
        % we may or may not have a multi-word datatype
        % swap the bytes within the words of the datatype

        % 16-bit word, 8 datatype bytes = | 2 1 | 4 3 | 6 5 | 8 7 |
        % 32-bit word, 8 datatype bytes = | 4 3   2 1 | 8 7   6 5 |
        % 16-bit word, 6 datatype bytes = | 2 1 | 4 3 | 6 5 |
        % 16-bit word, 4 datatype bytes = | 2 1 | 4 3 |
        % 32-bit word, 4 datatype bytes = | 4 3   2 1 |
        % 32-bit word, 2 datatype bytes = | 2 1 |

        for word=1:numWords
          for byte = 1:wordLenBytes
            map(end+1) = (wordLenBytes * word) - byte + 1;
          end
        end
      else
        if (this.target.isByteAddressable())
          map = 1:dataTypeBytes;
        else
          map = 1:numWords;
        end
      end
    end    
    
  end

  methods(Access = 'private')
    
    function map = generateDataTypeMap(this, dtSize, dtName, wordLen, wordOrder, byteOrder)

      % Original arguments
      %
      % h
      % text
      % datatypeid
      % wordLen - number of bits in a word
      % byteOrder
      % numDataElements
      
      % New arguments
      %
      % size - int
      dataTypeBytes = dtSize;
      % name - string      
      dataTypeName = dtName;
      % wordLen - int - number of bits in a word
      % wordOrder - string
      % byteOrder - string
      % text = '';
      

      % determine if we need to swap the word order of
      % the datatype (multi-word datatypes only)
      swapWordOrder = false;
      % dataTypeBytes = i_sizeof(datatypeid, h, 1);
      dataTypeBits = dataTypeBytes * 8;
      % dataTypeName = i_SimulinkTypeIdtoSimulinkType(datatypeid);

      if dataTypeBits > wordLen
        % make sure that datatype size is an exact multiple of the wordlength
        if mod(dataTypeBits, wordLen) ~= 0
          error('DataTypeHandler_MapGenerator:generateDataTypeMap:MultiwordDataTypeSize', ...
            ['Multi-word datatype (' dataTypeName ') size is not ' ...
            'an exact multiple of the target word size: ' num2str(wordLen)]);
        end
        % calculate the number of words in the datatype
        numWords = dataTypeBits / wordLen;
        % obtain the word order
        % wordOrder = h.a_getDatatypeWordOrder(dataTypeName, byteOrder);
        switch wordOrder
          case 'BigEndian'
            % different to host word order
            swapWordOrder = true;
          case 'LittleEndian'
            % same as host word order
            swapWordOrder = false;
          otherwise
            error('DataTypeHandler_MapGenerator:generateDataTypeMap:WordOrderUnknown', ...
              ['Unknown word order: ' wordOrder]);
        end
      else
        % datatype fits in a single word
        numWords = 1;
      end

      % calculate the number of bytes in a word
      wordLenBytes = dataTypeBytes / numWords;

      % determine if we need to swap the byte order of the datatype
      swapByteOrder = false;
      switch byteOrder
        case 'BigEndian'
          % different to host byte order
          swapByteOrder = true;
        case 'LittleEndian'
          % same as host byte order
          swapByteOrder = false;
        case 'Unspecified'
          % 8-bit word size need not specify byte order
          swapByteOrder = false;
        otherwise
          error('DataTypeHandler_MapGenerator:generateDataTypeMap:ByteOrderUnknown', ...
            ['Unknown byte order: ' byteOrder]);
      end

      % indicate reordering is required
      reorder = true;
      %
      % Examples:
      %
      % Original byte order definitions:
      %
      % 16-bit word, 8 datatype bytes = | 1 2 | 3 4 | 5 6 | 7 8 |
      % 32-bit word, 8 datatype bytes = | 1 2   3 4 | 5 6   7 8 |
      % 16-bit word, 6 datatype bytes = | 1 2 | 3 4 | 5 6 |
      % 32-bit word, 6 datatype bytes = | 1 2 3 4 | 5 6 X X | => ILLEGAL
      % 16-bit word, 4 datatype bytes = | 1 2 | 3 4 |
      % 32-bit word, 4 datatype bytes = | 1 2   3 4 |
      % 32-bit word, 2 datatype bytes = | 1 2 |
      %
      map = [];
      if swapWordOrder && swapByteOrder
        % We have a multi-word datatype

        % Required reordered byte order:
        %
        % 16-bit, 8 bytes => | 8 7 | 6 5 | 4 3 | 2 1 |
        % 32-bit, 8 bytes => | 8 7   6 5 | 4 3   2 1 |
        % 16-bit, 6 bytes => | 6 5 | 4 3 | 2 1 |
        % 16-bit, 4 bytes => | 4 3 | 2 1 |
        %
        map = dataTypeBytes:-1:1;
%        text{end+1} = ['   % swap word order and swap byte order (' dataTypeName ')'];
      elseif swapWordOrder
        % We have a multi-word datatype
        % datatype size is an exact multiple of the word length

        % Required reordered byte order:
        %
        % 16-bit (2 bytes), 8 bytes => | 7 8 | 5 6 | 3 4 | 1 2 |
        % 32-bit (4 bytes), 8 bytes => | 5 6   7 8 | 1 2   3 4 |
        % 16-bit (2 bytes), 6 bytes => | 5 6 | 3 4 | 1 2 |
        % 16-bit (2 bytes), 4 bytes => | 3 4 | 1 2 |

        for word=1:numWords
          for byte = 1:wordLenBytes
            map(end+1) = dataTypeBytes - (wordLenBytes * word) + byte;
          end
        end
%         text{end+1} = ['   % swap word order (' dataTypeName ')'];
      elseif swapByteOrder
        % we may or may not have a multi-word datatype
        % swap the bytes within the words of the datatype

        % 16-bit word, 8 datatype bytes = | 2 1 | 4 3 | 6 5 | 8 7 |
        % 32-bit word, 8 datatype bytes = | 4 3   2 1 | 8 7   6 5 |
        % 16-bit word, 6 datatype bytes = | 2 1 | 4 3 | 6 5 |
        % 16-bit word, 4 datatype bytes = | 2 1 | 4 3 |
        % 32-bit word, 4 datatype bytes = | 4 3   2 1 |
        % 32-bit word, 2 datatype bytes = | 2 1 |

        for word=1:numWords
          for byte = 1:wordLenBytes
            map(end+1) = (wordLenBytes * word) - byte + 1;
          end
        end
%       text{end+1} = ['   % swap byte order (' dataTypeName ')'];
      else
        % no reordering required
        reorder = false;
      end

%       if reorder
%         % expand the map according to the number of data elements
%         text{end+1} = ['   map = [' num2str(map) '];'];
%         text{end+1} =  '   indices = [];';
%         text{end+1} = ['   for i=0:' num2str(numDataElements - 1)];
%         text{end+1} = ['      indices = [indices (map + (i * ' num2str(dataTypeBytes) '))];'];
%         text{end+1} =  '   end';
%       end      
    end    
    
  end
  
end
