classdef detector < crc.basecrc
% DETECTOR Construct a CRC detector object.
%   H = CRC.DETECTOR(POLYNOMIAL) constructs a CRC detector object H defined by
%   the generator polynomial POLYNOMIAL.  See below for a description of the
%   POLYNOMIAL property.
%
%   H = CRC.DETECTOR(PROPERTY1, VALUE1, ...) constructs a CRC detector object
%   H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = CRC.DETECTOR(GENERATOROBJ) constructs a CRC detector object H defined
%   by the parameters found in the CRC generator object GENERATOROBJ.
%
%   A CRC detector object has the following properties.  All the properties are
%   writable.
%
%   Property Name      Description
%   ----------------------------------------------------------------------------
%   Type             - 'CRC Detector'.  This property is not writable.
%   Polynomial       - The generator polynomial that defines connections for a
%                      linear feedback shift register.  This property can be
%                      specified as a binary vector representing descending
%                      powers of the polynomial.  In this case, the leading '1'
%                      of the polynomial must be included.  It can also be
%                      specified as a string, prefaced by '0x', that is a
%                      hexadecimal representation of the descending powers of
%                      the polynomial. In this case, the leading '1' of the
%                      polynomial is omitted.
%   InitialState     - The initial contents of the shift register.  This
%                      property can be specified as a scalar, a binary vector or
%                      as a string, prefaced by '0x', that is a hexadecimal
%                      representation of the binary vector.  As a binary vector,
%                      its length must be one less than the length of the binary
%                      vector representation of the Polynomial.
%   ReflectInput     - A Boolean quantity that specifies whether the input data
%                      should be flipped on a bytewise basis prior to entering
%                      the shift register.
%   ReflectRemainder - A Boolean quantity that specifies whether the binary
%                      output CRC checksum should be flipped around its center
%                      after the input data is completely through the shift
%                      register.
%   FinalXOR         - The value with which the CRC checksum is to be XORed just
%                      prior to being appended to the input data.  This property
%                      can be specified as a scalar, a binary vector or as a
%                      string, prefaced by '0x', that is a hexadecimal
%                      representation of the binary vector.  As a binary vector,
%                      its length must be one less than the length of the binary
%                      vector representation of the Polynomial.
%
%   H = CRC.DETECTOR constructs a CRC detector object H with default properties.
%   It constructs a CRC-CCITT detector, and is equivalent to:
%   H = CRC.DETECTOR('Polynomial', '0x1021', 'InitialState', '0xFFFF', ...
%                    'ReflectInput', false, 'ReflectRemainder', false, ...
%                    'FinalXOR', '0x0000').
%
%   crc.detector methods:
%     detect - Determine if transmission errors have occurred by using a CRC
%              checksum
%     disp   - Display a CRC detector object
%
%   To get detailed help on a method from the command line, type 'help
%   crc.detector/<METHOD>', where METHOD is on of the methods listed above.
%   For instance, 'help crc.detector/detect'.
%
%   Examples:
%
%     % Construct a CRC detector with a polynomial defined by x^4+x^3+x^2+x+1:
%     h = crc.detector([1 1 1 1 1])
%
%     % Construct a CRC detector with a polynomial defined by x^3+x+1, with
%     % zero initial states, and with an all-ones final XOR value:
%     h = crc.detector('Polynomial', [1 0 1 1], 'InitialState', [0 0 0], ...
%                      'FinalXOR', [1 1 1])
%
%     % Construct a CRC detector with a polynomial defined by x^4+x^3+x^2+x+1,
%     % all-ones initial states, reflected input, and all-zeros final XOR value:
%     h = crc.detector('Polynomial', '0xF', 'InitialState', '0xF', ...
%                      'ReflectInput', true, 'FinalXOR', '0x0')
%
%     See also CRC, CRC.DETECTOR/DETECT, CRC.DETECTOR/DISP, CRC.GENERATOR.
    
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2009/05/23 07:48:30 $

%------------------------------------------------------------------------------
    methods
        
        % Constructor
        function crcObj = detector(varargin)

            crcObj = crcObj@crc.basecrc(varargin{:});
            crcObj.Type = 'CRC Detector';

        end

 %-----------------------------------------------------------------------------       
        % Detect method
        function [outData error] = detect(crcObj, inData)
% DETECT Detect transmission errors using a CRC checksum.
%    [OUTDATA ERROR] = DETECT(H, INDATA) detects transmission errors in the
%    encoded input message INDATA by regenerating a CRC checksum using the CRC
%    detector object H.  It then compares the regenerated checksum with the
%    checksum appended to INDATA.  The binary-valued INDATA can be either a
%    column vector or a matrix.  If it is a matrix, then each column is
%    considered to be a separate channel.
%
%    OUTDATA is identical to the input message INDATA, except that it has the
%    CRC checksum stripped off.  ERROR is a 1xC logical vector indicating if the
%    encoded message INDATA has errors, where C is the number of channels in
%    INDATA.  An ERROR value of 0 indicates no errors, and a value of 1
%    indicates errors.
%
%    Example:
%
%    % Create a CRC-16 CRC generator, then use it to generate a checksum for the
%    % binary vector represented by the ASCII sequence '123456789'.  Introduce
%    % an error, then detect it using a CRC-16 CRC detector.
%    gen = crc.generator('Polynomial', '0x8005', 'ReflectInput', true, ...
%                        'ReflectRemainder', true);
%    det = crc.detector('Polynomial', '0x8005', 'ReflectInput', true, ...
%                       'ReflectRemainder', true);
%    % The message below is an ASCII representation of the digits 1-9
%    msg = reshape(de2bi(49:57, 8, 'left-msb')', 72, 1);
%    encoded = generate(gen, msg);
%    encoded(1) = ~encoded(1);                % Introduce an error
%    [outdata error] = detect(det, encoded);  % Detect the error
%    noErrors = isequal(msg, outdata)         % Should be 0
%    error                                    % Should be 1
%
%    See also CRC.DETECTOR, CRC.DETECTOR/DISP.
            
            % Get the length of the polynomial
            poly = crcObj.Polynomial(2:end)';
            polyLen = length(poly);
            
            % Call the baseclass generate function on the original data, then
            % compare its output with the checksum.
            outData = inData(1:end-polyLen,:);
            encData = baseGenerate(crcObj, outData);

            % Determine if an error has occurred
            error = any( encData(end-polyLen+1:end,:) ~= ...
                         inData(end-polyLen+1:end,:),   1);

        end  % function

    end  % methods

end  % classdef

% [EOF]