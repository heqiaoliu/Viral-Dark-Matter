function h = genqammod(varargin)
%GENQAMMOD  General QAM Modulator
%   H = MODEM.GENQAMMOD(PROPERTY1, VALUE1, ...) constructs a General QAM
%   modulator object H with properties as specified by PROPERTY/VALUE pairs.
%
%   H = MODEM.GENQAMMOD(GENQAMDEMOD_OBJECT) constructs a General QAM modulator
%   object H by reading the property values from the General QAM demodulator
%   object GENQAMDEMOD_OBJECT. The properties that are unique to the General QAM
%   modulator object are set to default values.
%
%   H = MODEM.GENQAMMOD(GENQAMDEMOD_OBJECT, PROPERTY1, VALUE1, ...) constructs a
%   General QAM modulator object H by reading the property values from the
%   General QAM demodulator object GENQAMDEMOD_OBJECT. Additional properties are
%   specified using PROPERTY/VALUE pairs.
%
%   A General QAM modulator object has the following properties. All the
%   properties are writable except for the ones explicitly noted otherwise.
%
%   Type          - Type of modulation object ('General QAM Modulator'). This
%                   property is not writable.
%   M             - M-ary value.  This property is not writable and is
%                   automatically computed based on Constellation.
%   Constellation - Signal constellation. 
%   InputType     - Type of input to be processed by General QAM modulator
%                   object. The choices are: 
%                   'bit'           - for bit/binary input
%                   'integer'       - for integer/symbol input
%
%   H = MODEM.GENQAMMOD constructs a General QAM modulator object H with default
%   properties. It constructs a modulator object for 16-QAM modulation and is
%   equivalent to:
%   H = MODEM.GENQAMMOD('Constellation', [-3+j*3, -3+j*1, -3-j*1, -3-j*3, ...
%     -1+j*3, -1+j*1, -1-j*1, -1-j*3, 1+j*3, 1+j*1, 1-j*1, 1-j*3, 3+j*3, ...
%     3+j*1, 3-j*1, 3-j*3], 'INPUTTYPE', 'INTEGER')
%
%   A General QAM modulator object is equipped with three functions for
%   inspection, management, and simulation:
%     - DISP (type "help modem/disp" for detailed help)
%     - COPY (type "help modem/copy" for detailed help)
%     - MODULATE (type "help modem/modulate" for detailed help)
%
%   EXAMPLES: 
%
%     % Construct a General QAM modulator object with an equidistant 3-point
%     % constellation on the unit circle.
%     M = 3;
%     h = modem.genqammod('Constellation', exp(j*2*pi*[0:M-1]/M))
%
%     % Construct a General QAM object to modulate binary data using a
%     % two-tiered constellation.
%     h = modem.genqammod('Constellation', [exp(j*2*pi*[0:3]/4) ...
%           2*exp(j*(2*pi*[0:3]/4+pi/4))], 'InputType', 'Bit')
%     plot(h.Constellation, '*');grid on;axis('equal',[-2 2 -2 2]);
%
%     % Construct a modulator object from an existing demodulator object for
%     % General QAM demodulation in order to compute approximate log-likelihood
%     % ratio for a baseband signal whose estimated noise variance is 0.81.
%     demodObj = modem.genqamdemod('Constellation', [-1 1 2*j -2*j], ...
%               'OutputType', 'Bit', 'DecisionType', 'Approximate LLR', ...
%               'NoiseVariance', 0.81)   % existing General QAM demodulator object
%     modObj = modem.genqammod(demodObj)
%
%   See also MODEM, MODEM/TYPES, MODEM/DISP, MODEM/COPY, MODEM/MODULATE,
%   MODEM.GENQAMDEMOD

%   @modem/@genqammod   

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/01 12:18:12 $

h = modem.genqammod;

% default prop values
h.Type = 'General QAM Modulator';
h.Constellation = [-3+j*3, -3+j*1, -3-j*1, -3-j*3, -1+j*3, ...
     -1+j*1, -1-j*1, -1-j*3, 1+j*3, 1+j*1, 1-j*1, 1-j*3, ...
     3+j*3, 3+j*1, 3-j*1, 3-j*3]; 
setPrivProp(h, 'ProcessFunction', @modulate_Int);

% Initialize based on the arguments
if nargin ~= 0
    if isa(varargin{1},'modem.genqamdemod')
        % modem.genqammod(genqamdemod_object, ...) form
        initFromObject(h, varargin{:});
    else
        initObject(h, varargin{:});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
