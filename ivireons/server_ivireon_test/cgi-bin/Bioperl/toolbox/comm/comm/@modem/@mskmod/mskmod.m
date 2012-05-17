function h = mskmod(varargin)
%MSKMOD  MSK Modulator
%   H = MODEM.MSKMOD(PROPERTY1, VALUE1, ...) constructs an MSK modulator object
%   H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.MSKMOD(MSKDEMOD_OBJECT) constructs an MSK modulator object H by
%   reading the property values from the MSK demodulator object MSKDEMOD_OBJECT.
%   The properties that are unique to the MSK modulator object are set to
%   default values.
%
%   H = MODEM.MSKMOD(MSKDEMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs an MSK
%   modulator object H by reading the property values from the MSK modulator
%   object MSKDEMOD_OBJECT. Additional properties are specified using
%   PROPERTY/VALUE pairs.
%
%   An MSK modulator object has the following properties. All the properties are
%   writable except for the ones explicitly noted otherwise.
%
%   Type             - Type of modulation object ('MSK Modulator'). This
%                      property is not writable.
%   M                - Constellation size.  It is set to two and is not
%                      writable. 
%   Precoding        - Specifies the type of the coherent MSK modulator. The
%                      choices are : 
%                      'off'    - for conventional coherent MSK
%                      'on'     - for precoded coherent MSK
%   SamplesPerSymbol - Number of samples used to represent an MSK symbol.
%   InputType        - Type of input to be processed by MSK modulator
%                      object. The choices are:
%                      'bit'           - for bit/binary input
%                      'integer'       - for integer/symbol input
%                      Note that since MSK constellation size is two, 'bit' and
%                      'integer' are equivalent.
%
%   H = MODEM.MSKMOD constructs an MSK modulator object H with default
%   properties. This syntax is equivalent to:
%   H = MODEM.MSKMOD('PRECODING', 'OFF', 'SAMPLESPERSYMBOL', 8, ...
%           'INPUTTYPE', 'BIT')  
%
%   An MSK modulator object is equipped with four functions for inspection,
%   management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - MODULATE (type "help modem/modulate" for detailed help)
%     - RESET (type "help modem/reset" for detailed help)
%
%   EXAMPLES:
%
%     % Construct a modulator object for MSK modulation with five samples
%     % per symbol.
%     h = modem.mskmod('SamplesPerSymbol', 5)
%
%     % Construct an MSK modulator object with precoding and 10 samples per
%     % symbol.
%     h = modem.mskmod('Precoding', 'on', 'SamplesPerSymbol', 10)
%
%     % Construct a modulator object from an existing demodulator object for
%     % MSK demodulation in order to modulate binary inputs.
%     demodObj = modem.mskdemod('SamplesPerSymbol', 6)  % existing 
%                                                       % MSK demodulator object
%     modObj = modem.mskmod(demodObj)
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/RESET,
%   MODEM/MODULATE, MODEM.MSKDEMOD

%   @modem/@mskmod

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:18:14 $

h = modem.mskmod;

% default prop values
h.Type = 'MSK Modulator';
h.M = 2;
h.InputType = 'Bit';
h.SamplesPerSymbol = 8;
setPrivProp(h, 'ProcessFunction', @modulate_Conventional);

% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.mskdemod')
        % modem.mskmod(mskdemod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
