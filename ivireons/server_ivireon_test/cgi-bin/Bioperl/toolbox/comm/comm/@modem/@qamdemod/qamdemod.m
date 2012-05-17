function h = qamdemod(varargin)
%QAMDEMOD  QAM Demodulator
%   H = MODEM.QAMDEMOD(M) constructs a QAM demodulator object H for M-ary
%   demodulation. 
%
%   H = MODEM.QAMDEMOD(M, PHASEOFFSET) constructs a QAM demodulator object H for
%   M-ary demodulation. The M-ary constellation has a phase offset of
%   PHASEOFFSET radians.
%
%   H = MODEM.QAMDEMOD(PROPERTY1, VALUE1, ...) constructs a QAM demodulator
%   object H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.QAMDEMOD(QAMMOD_OBJECT) constructs a QAM demodulator object H by
%   reading the property values from the QAM modulator object QAMMOD_OBJECT. The
%   properties that are unique to the QAM demodulator object are set to default
%   values.
%
%   H = MODEM.QAMDEMOD(QAMMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs a QAM
%   demodulator object H by reading the property values from the QAM modulator
%   object QAMMOD_OBJECT. Additional properties are specified using
%   PROPERTY/VALUE pairs.
%
%   A QAM demodulator object has the following properties. All the properties
%   are writable except for the ones explicitly noted otherwise.
%
%   Type          - Type of modulation object. This property is not writable.
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
%   OutputType    - Type of output to be computed by QAM demodulator
%                   object. The choices are: 
%                   'bit'             - bit/binary output
%                   'integer'         - integer/symbol output
%   DecisionType  - Type of output values to be computed by QAM demodulator
%                   object. The choices are: 
%                   'hard decision'   - Hard decision values
%                   'llr'             - Log-likelihood ratio(LLR)
%                   'approximate llr' - Approximate log-likelihood ratio
%   NoiseVariance - Noise variance of the channel/equalized signal to be
%                   processed by QAM demodulator object. The noise variance is
%                   used to compute only LLR or Approximate LLR.  Hence, the
%                   NoiseVariance property is visible only when the DecisionType
%                   property is set to 'llr' or 'approximate llr'.
%
%   H = MODEM.QAMDEMOD constructs a QAM demodulator object H with default
%   properties. It constructs a demodulator object for 16-QAM demodulation and
%   is equivalent to:
%   H = MODEM.QAMDEMOD('M', 16, 'PHASEOFFSET', 0, 'SYMBOLORDER', 'BINARY', ...
%           'OUTPUTTYPE', 'INTEGER', 'DECISIONTYPE', 'HARD DECISION')
%
%   A QAM demodulator object is equipped with three functions for inspection,
%   management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - DEMODULATE (type "help modem/demodulate" for detailed help)
%
%   EXAMPLES:
%
%     % Construct a demodulator object for 16-QAM demodulation.
%     h = modem.qamdemod  % note that default value of property M is 16
%
%     % Construct an object to compute log-likelihood ratio of a baseband
%     % signal using 64-QAM modulation. The constellation has Gray mapping.
%     % The estimated noise variance of input signal is 12.2.
%     h = modem.qamdemod('M', 64, 'SymbolOrder', 'Gray', ...
%     'OutputType', 'Bit', 'DecisionType', 'LLR', 'NoiseVariance', 12.2)
%
%     % Construct a demodulator object from an existing modulator object for
%     % QAM modulation in order to compute approximate log-likelihood ratio for
%     % a baseband signal whose estimated noise variance is 3.81.
%     modObj = modem.qammod('M', 8, 'InputType', 'Bit')  % existing QAM 
%                                                        % modulator object
%     demodObj = modem.qamdemod(modObj, 'DecisionType', 'Approximate LLR', ...
%     'NoiseVariance', 3.81)
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/DEMODULATE,
%   MODEM.QAMMOD

%   @modem/@qamdemod   

%   Copyright 2006 - 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/01 12:18:22 $

h = modem.qamdemod;

% default prop values
h.Type = 'QAM Demodulator';
h.M = 16;
setPrivProp(h, 'ProcessFunction', @demodulate_SquareQAMIntBin);

% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.qammod')
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]