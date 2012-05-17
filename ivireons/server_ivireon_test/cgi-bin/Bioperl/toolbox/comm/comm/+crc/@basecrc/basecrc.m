classdef basecrc
% BASECRC Baseclass for CRC generators and detectors.

% Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.6.8 $  $Date: 2010/01/25 21:28:20 $

    properties (SetAccess = 'protected')
        Type             = 'CRC Generator';
    end
    properties  % public
        % CRC-CCITT properties
        Polynomial       = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
        InitialState     = ones(1,16);
        ReflectInput     = false;
        ReflectRemainder = false;
        FinalXOR         = zeros(1,16);
    end

%===============================================================================
    % Public methods
    methods (Access = public)

        % Constructor
        function crcObj = basecrc(varargin)

            switch nargin
                case 0
                    % Use the default constructor

                case 1
                    % Use the numeric polynomial argument
                    if isnumeric(varargin{1})
                        crcObj.Polynomial   = varargin{1};
                        
                    % Use the string polynomial argument
                    elseif ischar(varargin{1})
                        % Convert the string poly to binary.  Prepend zeros if
                        % necessary.
                        polynomial = convertHexToBinary(varargin{1});
                        crcObj.Polynomial   = [1 polynomial];  % Add leading '1'

                    elseif isa(varargin{1}, 'crc.basecrc')
                        % Use a source object to copy properties to a
                        % destination object                        
                        srcObj = varargin{1};
                        crcObj.Polynomial       = srcObj.Polynomial;
                        crcObj.InitialState     = srcObj.InitialState;
                        crcObj.ReflectInput     = srcObj.ReflectInput;
                        crcObj.ReflectRemainder = srcObj.ReflectRemainder;
                        crcObj.FinalXOR         = srcObj.FinalXOR;
                    end

                otherwise

                    % P/V pairs
                    % Process the polynomial first, since other properties are
                    % dependent on it.
                    for idx = 1 : 2 : nargin
                         param = varargin{idx};
                        % Process params to allow for less user typing                         
                         if findstr('poly', lower(param))
                            crcObj.Polynomial = varargin{idx+1};
                        end
                    end
                    
                    for idx = 1 : 2 : nargin
                        param = varargin{idx};
                        
                        % Process params to allow for less user typing
                        if findstr('poly', lower(param))
                            % Do nothing - already processed
                        elseif findstr('init', lower(param))
                            param = 'init';
                        elseif findstr('reflecti', lower(param))
                            param = 'reflecti';
                        elseif findstr('reflectr', lower(param))
                            param = 'reflectr';
                        elseif findstr('final', lower(param))
                            param = 'final';
                        else
                            error('comm:crc:invalidProperty', ...
                                'Invalid property passed in.');
                        end
                        
                        switch param
                            case 'init'
                                crcObj.InitialState = varargin{idx+1};
                            case 'reflecti'
                                crcObj.ReflectInput = varargin{idx+1};
                            case 'reflectr'
                                crcObj.ReflectRemainder = varargin{idx+1};
                            case 'final'
                                crcObj.FinalXOR = varargin{idx+1};
                        end
                    end

            end  % switch

        end  % function crcObj = basecrc(varargin)

%-------------------------------------------------------------------------------        
        function disp(crcObj)
% DISP  Display properties of a CRC object.
%   DISP(H) displays relevant properties of the CRC object H.  A CRC object can
%   be either a generator or a detector.
%
%   Example 1:
%     hGen = crc.generator;  % Create a generator object with default properties
%     disp(hGen);  % Display object properties
%
%   Example 2:
%     hDet = crc.detector([1 0 1 1]);  % Create a nondefault detector object
%     disp(hDet);  % display object properties
%
%
%   See also CRC.GENERATOR, CRC.GENERATOR/GENERATE, CRC.DETECTOR,
%   CRC.DETECTOR/DETECT.

        %If displaying a single object use custom display. If trying
        %to display a vector of objects, then use builtin display
        %function.
        if isscalar(crcObj)
            % Format Type
            dispType = crcObj.Type;
            
            % Format Polynomial
            polyLen = length(crcObj.Polynomial)-1;  % omit leading '1'
            polyLenDiv4 = polyLen/4;
            if ( polyLenDiv4 == floor(polyLenDiv4) )
                % The displayed value will be hex
                dispPolynomial = convertBinaryToHex(crcObj.Polynomial(2:end));
            else
                % The displayed value will be numeric, since a hex value
                % would imply zeros in the polynomial that don't exist
                dispPolynomial = mat2str(crcObj.Polynomial);
            end
            
            % Format InitialState
            dispInitialState = ...
                formatLengthDependentOutput(crcObj.InitialState, ...
                dispPolynomial);
            
            % Format ReflectInput
            dispReflectInput = formatLogical(crcObj.ReflectInput);
            
            % Format ReflectRemainder
            dispReflectRemainder = formatLogical(crcObj.ReflectRemainder);
            
            % Format FinalXOR
            dispFinalXOR = ...
                formatLengthDependentOutput(crcObj.FinalXOR, dispPolynomial);
            
            fprintf(1,['                Type: %s\n' ...
                '          Polynomial: %s\n' ...
                '        InitialState: %s\n' ...
                '        ReflectInput: %s\n' ...
                '    ReflectRemainder: %s\n' ...
                '            FinalXOR: %s\n'], ...
                dispType, dispPolynomial, ...
                dispInitialState, dispReflectInput, ...
                dispReflectRemainder, dispFinalXOR);
        else
            builtin('disp', crcObj);
        end
        end % disp(crcObj)

    end  % public methods
    
