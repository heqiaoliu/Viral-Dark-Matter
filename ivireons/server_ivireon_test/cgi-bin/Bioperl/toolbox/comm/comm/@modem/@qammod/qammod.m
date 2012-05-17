function h = qammod(varargin)
%QAMMOD  QAM Modulator
%   H = MODEM.QAMMOD(M) constructs a QAM modulator object H for M-ary
%   modulation. 
%
%   H = MODEM.QAMMOD(M, PHASEOFFSET) constructs a QAM modulator object H whose
%   constellation has a phase offset of PHASEOFFSET radians.
%
%   H = MODEM.QAMMOD(PROPERTY1, VALUE1, ...) constructs a QAM modulator object
%   H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.QAMMOD(QAMDEMOD_OBJECT) constructs a QAM modulator object H by
%   reading the property values from the QAM demodulator object QAMDEMOD_OBJECT.
%   The properties that are unique to the QAM modulator object are set to
%   default values.
%
%   H = MODEM.QAMMOD(QAMDEMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs a QAM
%   modulator object H by reading the property values from the QAM demodulator
%   object QAMDEMOD_OBJECT. Additional properties are specified using
%   PROPERTY/VALUE pairs.
%
%   A QAM modulator object has the following properties. All the properties are
%   writable except for the ones explicitly noted otherwise.
%
%   Type          - Type of modulation object ('QAM Modulator'). This
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
%   InputType     - Type of input to be processed by QAM modulator
%                   object. The choices are: 
%                   'bit'           - for bit/binary input
%                   'integer'       - for integer/symbol input
%
%   H = MODEM.QAMMOD constructs a QAM modulator object H with default
%   properties. It constructs a modulator object for 16-QAM modulation and is
%   equivalent to:
%   H = MODEM.QAMMOD('M', 16, 'PHASEOFFSET', 0, 'SYMBOLORDER', 'BINARY', ...
%           'INPUTTYPE', 'INTEGER')
%
%   A QAM modulator object is equipped with three functions for inspection,
%   management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - MODULATE (type "help modem/modulate" for detailed help)
%
%
%   EXAMPLES: 
%
%     % Construct a modulator object for 32-QAM modulation.
%     h = modem.qammod(32)
%
%     % Construct an object to modulate binary data using 64-QAM modulation.
%     % The constellation has Gray mapping.
%     h = modem.qammod('M', 64, 'SymbolOrder', 'Gray', 'InputType', 'Bit')
%
%     % Construct a modulator object from an existing demodulator object for
%     % QAM demodulation in order to modulate binary inputs.
%     demodObj = modem.qamdemod('M', 8)  % existing QAM demodulator object
%     modObj = modem.qammod(demodObj, 'InputType', 'Bit')
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/MODULATE,
%   MODEM.QAMDEMOD

%   @modem/@qammod   

%   Copyright 2006 - 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/01 12:18:23 $

h = modem.qammod;

% default prop values
h.Type = 'QAM Modulator';
h.M = 16;
setPrivProp(h, 'ProcessFunction', @modulate_Int);

% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.qamdemod')
        % modem.qammod(qamdemod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------

% [EOF]