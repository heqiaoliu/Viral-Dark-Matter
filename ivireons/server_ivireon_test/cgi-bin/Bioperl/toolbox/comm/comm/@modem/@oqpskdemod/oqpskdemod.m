function h = oqpskdemod(varargin)
%OQPSKDEMOD  OQPSK Demodulator
%   H = MODEM.OQPSKDEMOD(PROPERTY1, VALUE1, ...) constructs an OQPSK
%   demodulator object H with properties as specified by PROPERTY/VALUE pairs. 
%
%   H = MODEM.OQPSKDEMOD(OQPSKMOD_OBJECT) constructs an OQPSK demodulator object 
%   H by reading the property values from the OQPSK modulator object
%   OQPSKMOD_OBJECT. The properties that are unique to the OQPSK demodulator
%   object are set to default values. 
%
%   H = MODEM.OQPSKDEMOD(OQPSKMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs an
%   OQPSK demodulator object H by reading the property values from the OQPSK
%   modulator object OQPSKMOD_OBJECT. Additional properties are specified using
%   PROPERTY/VALUE pairs.
%
%   An OQPSK demodulator object has following properties. All the properties are
%   writable except for the ones explicitly noted otherwise. 
%
%   Type          - Type of modulation object ('OQPSK Demodulator'). This
%                   property is not writable. 
%   M             - M-ary value. This property is set to four.  This property is
%                   not writable. 
%   PhaseOffset   - Phase offset of ideal signal constellation in radians.
%   Constellation - Ideal signal constellation. This property is not writable
%                   and is automatically computed based on M and PhaseOffset
%                   properties. 
%   SymbolOrder   - Type of mapping employed for mapping symbols to ideal
%                   constellation points. The choices are:  
%                   'binary'          - Binary mapping
%                   'gray'            - Gray mapping 
%                   'user-defined'    - custom mapping
%   SymbolMapping - A list of integer values from 0 to M-1 that correspond to
%                   ideal constellation points. This property is writable only
%                   when SymbolOrder is set to 'user-defined'; otherwise it is
%                   automatically computed. 
%   OutputType    - Type of output to be computed by OQPSK demodulator object.
%                   The choices are:  
%                   'bit'             - bit/binary output
%                   'integer'         - integer/symbol output
%   DecisionType  - Type of output values to be computed by OQPSK demodulator
%                   object. The choices are:  
%                   'hard decision'   - Hard decision values
%                   'llr'             - Log-likelihood ratio (LLR)
%                   'approximate llr' - Approximate log-likelihood ratio
%   NoiseVariance - Noise variance of the received signal to be processed by
%                   OQPSK demodulator object. The noise variance is used to
%                   compute only LLR or Approximate LLR.  Hence, the
%                   NoiseVariance property is visible only when the DecisionType
%                   property is set to 'llr' or 'approximate llr'.
%
%   H = MODEM.OQPSKDEMOD constructs an OQPSK demodulator object H with default
%   properties. It constructs a demodulator object for OQPSK demodulation and is
%   equivalent to: 
%   H = MODEM.OQPSKDEMOD('PHASEOFFSET', 0, 'SYMBOLORDER', 'BINARY', ...
%           'OUTPUTTYPE', 'INTEGER', 'DECISIONTYPE', 'HARD DECISION')
%
%   An OQPSK demodulator object is equipped with four functions for inspection,
%   management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - DEMODULATE (type "help modem/demodulate" for detailed help)
%     - RESET (type "help modem/reset" for detailed help)
%
%   EXAMPLES:
%
%     % Construct a demodulator object for OQPSK demodulation with default
%     % constellation.
%     h = modem.oqpskdemod
%
%     % Construct an object to compute log-likelihood ratio of a baseband
%     % signal using OQPSK modulation. The constellation has Gray mapping and
%     % is shifted by -pi/16 radians. The estimated noise variance of input
%     % signal is 1.2.
%     h = modem.oqpskdemod('PhaseOffset', -pi/16, 'SymbolOrder', 'Gray', ...
%     'OutputType', 'Bit', 'DecisionType', 'LLR', 'NoiseVariance', 1.2)
%
%     % Construct a demodulator object from an existing modulator object for
%     % OQPSK modulation in order to compute approximate log-likelihood ratio
%     % for a baseband signal whose estimated noise variance is 0.81. 
%     modObj = modem.oqpskmod('InputType', 'Bit') % existing OQPSK modulator
%                                                 % object
%     demodObj = modem.oqpskdemod(modObj, 'DecisionType', 'Approximate LLR', ...
%     'NoiseVariance', 0.81)
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/RESET,
%   MODEM/DEMODULATE, MODEM.OQPSKMOD

%   @modem/@oqpskdemod   

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:18:15 $

h = modem.oqpskdemod;

% default prop values
h.Type = 'OQPSK Demodulator';
h.M = 4;
setPrivProp(h, 'Constellation', [1 j -1 -j]*exp(j*pi/4));
setPrivProp(h, 'ProcessFunction', @demodulate_IntBin);


% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.oqpskmod')
        % modem.oqpskdemod(oqpskmod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
