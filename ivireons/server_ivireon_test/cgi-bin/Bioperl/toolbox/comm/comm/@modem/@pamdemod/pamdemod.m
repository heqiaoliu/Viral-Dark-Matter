function h = pamdemod(varargin)
%PAMDEMOD  PAM Demodulator
%   H = MODEM.PAMDEMOD(PROPERTY1, VALUE1, ...) constructs a PAM demodulator
%   object H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.PAMDEMOD(PAMMOD_OBJECT) constructs a PAM demodulator object H by
%   reading the property values from the PAM modulator object PAMMOD_OBJECT. The
%   properties that are unique to the PAM demodulator object are set to default
%   values.
%
%   H = MODEM.PAMDEMOD(PAMMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs a PAM
%   demodulator object H by reading the property values from the PAM modulator
%   object PAMMOD_OBJECT. Additional properties are specified using
%   PROPERTY/VALUE pairs.
%
%   A PAM demodulator object has following properties. All the properties are
%   writable except for the ones explicitly noted otherwise. 
%
%   Type          - Type of modulation object ('PAM Demodulator'). This property
%                   is not writable.
%   M             - M-ary value.
%   Constellation - Ideal signal constellation. This property is not writable
%                   and is automatically computed based on M. 
%   SymbolOrder   - Type of mapping employed for mapping symbols to ideal
%                   constellation points. The choices are:  
%                   'binary'          - Binary mapping
%                   'gray'            - Gray mapping 
%                   'user-defined'    - custom mapping
%   SymbolMapping - Symbol mapping is a list of integer values from 0 to M-1
%                   that correspond to ideal constellation points. This property
%                   is writable only when SymbolOrder is set to 'user-defined';
%                   otherwise it is automatically computed. 
%   OutputType    - Type of output to be computed by PAM demodulator object. The
%                   choices are:  
%                   'bit'             - bit/binary output
%                   'integer'         - integer/symbol output
%   DecisionType  - Type of output values to be computed by PAM demodulator
%                   object. The choices are:  
%                   'hard decision'   - Hard decision values
%                   'llr'             - Log-likelihood ratio(LLR)
%                   'approximate llr' - Approximate log-likelihood ratio
%   NoiseVariance - Noise variance of the received signal to be processed by
%                   PAM demodulator object. The noise variance is used to
%                   compute only LLR or Approximate LLR.  Hence, the
%                   NoiseVariance property is visible only when the DecisionType
%                   property is set to 'llr' or 'approximate llr'.
%
%   H = MODEM.PAMDEMOD constructs a PAM demodulator object H with default
%   properties. It constructs a demodulator object for BPAM demodulation and is
%   equivalent to:
%   H = MODEM.PAMDEMOD('M', 2, 'SYMBOLORDER', 'BINARY', 'OUTPUTTYPE', ...
%           'INTEGER', 'DECISIONTYPE', 'HARD DECISION') 
%
%   A PAM demodulator object is equipped with three functions for inspection,
%   management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - DEMODULATE (type "help modem/demodulate" for detailed help)
%
%   EXAMPLES:
%
%     % Construct a demodulator object for 4-PAM demodulation.
%     h = modem.pamdemod('M', 4)
%
%     % Construct an object to compute log-likelihood ratio of a baseband
%     % signal using 16-PAM modulation. The constellation has Gray mapping.
%     % The estimated noise variance of input signal is 1.2.
%     h = modem.pamdemod('M', 16, 'SymbolOrder', 'Gray', 'OutputType', ...
%     'Bit', 'DecisionType', 'LLR', 'NoiseVariance', 1.2)
%
%     % Construct a demodulator object from an existing modulator object for
%     % PAM modulation in order to compute approximate log-likelihood ratio for
%     % a baseband signal whose estimated noise variance is 0.81.
%     modObj = modem.pammod('M', 8, 'InputType', 'Bit')  % existing PAM 
%                                                        % modulator object
%     demodObj = modem.pamdemod(modObj, 'DecisionType', 'Approximate LLR', ...
%           'NoiseVariance', 0.81)
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/DEMODULATE,
%   MODEM.PAMMOD

%   @modem/@pamdemod   

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:18:18 $

h = modem.pamdemod;

% default prop values
h.Type = 'PAM Demodulator';
h.M = 2;
setPrivProp(h, 'ProcessFunction', @demodulate_IntBin);

% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.pammod')
        % modem.pamdemod(pammod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
