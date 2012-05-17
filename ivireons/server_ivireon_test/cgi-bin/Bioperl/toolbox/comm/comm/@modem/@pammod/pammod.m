function h = pammod(varargin)
%PAMMOD  PAM Modulator
%   H = MODEM.PAMMOD(PROPERTY1, VALUE1, ...) constructs a PAM modulator object
%   H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.PAMMOD(PAMDEMOD_OBJECT) constructs a PAM modulator object H by
%   reading the property values from the PAM demodulator object PAMDEMOD_OBJECT.
%   The properties that are unique to the PAM modulator object are set to
%   default values.
%
%   H = MODEM.PAMMOD(PAMDEMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs a PAM
%   modulator object H by reading the property values from the PAM demodulator
%   object PAMDEMOD_OBJECT. Additional properties are specified using
%   PROPERTY/VALUE pairs.
%
%   A PAM modulator object has the following properties. All the properties are
%   writable except for the ones explicitly noted otherwise.
%
%   Type          - Type of modulation object ('PAM Modulator'). This
%                   property is not writable.
%   M             - M-ary value.
%   Constellation - Ideal signal constellation. This property is not
%                   writable and is automatically computed based on M.
%   SymbolOrder   - Type of mapping employed for mapping symbols to ideal
%                   constellation points. The choices are: 
%                   'binary'        - for Binary mapping
%                   'gray'          - for Gray mapping
%                   'user-defined'  - for custom mapping
%   SymbolMapping - Symbol mapping is a list of integer values from 0 to M-1
%                   that correspond to ideal constellation points. This property
%                   is writable only when SymbolOrder is set to 'user-defined';
%                   otherwise it is automatically computed. 
%   InputType     - Type of input to be processed by PAM modulator
%                   object. The choices are: 
%                   'bit'           - for bit/binary input
%                   'integer'       - for integer/symbol input
%
%   H = MODEM.PAMMOD constructs a PAM modulator object H with default
%   properties. It constructs a modulator object for BPAM modulation and is
%   equivalent to:
%   H = MODEM.PAMMOD('M', 2, 'SYMBOLORDER', 'BINARY', 'INPUTTYPE', 'INTEGER') 
%
%   A PAM modulator object is equipped with three functions for inspection,
%   management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - MODULATE (type "help modem/modulate" for detailed help)
%
%   EXAMPLES: 
%
%     % Construct a modulator object for 4-PAM modulation.
%     h = modem.pammod('M', 4)
%
%     % Construct an object to modulate binary data using 16-PAM modulation.
%     % The constellation has Gray mapping.
%     h = modem.pammod('M', 16, 'SymbolOrder', 'Gray', 'InputType', 'Bit')
%
%     % Construct a modulator object from an existing demodulator object
%     % for PAM demodulation in order to modulate binary inputs.
%     demodObj = modem.pamdemod('M', 8)  % existing PAM demodulator object
%     modObj   = modem.pammod(demodObj, 'InputType', 'Bit')
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/MODULATE,
%   MODEM.PAMDEMOD

%   @modem/@pammod   

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:18:19 $

h = modem.pammod;

% default prop values
h.Type = 'PAM Modulator';
h.M = 2;
setPrivProp(h, 'ProcessFunction', @modulate_Int);

% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.pamdemod')
        % modem.pammod(pamdemod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