%===============================================================================
    % Protected methods
    methods (Access = protected)
        function encData = baseGenerate(crcObj, msg)

            % Ensure that the data is binary-valued
            if any(any(~(msg==0 | msg==1)))
                error('comm:crc:invalidMsg', ...
                    'The input message must have binary (0 or 1) values.');
            end

            % Discard the leading '1' of the poly and convert to a column vector
            poly = crcObj.Polynomial(2:end)';
            polyLen = length(poly);

            % Reflect input data if appropriate
            regInput = msg;
            if crcObj.ReflectInput
                regInput = reflectData(regInput);
            end

            % Augment message with zeros
            nChan = size(msg,2);
            regInput = [regInput; zeros(polyLen,nChan)];
            regInputLen = size(regInput,1);

            % Initialize shift register, convert to a column vector, and repeat
            % for all channels
            reg = repmat(crcObj.InitialState', 1, nChan);
            
            % If the truncated polynomial length is 32 bits or less, call a C
            % mex function to accelerate the CRC calculation.  The 32-bit
            % limitation is because the C mex function uses bitops on uint32
            % integers.
            if polyLen <= 32

                % The mex function requires the register contents and the
                % polynomial to be packed into integers, so format the register
                % and the polynomial first.
                reg = bi2de(reg', 'left-msb');
                poly = bi2de(poly', 'left-msb');
                reg = crccore(uint32(regInput), ...
                              uint32(regInputLen), ...
                              uint32(nChan), ...
                              uint32(poly), ...
                              uint32(reg), ...
                              uint32(polyLen));

                % Convert the register contents from integers to binary column
                % vectors
                reg = de2bi(reg, polyLen, 'left-msb')';

            else  % Use MATLAB code, which has no limitation on register length

                for i = 1 : regInputLen
                    % Shift the register contents and add the next message bit
                    % to the end of the register
                    output = reg(1,:);
                    reg(1:end-1, :) = reg(2:end, :);
                    reg(end,:) = regInput(i,:);

                    for iChan = 1 : nChan
                        if output(iChan)
                            reg(:,iChan) = xor(reg(:,iChan), poly);
                        end
                    end

                end

            end  % if regInputLen <= 32

            % Reflect the remainder (i.e. the register contents) if appropriate
            if crcObj.ReflectRemainder
                reg = flipud(double(reg));
            end

            % Perform the final XOR operation
            reg = xor( reg, repmat(crcObj.FinalXOR',1,nChan) );

            % Add checksum to data
            encData = [msg; reg];

        end  % function baseGenerate(crcObj, msg)
        
    end  % protected methods    
    
%===============================================================================
    % Property set methods
    methods
        function obj = set.Polynomial(obj, polynomial)
            if ischar(polynomial)
                % Check for valid hex string                
                checkHexString(polynomial, 'Polynomial');
                
                % Convert the string poly to binary.  Prepend zeros if
                % necessary.
                polynomial = convertHexToBinary(polynomial);
                polynomial = [1 polynomial];  % Add leading '1'

            elseif isnumeric(polynomial)
                % Check for valid binary vector                
                if polynomial(1)~=1
                    error('comm:crc:invalidPoly', ...
                        ['The first element of a numeric vector Polynomial ' ...
                         'property must be 1.']);
                end
                
                checkBinaryVector(polynomial, 'Polynomial')

            else
                error('comm:crc:invalidPoly', ...
                      'Unknown Polynomial type passed in.');
            end

            obj.Polynomial = polynomial;
            
            % If the length of the polynomial now differs from the lengths of
            % the InitialState and FinalXOR properties, then reset InitialState
            % and FinalXOR to all-zero vectors of the proper length.
            polyLenLess1 = length(polynomial) - 1;
            if ( polyLenLess1~=length(obj.InitialState) || ...
                 polyLenLess1~=length(obj.FinalXOR) )
                [obj.InitialState obj.FinalXOR] = deal(zeros(1,polyLenLess1));
            end
            
        end  % set.Polynomial

%-------------------------------------------------------------------------------        
        function obj = set.InitialState(obj, initialState)
            if ischar(initialState)
                % Check for valid hex string                
                checkHexString(initialState, 'InitialState');
                
                checkHexStringAgainstPoly(initialState(3:end), ...
                                          obj.Polynomial, 'InitialState');
                
                % Convert the string initial state to binary
                initialState = convertHexToBinary(initialState);

            elseif isnumeric(initialState)
                % Perform scalar expansion if needed
                if isscalar(initialState)
                    initialState = expandScalar(initialState, ...
                                                length(obj.Polynomial));
                end
                
                % Check for valid binary vector                
                checkBinaryVector(initialState, 'InitialState');
                
                checkBinaryVectorAgainstPoly(initialState, obj.Polynomial, ...
                                             'InitialState');
                
            else
                error('comm:crc:invalidInitialState', ...
                      'Unknown InitialState type passed in.');
            end
            
            % Check binary vector against polynomial


            obj.InitialState = initialState;
        end  % set.InitialState

%-------------------------------------------------------------------------------        
        function obj = set.ReflectInput(obj, reflectInput)
            checkLogicalScalar(reflectInput, 'ReflectInput');
            obj.ReflectInput = reflectInput;
        end 

%-------------------------------------------------------------------------------        
        function obj = set.ReflectRemainder(obj, reflectRemainder)          
            checkLogicalScalar(reflectRemainder, 'ReflectRemainder');
            obj.ReflectRemainder = reflectRemainder;
        end

%-------------------------------------------------------------------------------        
        function obj = set.FinalXOR(obj, finalXOR)
            if ischar(finalXOR) 
                % Check for valid hex string                
                checkHexString(finalXOR, 'FinalXOR');
                
                checkHexStringAgainstPoly(finalXOR(3:end), obj.Polynomial, ...
                                          'FinalXOR');                
                
                % Convert the string initial state to binary
                finalXOR = convertHexToBinary(finalXOR);

            elseif isnumeric(finalXOR)
                % Perform scalar expansion if needed
                if isscalar(finalXOR)
                    finalXOR = expandScalar(finalXOR, ...
                                            length(obj.Polynomial));
                end
                
                % Check for valid binary vector                
                checkBinaryVector(finalXOR, 'FinalXOR');
                
                checkBinaryVectorAgainstPoly(finalXOR, obj.Polynomial, ...
                                             'FinalXOR');

            else
                error('comm:crc:invalidFinalXOR', ...
                      'Unknown FinalXOR type passed in.');
            end

            obj.FinalXOR = finalXOR;
        end  % set.FinalXOR

    end % private methods

end  % classdef

%-------------------------------------------------------------------------
% Subfunctions
%-------------------------------------------------------------------------------
function checkHexString(hexString, string)
% CHECKHEXSTRING  Check that the hex string starts with '0x' and includes only
% valid hex characters.

if ( length(hexString)<3 || ~(hexString(1)=='0' && hexString(2)=='x') )
    error('comm:crc:invalidHexString', ...
          ['A hex string that specifies the %s property must begin with ' ...
          '''0x''.'], string);
end

validChars = '0123456789abcdefABCDEF';
if any(~ismember(hexString(3:end), validChars))
    error('comm:crc:invalidHexString', ...
        ['The body of a hex string that specifies the %s property must use ' ...
        'the characters ''0123456789abcdefABCDEF'' only.'], string);
end

end

%-------------------------------------------------------------------------------
function checkHexStringAgainstPoly(hexString, polynomial, string)
% CHECKHEXSTRINGAGAINSTPOLY  Check the length of a hex string against the
% length of its associated Polynomial vector.

if size(hexString,2) ~= (size(polynomial,2)-1) / 4;
    error('comm:crc:invalidHexString', ...
        ['A hex %s property must have the same length as the ' ...
         'hex form of the Polynomial property.'], string);
end

end

%-------------------------------------------------------------------------------
function binaryVector = convertHexToBinary(hexString)
% CONVERTHEXTOBINARY  Convert a hex string to a binary vector.

hexString    = hexString(3:end);  % Remove '0x'
lenHexString = length(hexString);
binaryVector = zeros(1,4*lenHexString);  % Preallocate

% Convert to binary by one hex symbol at a time, to avoid dynamic range problems
% with very long hex strings
for idx = 1 : lenHexString
    binaryVector( 4*(idx-1)+1 : 4*idx ) = ...
        de2bi(hex2dec(hexString(idx)), 4, 'left-msb');
end

end

%-------------------------------------------------------------------------------
function hexString = convertBinaryToHex(binaryVector)
% CONVERTBINARYTOHEX  Convert a binary vector to a hex string.  It is assumed
% that the length of the binary vector is a multiple of 4.

lenBinaryVector = length(binaryVector);
lenHexString    = lenBinaryVector/4;
hexString       = char(zeros(1,lenHexString));  % Preallocate

% Convert to hex by four binary elements at a time, to avoid dynamic range
% problems with very long binary vectors
for idx = 1 : lenHexString
    hexString(idx) = ...
        dec2hex(bi2de(binaryVector( 4*(idx-1)+1 : 4*idx ), 'left-msb' ) );
end

hexString = ['0x' hexString];

end
%-------------------------------------------------------------------------------
function checkBinaryVector(binVector, string)
% CHECKBINARYVECTOR  Ensure that a vector has only binary (0 or 1) values, and
% that it is a row vector.

if any(~(binVector==0 | binVector==1))
    error('comm:crc:invalidBinaryVector', ...
          ['A numeric vector that specifies the %s property must ' ...
           'have binary (0 or 1) values.'], string);
end
if (size(binVector,1)>1 || size(binVector,2)==1)
    error('comm:crc:invalidBinaryVector', ...
          'A numeric, nonscalar %s property must be a row vector.', string);
end

end

%-------------------------------------------------------------------------------
function checkBinaryVectorAgainstPoly(binVector, polynomial, string)
% CHECKBINARYVECTORAGAINSTPOLY  Check the length of a binary vector against the
% length of its associated Polynomial vector.

if size(binVector,2) ~= size(polynomial,2)-1
    error('comm:crc:invalidBinaryVector', ...
        ['A numeric, nonscalar %s property must have ' ...
         'a length that is one less than the length of the numeric form of ' ...
         'the Polynomial property.'], string);
end

end

%-------------------------------------------------------------------------------
function checkLogicalScalar(input, string)

if ~( islogical(input) && isscalar(input) )
    error('comm:crc:invalidLogicalScalar', ...
          'The %s property must be a logical scalar.', string);
end

end

%-------------------------------------------------------------------------------
function dispOut = formatLengthDependentOutput(input, dispPolynomial)
% FORMATLENGTHDEPENDENTOUTPUT  Format either an output hex string or an output
% numeric vector for display.

inputLen = length(input);
if ( inputLen/4 == floor(inputLen/4) )
    % The displayed value will be hex
    dispOut = convertBinaryToHex(input);

    if strcmpi(dispOut, '0x0')
        dispOut = expandHexZero(dispPolynomial);
    end
else
    % The displayed value will be numeric, since a hex value
    % would imply zeros that don't exist
    dispOut = mat2str(input);
end

end

%-------------------------------------------------------------------------------
function expanded = expandScalar(scalar, lenPoly)

expanded = repmat(scalar, 1, lenPoly-1);

end

%-------------------------------------------------------------------------------
function expanded = expandHexZero(dispPolynomial)
% EXPANDHEXZERO  If a displayed string is '0x0', expand it to the proper length,
% which is dependent on the length of the Polynomial.

expanded = '';
for idx = 1 : length(dispPolynomial)-2
    expanded = [expanded '0'];  %#ok
end
expanded = ['0x' expanded];

end

%-------------------------------------------------------------------------------
function formatted = formatLogical(numericVal)

if numericVal==0
    formatted = 'false';
else
    formatted = 'true';
end

end

%-------------------------------------------------------------------------------
function reflected = reflectData(input)
% REFLECTDATA  Reflect input data bytewise around the center of the byte.

[lenInput nChan] = size(input);
if (floor(lenInput/8) ~= lenInput/8)
    error('comm:crc:cannotReflectData', ...
      'To implement reflected data, the input length must be a multiple of 8.');
end

reflected = zeros(lenInput, nChan);
for iChan = 1 : nChan
    temp = flipud(reshape(input(:,iChan), 8, lenInput/8));
    reflected(:,iChan) = temp(:);
end

end

% [EOF]