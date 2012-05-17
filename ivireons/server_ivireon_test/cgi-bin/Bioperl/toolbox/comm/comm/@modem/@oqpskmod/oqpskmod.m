function h = oqpskmod(varargin)
%OQPSKMOD  OQPSK Modulator
%   H = MODEM.OQPSKMOD(PROPERTY1, VALUE1, ...) constructs an OQPSK modulator
%   object H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.OQPSKMOD(OQPSKDEMOD_OBJECT) constructs an OQPSK modulator object H
%   by reading the property values from the OQPSK demodulator object
%   OQPSKDEMOD_OBJECT. The properties that are unique to the OQPSK modulator
%   object are set to default values.
%
%   H = MODEM.OQPSKMOD(OQPSKDEMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs an
%   OQPSK modulator object H by reading the property values from the OQPSK
%   modulator object OQPSKDEMOD_OBJECT. Additional properties are specified
%   using PROPERTY/VALUE pairs.
%
%   An OQPSK modulator object has the following properties. All the properties
%   are writable except for the ones explicitly noted otherwise.
%
%   Type          - Type of modulation object ('OQPSK Modulator'). This
%                   property is not writable.
%   M             - M-ary value is constant and set to four.  This property is
%                   not writable.
%   PhaseOffset   - Phase offset of ideal signal constellation in radians.
%   Constellation - Ideal signal constellation. This property is not
%                   writable and is automatically computed based on M and
%                   PhaseOffset properties.
%   SymbolOrder   - Type of mapping employed for mapping symbols to ideal
%                   constellation points. The choices are:
%                   'binary'        - for Binary mapping
%                   'gray'          - for Gray mapping
%                   'user-defined'  - for custom mapping
%   SymbolMapping - A list of integer values from 0 to M-1 that correspond to
%                   ideal constellation points. This property is writable only
%                   when SymbolOrder is set to 'user-defined'; otherwise it is
%                   automatically computed. 
%   InputType     - Type of input to be processed by PSK modulator
%                   object. The choices are:
%                   'bit'           - for bit/binary input
%                   'integer'       - for integer/symbol input
%
%   H = MODEM.OQPSKMOD constructs an OQPSK modulator object H with default
%   properties. It constructs a modulator object that is equivalent to:
%   H = MODEM.OQPSKMOD('PHASEOFFSET', 0, 'SYMBOLORDER', 'BINARY', ...
%           'INPUTTYPE', 'INTEGER')
%
%   An OQPSK modulator object is equipped with four functions for inspection,
%   management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - MODULATE (type "help modem/modulate" for detailed help)
%     - RESET (type "help modem/reset" for detailed help)
%
%   EXAMPLES:
%
%     % Construct a modulator object for OQPSK modulation with default
%     % constellation .
%     h = modem.oqpskmod
%
%     % Construct an object to modulate binary data using OQPSK modulation.
%     % The constellation has Gray mapping and is shifted by -pi/16 radians.
%     h = modem.oqpskmod('PhaseOffset', -pi/16, 'SymbolOrder', 'Gray', ...
%     'InputType', 'Bit')
%
%     % Construct a modulator object from an existing demodulator object for
%     % OQPSK demodulation in order to modulate binary inputs.
%     demodObj = modem.oqpskdemod('PhaseOffset', pi/3) % existing OQPSK 
%                                                      % demodulator object
%     modObj = modem.oqpskmod(demodObj, 'InputType', 'Bit')
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/RESET,
%   MODEM/MODULATE, MODEM.OQPSKDEMOD

%   @modem/@oqpskmod

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:18:17 $

h = modem.oqpskmod;

% Initialize default prop values
h.Type = 'OQPSK Modulator';
h.M = 4;
setPrivProp(h, 'Constellation', [1 j -1 -j]*exp(j*pi/4));
setPrivProp(h, 'ProcessFunction', @modulate_Int);

% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.oqpskdemod')
        % modem.oqpskmod(oqpskdemod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
