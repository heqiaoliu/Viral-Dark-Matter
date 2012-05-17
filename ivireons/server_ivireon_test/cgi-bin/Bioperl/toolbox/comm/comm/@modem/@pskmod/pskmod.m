function h = pskmod(varargin)
%PSKMOD  PSK Modulator
%   H = MODEM.PSKMOD(M) constructs a PSK modulator object H for M-ary
%   modulation. 
%
%   H = MODEM.PSKMOD(M, PHASEOFFSET) constructs a PSK modulator object H whose
%   constellation has a phase offset of PHASEOFFSET radians.
%
%   H = MODEM.PSKMOD(PROPERTY1, VALUE1, ...) constructs a PSK modulator object
%   H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.PSKMOD(PSKDEMOD_OBJECT) constructs a PSK modulator object H by
%   reading the property values from the PSK demodulator object PSKDEMOD_OBJECT.
%   The properties that are unique to the PSK modulator object are set to
%   default values.
%
%   H = MODEM.PSKMOD(PSKDEMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs a PSK
%   modulator object H by reading the property values from the PSK demodulator
%   object PSKDEMOD_OBJECT. Additional properties are specified using
%   PROPERTY/VALUE pairs.
%
%   A PSK modulator object has the following properties. All the properties are
%   writable except for the ones explicitly noted otherwise.
%
%   Type          - Type of modulation object ('PSK Modulator'). This
%                   property is not writable.
%   M             - M-ary value.
%   PhaseOffset   - Phase offset of ideal signal constellation in radians.
%   Constellation - Ideal signal constellation. This property is not
%                   writable and is automatically computed based on M and
%                   PhaseOffset properties.
%   SymbolOrder   - Type of mapping employed for mapping symbols to ideal
%                   constellation points. The choices are: 
%                   'binary'        - for Binary mapping
%                   'gray'          - for Gray mapping
%                   'user-defined'  - for custom mapping
%   SymbolMapping - Symbol mapping is a list of integer values from 0 to M-1
%                   that correspond to ideal constellation points. This property
%                   is writable only when SymbolOrder is set to 'user-defined';
%                   otherwise it is automatically computed. 
%   InputType     - Type of input to be processed by PSK modulator
%                   object. The choices are: 
%                   'bit'           - for bit/binary input
%                   'integer'       - for integer/symbol input
%
%   H = MODEM.PSKMOD constructs a PSK modulator object H with default
%   properties. It constructs a modulator object for BPSK modulation and is
%   equivalent to:
%   H = MODEM.PSKMOD('M', 2, 'PHASEOFFSET', 0, 'SYMBOLORDER', 'BINARY', ...
%           'INPUTTYPE', 'INTEGER')
%
%   A PSK modulator object is equipped with three functions for inspection,
%   management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - MODULATE (type "help modem/modulate" for detailed help)
%
%   EXAMPLES: 
%
%     % Construct a modulator object for QPSK modulation.
%     h = modem.pskmod(4)
%
%     % Construct a modulator object for 8-PSK modulation with constellation
%     % shifted by pi/8 radians.
%     h = modem.pskmod(8, pi/8)
%
%     % Construct an object to modulate binary data using 16-PSK modulation.
%     % The constellation has Gray mapping and is shifted by -pi/16 radians.
%     h = modem.pskmod('M', 16, 'PhaseOffset', -pi/16, ...
%           'SymbolOrder', 'Gray', 'InputType', 'Bit')
%
%     % Construct a modulator object from an existing demodulator object for
%     % PSK demodulation in order to modulate binary inputs.
%     demodObj = modem.pskdemod('M', 8)  % existing PSK demodulator object
%     modObj = modem.pskmod(demodObj, 'InputType', 'Bit')
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/MODULATE,
%   MODEM.PSKDEMOD

%   @modem/@pskmod   

%   Copyright 2006 - 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/01 12:18:21 $

h = modem.pskmod;

% Set default prop values
h.Type = 'PSK Modulator';
h.M = 2;
setPrivProp(h, 'ProcessFunction', @modulate_Int);

% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.pskdemod')
        % modem.pskmod(pskdemod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]