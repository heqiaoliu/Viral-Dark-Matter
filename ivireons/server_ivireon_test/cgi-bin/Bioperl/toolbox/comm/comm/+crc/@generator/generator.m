classdef generator < crc.basecrc
% GENERATOR Construct a CRC generator object.
%   H = CRC.GENERATOR(POLYNOMIAL) constructs a CRC generator object H defined by
%   the generator polynomial POLYNOMIAL.  See below for a description of the
%   POLYNOMIAL property.
%
%   H = CRC.GENERATOR(PROPERTY1, VALUE1, ...) constructs a CRC generator object
%   H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = CRC.GENERATOR(DETECTOROBJ) constructs a CRC generator object H defined
%   by the parameters found in the CRC detector object DETECTOROBJ.
%
%   A CRC generator object has the following properties.  All the properties are
%   writable unless explicitly stated otherwise.
%
%   Property Name      Description
%   ----------------------------------------------------------------------------
%   Type             - 'CRC Generator'.  This property is not writable.
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
%   H = CRC.GENERATOR constructs a CRC generator object H with default
%   properties.  It constructs a CRC-CCITT generator, and is equivalent to:
%   H = CRC.GENERATOR('Polynomial', '0x1021', 'InitialState', '0xFFFF', ...
%                     'ReflectInput', false, 'ReflectRemainder', false, ...
%                     'FinalXOR', '0x0000').
%
%   crc.generator methods:
%     generate - Generate a CRC checksum and append it to the input data
%     disp     - Display a CRC generator object
%
%   To get detailed help on a method from the command line, type 'help
%   crc.generator/<METHOD>', where METHOD is on of the methods listed above.
%   For instance, 'help crc.generator/generate'.
%
%   Examples:
%
%     % Construct a CRC generator with a polynomial defined by x^4+x^3+x^2+x+1:
%     h = crc.generator([1 1 1 1 1])
%
%     % Construct a CRC generator with a polynomial defined by x^3+x+1, with
%     % zero initial states, and with an all-ones final XOR value:
%     h = crc.generator('Polynomial', [1 0 1 1], 'InitialState', [0 0 0], ...
%                       'FinalXOR', [1 1 1])
%
%     % Construct a CRC generator with a polynomial defined by x^4+x^3+x^2+x+1,
%     % all-ones initial states, reflected input, and all-zeros final XOR value:
%     h = crc.generator('Polynomial', '0xF', 'InitialState', '0xF', ...
%                       'ReflectInput', true, 'FinalXOR', '0x0')
%
%     See also CRC, CRC.GENERATOR/GENERATE, CRC.GENERATOR/DISP, CRC.DETECTOR.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2009/05/23 07:48:31 $    

%------------------------------------------------------------------------------
    methods

        % Constructor
        function crcObj = generator(varargin)
            
            crcObj = crcObj@crc.basecrc(varargin{:});
            crcObj.Type = 'CRC Generator';

        end

%------------------------------------------------------------------------------
        % Generate
        function encData = generate(crcObj, msg)
% GENERATE Generate a CRC checksum and append it to the input data.
%    ENCODED = GENERATE(H, MSG) generates a CRC checksum for an input message
%    using the CRC generator object H.  It appends the checksum to the end of
%    MSG.  The binary-valued MSG can be either a column vector or a matrix.  If
%    it is a matrix, then each column is considered to be a separate channel.
%
%    Example:
%
%    % Create a CRC-16 CRC generator, then use it to generate a checksum for the
%    % binary vector represented by the ASCII sequence '123456789'.
%    gen = crc.generator('Polynomial', '0x8005', 'ReflectInput', true, ...
%                        'ReflectRemainder', true);
%    % The message below is an ASCII representation of the digits 1-9
%    msg = reshape(de2bi(49:57, 8, 'left-msb')', 72, 1);
%    encoded = generate(gen, msg);
%
%    See also CRC.GENERATOR, CRC.GENERATOR/DISP. 

            % Call the baseGenerate method in the basecrc class.  
            encData = baseGenerate(crcObj, msg);

        end  % function

    end  % methods

end  % classdef

% [EOF]