function h = genqamdemod(varargin)
%GENQAMDEMOD  General QAM Demodulator
%   H = MODEM.GENQAMDEMOD(PROPERTY1, VALUE1, ...) constructs a General QAM
%   demodulator object H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.GENQAMDEMOD(GENQAMMOD_OBJECT) constructs a General QAM demodulator
%   object H by reading the property values from the General QAM modulator
%   object GENQAMMOD_OBJECT. The properties that are unique to the General QAM
%   demodulator object are set to default values.
%
%   H = MODEM.GENQAMDEMOD(GENQAMMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs a
%   General QAM demodulator object H by reading the property values from the
%   General QAM modulator object GENQAMMOD_OBJECT. Additional properties are
%   specified using PROPERTY/VALUE pairs.
%
%   A GENQAMDEMOD object has following properties. All the properties are
%   writable except for the ones explicitly noted otherwise.
%
%   Type          - Type of modulation object ('General QAM Demodulator'). This
%                   property is not writable.
%   M             - M-ary value.  This property is not writable and is
%                   automatically computed based on Constellation.
%   Constellation - Signal constellation. 
%   OutputType    - Type of output to be computed by General QAM demodulator
%                   object. The choices are: 
%                   'bit'             - bit/binary output
%                   'integer'         - integer/symbol output
%   DecisionType  - Type of output values to be computed by General QAM
%                   demodulator object. The choices are: 
%                   'hard decision'   - Hard decision values
%                   'llr'             - Log-likelihood ratio(LLR)
%                   'approximate llr' - Approximate log-likelihood ratio
%   NoiseVariance - Noise variance of the received signal to be processed by
%                   General QAM demodulator object. The noise variance is used
%                   to compute only LLR or Approximate LLR.  Hence, the
%                   NoiseVariance property is visible only when the DecisionType
%                   property is set to 'llr' or 'approximate llr'.
%
%   H = MODEM.GENQAMDEMOD constructs a General QAM demodulator object H with
%   default properties. It constructs a demodulator object for 16-QAM modulation
%   and is equivalent to:
%   H = MODEM.GENQAMDEMOD('Constellation', [-3+j*3, -3+j*1, -3-j*1, -3-j*3, ...
%     -1+j*3, -1+j*1, -1-j*1, -1-j*3, 1+j*3, 1+j*1, 1-j*1, 1-j*3, 3+j*3, ...
%     3+j*1, 3-j*1, 3-j*3], 'OUTPUTTYPE', 'INTEGER', ...
%     'DECISIONTYPE', 'HARD DECISION')
%    
%   A General QAM demodulator object is equipped with three functions for
%   inspection, management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - DEMODULATE (type "help modem/demodulate" for detailed help)
%
%   EXAMPLES:
%
%     % Construct a General QAM demodulator object with an equidistant 3-point 
%     % constellation on the unit circle.
%     M = 3;
%     h = modem.genqamdemod('Constellation', exp(j*2*pi*[0:M-1]/M))
%
%     % Construct a General QAM demodulator object to compute log-likelihood 
%     % ratio of a baseband signal using a two-tiered constellation. The
%     % estimated noise variance of input signal is 1.2.
%     h = modem.genqamdemod('Constellation', [exp(j*2*pi*[0:3]/4) ...
%           2*exp(j*(2*pi*[0:3]/4+pi/4))], 'OutputType', 'Bit', ...
%           'DecisionType', 'LLR', 'NoiseVariance', 1.2)
%     plot(h.Constellation, '*');grid on;axis('equal',[-2 2 -2 2]);
%
%     % Construct a demodulator object from an existing modulator object for
%     % General QAM modulation in order to compute approximate log-likelihood
%     % ratio for a baseband signal whose estimated noise variance is 0.81.
%     modObj = modem.genqammod('Constellation', [-1 1 2*j -2*j], 'InputType',...
%               'Bit')   % existing General QAM modulator object
%     demodObj = modem.genqamdemod(modObj, 'DecisionType', 'Approximate LLR',...
%               'NoiseVariance', 0.81)
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/DEMODULATE,
%   MODEM.GENQAMMOD

%   @modem/@genqamdemod   

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:18:11 $

h = modem.genqamdemod;

% default prop values
h.Type = 'General QAM Demodulator';
h.Constellation = [-3+j*3, -3+j*1, -3+j*-1, -3+j*-3, -1+j*3, ...
     -1+j*1, -1+j*-1, -1+j*-3, 1+j*3, 1+j*1, 1+j*-1, 1+j*-3, ...
     3+j*3, 3+j*1, 3+j*-1, 3+j*-3]; 
setPrivProp(h, 'ProcessFunction', @demodulate_IntBin);

% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.genqammod')
        % modem.genqamdemod(genqammod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
