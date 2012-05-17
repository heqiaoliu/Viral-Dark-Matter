function h = mskdemod(varargin)
%MSKDEMOD  MSK Demodulator
%   H = MODEM.MSKDEMOD(PROPERTY1, VALUE1, ...) constructs an MSK demodulator
%   object H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.MSKDEMOD(MSKMOD_OBJECT) constructs an MSK demodulator object H by
%   reading the property values from the MSK modulator object MSKMOD_OBJECT. The
%   properties that are unique to the MSK demodulator object are set to default
%   values.
%
%   H = MODEM.MSKDEMOD(MSKMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs an MSK
%   demodulator object H by reading the property values from the MSK modulator
%   object MSKMOD_OBJECT. Additional properties are specified using
%   PROPERTY/VALUE pairs.
%
%   MSK demodulator object has following properties. All the properties are
%   writable except for the ones explicitly noted otherwise.
%
%   Type             - Type of modulation object ('MSK Demodulator'). This
%                      property is not writable.
%   M                - Constellation size.  It is set to two and is not writable.
%   Precoding        - Specifies the type of the coherent MSK demodulator. The
%                      choices are : 
%                      'off'    - for conventional coherent MSK
%                      'on'     - for precoded coherent MSK
%   SamplesPerSymbol - Number of samples used to represent an MSK symbol.
%   OutputType       - Type of output to be computed by MSK demodulator
%                      object. The choices are: 
%                      'bit'             - bit/binary output
%                      'integer'         - integer/symbol output
%                      Note that since MSK constellation size is two, 'bit' and
%                      'integer' are equivalent.
%   DecisionType     - Type of output values to be computed by MSK demodulator
%                      object. This property is set to 'hard decision' and is
%                      not writable.
%
%   H = MODEM.MSKDEMOD constructs an MSK demodulator object H with default
%   properties. It constructs a demodulator object for MSK demodulation and is
%   equivalent to:
%   H = MODEM.MSKDEMOD('PRECODING', 'OFF', 'SAMPLESPERSYMBOL', 8, ...
%           'OUTPUTTYPE', 'BIT') 
%
%   An MSK demodulator object is equipped with four functions for inspection,
%   management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - DEMODULATE (type "help modem/demodulate" for detailed help)
%     - RESET (type "help modem/reset" for detailed help)
%
%   EXAMPLES:
%
%     % Construct an MSK demodulator object with five samples per symbol. 
%     h = modem.mskdemod('SamplesPerSymbol', 5)
%
%     % Construct an MSK demodulator object with precoding.
%     h = modem.mskdemod('Precoding', 'on') 
%
%     % Construct an MSK demodulator object from an existing MSK modulator
%     % object. 
%     modObj = modem.mskmod('SamplesPerSymbol', 6, 'Precoding', 'on') % existing 
%                                                        % MSK modulator object
%     demodObj = modem.mskdemod(modObj)
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/RESET,
%   MODEM/DEMODULATE, MODEM.MSKMOD

%   @modem/@mskdemod   

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:18:13 $

h = modem.mskdemod;

% default prop values
h.Type = 'MSK Demodulator';
h.M = 2;
h.OutputType = 'Bit';
h.SamplesPerSymbol = 8;
setPrivProp(h, 'ProcessFunction', @demodulate_Conventional);

% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.mskmod')
        % modem.mskdemod(mskmod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
