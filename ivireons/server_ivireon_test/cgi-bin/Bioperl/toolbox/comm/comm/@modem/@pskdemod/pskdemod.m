function h = pskdemod(varargin)
%PSKDEMOD  PSK Demodulator
%   H = MODEM.PSKDEMOD(M) constructs a PSK demodulator object H for M-ary
%   demodulation. 
%
%   H = MODEM.PSKDEMOD(M, PHASEOFFSET) constructs a PSK demodulator object H
%   whose constellation has a phase offset of PHASEOFFSET radians.
%
%   H = MODEM.PSKDEMOD(PROPERTY1, VALUE1, ...) constructs a PSK demodulator
%   object H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.PSKDEMOD(PSKMOD_OBJECT) constructs a PSK demodulator object H by
%   reading the property values from the PSK modulator object PSKMOD_OBJECT. The
%   properties that are unique to the PSK demodulator object are set to default
%   values.
%
%   H = MODEM.PSKDEMOD(PSKMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs a PSK
%   demodulator object H by reading the property values from the PSK modulator
%   object PSKMOD_OBJECT. Additional properties are specified using
%   PROPERTY/VALUE pairs.
%
%   A PSK demodulator object has following properties. All the properties are
%   writable except for the ones explicitly noted otherwise.
%
%   Type          - Type of modulation object ('PSK Demodulator'). This
%                   property is not writable.
%   M             - M-ary value.
%   PhaseOffset   - Phase offset of ideal signal constellation in radians.
%   Constellation - Ideal signal constellation. This property is not
%                   writable and is automatically computed based on M and
%                   PhaseOffset properties.
%   SymbolOrder   - Type of mapping employed for mapping symbols to ideal
%                   constellation points. The choices are: 
%                   'binary'          - Binary mapping
%                   'gray'            - Gray mapping 
%                   'user-defined'    - custom mapping
%   SymbolMapping - Symbol mapping is a list of integer values from 0 to M-1
%                   that correspond to ideal constellation points. This property
%                   is writable only when SymbolOrder is set to 'user-defined';
%                   otherwise it is automatically computed. 
%   OutputType    - Type of output to be computed by PSK demodulator
%                   object. The choices are: 
%                   'bit'             - bit/binary output
%                   'integer'         - integer/symbol output
%   DecisionType  - Type of output values to be computed by PSK demodulator
%                   object. The choices are: 
%                   'hard decision'   - Hard decision values
%                   'llr'             - Log-likelihood ratio(LLR)
%                   'approximate llr' - Approximate log-likihood raio
%   NoiseVariance - Noise variance of the channel/equalized signal to be
%                   processed by PSK demodulator object. The noise variance is
%                   used to compute only LLR or Approximate LLR.  Hence, the
%                   NoiseVariance property is visible only when the DecisionType
%                   property is set to 'llr' or 'approximate llr'.
%
%   H = MODEM.PSKDEMOD constructs a PSK demodulator object H with default
%   properties. It constructs a demodulator object for BPSK demodulation and is
%   equivalent to:
%   H = MODEM.PSKDEMOD('M', 2, 'PHASEOFFSET', 0, 'SYMBOLORDER', 'BINARY', ...
%           'OUTPUTTYPE', 'INTEGER', 'DECISIONTYPE', 'HARD DECISION')
%   A PSK demodulator object is equipped with three functions for inspection,
%   management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - DEMODULATE (type "help modem/demodulate" for detailed help)
%
%   EXAMPLES:
%
%     % Construct a demodulator object for QPSK demodulation.
%     h = modem.pskdemod(4)
%
%     % Construct an object to compute log-likelihood ratio of a baseband
%     % signal using 16-PSK modulation. The constellation has Gray mapping and
%     % is shifted by -pi/16 radians. The estimated noise variance of input
%     % signal is 1.2.
%     h = modem.pskdemod('M', 16, 'PhaseOffset', -pi/16, ...
%           'SymbolOrder', 'Gray', 'OutputType', 'Bit', ...
%           'DecisionType', 'LLR', 'NoiseVariance', 1.2)
%
%     % Construct a demodulator object from an existing modulator object for
%     % PSK modulation in order to compute approximate log-likelihood ratio for
%     % a baseband signal whose estimated noise variance is 0.81.
%     modObj = modem.pskmod('M', 8, 'InputType', 'Bit')  % existing PSK 
%                                                        % modulator object
%     demodObj = modem.pskdemod(modObj, 'DecisionType', 'Approximate LLR', ...
%           'NoiseVariance', 0.81)
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/DEMODULATE,
%   MODEM.PSKMOD

%   @modem/@pskdemod   

%   Copyright 2006 - 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/01 12:18:20 $

h = modem.pskdemod;

% default prop values
h.Type = 'PSK Demodulator';
h.M = 2;
setPrivProp(h, 'ProcessFunction', @demodulate_IntBin);

if nargin ~= 0
    if isa(varargin{1},'modem.pskmod')
        % modem.pskdemod(pskmod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
