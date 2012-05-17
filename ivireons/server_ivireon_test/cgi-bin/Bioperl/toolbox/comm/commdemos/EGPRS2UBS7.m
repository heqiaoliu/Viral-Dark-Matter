classdef (ConstructOnLoad) EGPRS2UBS7 < testconsole.SystemBasicAPI
%EGPRS2UBS7 - EGPRS2 UBS-7 system
%   EGPRS2UBS7 extends the testconsole.SystemBasicAPI class and defines an
%   EGPRS Phase 2 Level B Uplink Type 7 (UBS-7 Logical Channel) system. 
%
%   The following is a list of properties of the EGPRS2UBS7 system.  All the
%   properties are also registered as test parameters.
%
%   EGPRS2UBS7 properties:
%
%   SNR                       - Signal to noise ratio in dB
%   ChannelType               - Type of the simulated channel
%   SamplesPerSymbol          - Samples per symbol
%   EqualizerForgettingFactor - Equalizer forgetting factor
%   EqualizerNumForwardTaps   - Equalizer number of forward taps
%   EqualizerNumFeedbackTaps  - Equalizer number of feedback taps
%   EqualizerDelay            - Delay to position the desired symbol
%
%   EGPRS2UBS7 methods:
%
%   run              - Run the EGPRS2 UBS-7 system for one iteration
%   setup            - Get test parameter values from the test console
%
%   See also IEEE80211b, commtest.MPSKSystem, commtest.ErrorRate

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 15:57:08 $

    %===========================================================================
    % Test parameters
    % These are the properties that can be used to parameterize simulations,
    % i.e. can be changed during simulations.  We must declare these properties as
    % public to be able to register them as test parameters to a test
    % console.  Since they are defined as public, they are shown when the EGPRS2UBS7
    % system is displayed in the command line.
    properties
        %SNR     Signal to noise ratio in dB
        SNR = 10;
        %ChannelType Type of the simulated channel
        %   Select one of the GSM/EDGE or 3GPP channel types defined in STDCHAN
        %   function with a predefined speed.  To get a list of possible values
        %   use getChannelTypes method.
        ChannelType = 'gsmTU50_6c1';
        %SamplesPerSymbol Number of samples per symbol
        %   Specify the number of samples used to simulate a symbol.  The
        %   value of this property is used to configure the channel
        %   simulator and pulse shaping filter.  It is also used to
        %   calculate symbol power and number of received samples.  This
        %   property must be a positive integer.  The default value is 4.
        SamplesPerSymbol = 4;
        %EqualizerForgettingFactor Equalizer forgetting factor
        %   Specify the forgetting factor for the RLS algorithm used by
        %   the equalizer.  This property must be a nonnegative scalar less
        %   than or equal to 1.  The default value is 0.9.
        EqualizerForgettingFactor = 0.9;
        %EqualizerNumForwardTaps Equalizer number of forward taps
        %   Specify the number of forward taps for the DFE.  This property
        %   must be a positive integer.  The default value is 10.
        EqualizerNumForwardTaps = 10;
        %EqualizerNumFeedbackTaps Equalizer number of feedback taps
        %   Specify the number of feedback taps for the DFE.  This property
        %   must be a nonnegative integer.  The default value is 6.
        EqualizerNumFeedbackTaps = 6;
        %EqualizerDelay Delay to position the desired symbol in the equalizer 
        %   Specify the delay to position the desired symbol in the
        %   equalizer in terms of samples.  This property is used to
        %   position the main channel tap in the middle of the equalizer
        %   forward filter.  This property must be a nonnegative integer.
        %   The default value is 6.
        EqualizerDelay = 4;
    end

    %===========================================================================
    % Private constant properties
    % These are properties that do not change during simulations.  We
    % defined them as private to prevent them to be shown when the
    % EGPRS2UBS7 system is displayed in the command line.
    properties (GetAccess = private, Constant)
        % Constraint length
        ConstraintLength = 7;
        % Inverse of code rate
        RateInverse = 3;
        % Generator polynomial 4 (1+D^2+D^3+D^5+D^6)
        G4 = 133;
        % Generator polynomial 5 (1+D+D^4+D^6)
        G5 = 145;
        % Generator polynomial 7 (1+D+D^2+D^3+D^6)
        G7 = 171;
        % Puncturing pattern
        PuncturePattern = EGPRS2UBS7.calculatePuncturePattern;
        % Header interleaver parameter Nc
        HeaderInterleaverNc = 144;
        % Header interleaver parameter a
        HeaderInterleaverA = 29;
        % Data interleaver parameter Nc
        DataInterleaverNc = 2056;
        % Data interleaver parameter a
        DataInterleaverA = 403;
        % 16-QAM Constellation
        Constellation = [1+1i, 1+3i, 3+1i, 3+3i, 1-1i, 1-3i, 3-1i, 3-3i, ...
            -1+1i, -1+3i, -3+1i, -3+3i, -1-1i, -1-3i, -3-1i, -3-3i];
        % Carrier frequency
        Fc = 900e6;
        % Symbol duration
        TSymbol = 1/325000;
        % Number of data bits
        NumDataBits = 940;
        % Number of header bits
        NumHeaderBits = 40;
        % Number of information bits in one part
        NumInfoBits = 450;
        % Tail bits for the higher symbol rate burst (HB)
        TailBits = [0;0;0;1;0;1;1;0;0;1;1;0;1;1;0;1];
        % TSC 0 for the higher symbol rate burst (HB)
        TrainingBits = [...
            0;0;1;1;1;1;1;1;0;0;1;1;0;0;1;1;1;1;1;1;0;0;1;1;0;0;1;1;0;0;1;1;...
            1;1;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
            1;1;1;1;0;0;1;1;0;0;1;1;1;1;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
            1;1;1;1;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;1;1];
        % Number of bits per symbol (16-QAM)
        BitsPerSymbol = 4;
        % Mapping parameter j0
        j0 = 1:258;
        % Mapping parameter j1
        j1 = 259:276;
        % Mapping parameter j2
        j2 = 277:278;
        % Mapping parameter j3
        j3 = 279:296;
        % Mapping parameter j4
        j4 = 297:552;
        % Bit swapping parameter k
        kSwap = [0 1 4 5 8 9 12 13 16 17 38 39 42 43 46 47 50 51 54 55] +1;
        % Number of tail symbols
        NumTailSymbols = 4;
        % Number of encoded symbols per side
        NumEncodedSymbols = 69;
        % Number of training symbols
        NumTrainSymbols = 31;
        % Integer number of guard symbols
        NumGuardSymbols = 10;
        % Channel type enumerated values
        ChannelTypeEnums = {'gsmRA250_6c1', 'gsmRA250_4c2', 'gsmHT50_12c1', ...
                'gsmHT50_12c2', 'gsmHT50_6c1', 'gsmHT50_6c2', 'gsmTU3_12c1', ...
                'gsmTU3_12c2', 'gsmTU3_6c1', 'gsmTU3_6c2', 'gsmEQ100_6', ...
                'gsmTI3_2', '3gppTU3', '3gppRA250', '3gppHT100', 'gsmTU50_6c1'};
    end
    
    %===========================================================================
    % Private transient properties
    % These are the properties that will be used internally during
    % simulations.  Their values depend on other properties.  They are
    % initialized in the constructor.  We defined these properties as
    % transient so that MATLAB will not save their values.  Also, while
    % working on multiple workers, i.e. parallel processing, the values of
    % these properties will not be transferred to the workers.  Since
    % MATLAB uses save/load to transfer data between workers, we need to
    % force the constructor to be executed during load by defining the class
    % with ConstructOnLoad attribute.
    properties (Access = private, Transient)
        % Header CRC generator
        HeaderCRCGen
        % Header CRC detector
        HeaderCRCDec
        % Data CRC generator
        DataCRCGen
        % Data CRC detector
        DataCRCDec
        % Convolutional code for both header and data
        HeaderConvCode
        % Interleaver indices for header
        HeaderIntrlvVec
        % Interleaver indices for data
        DataIntrlvVec
        % 16-QAM modulator
        Modulator
        % 16-QAM demodulator
        Demodulator
        % Pulse shaping filter
        PulseShapeFilter
        % Pulse shaping filter delay
        FilterDelay
        % Equalizer
        Equalizer
        % Number of burst symbols
        NumBurstSymbols
        % Number of received samples
        NumReceivedSymbols
        % Number of received samples
        NumReceivedSamples
        % Channel
        Channel
        % Signal power
        SignalPower
        % Start sample number for part 1 of the burst
        Part1Start
        % End sample number for part 1 of the burst
        Part1End
        % Start sample number for part 2 of the burst
        Part2Start
        % End sample number for part 2 of the burst
        Part2End
        % Header decoder traceback length
        HeaderTracebackLength
        % Data decoder traceback length
        DataTracebackLength
    end
    
    %=====================================================================
    % Public methods
    methods
        function this = EGPRS2UBS7(varargin)
            %EGPRS2UBS7 Construct an EGPRS2 UBS-7 system
            %   EGPRS2UBS7 constructs an EGPRS2UBS7 object
            
            if nargin > 0
                % There are input arguments, so initialize with
                % property-value pairs.
                initPropValuePairs(this, varargin{:});
            end
            this.Description = 'EGPRS Phase 2 UBS-7 Logical Channel';
            
            % Determine number of symbols in a burst
            this.NumBurstSymbols = (this.NumTailSymbols + ...
                this.NumEncodedSymbols + this.NumTrainSymbols + ...
                this.NumEncodedSymbols + this.NumTailSymbols + ...
                this.NumGuardSymbols);
            
            % Determine number of received samples to pass to the next stage
            this.NumReceivedSymbols = (this.NumTailSymbols ...
                + this.NumEncodedSymbols + this.NumTrainSymbols ...
                + this.NumEncodedSymbols + this.NumTailSymbols + 4);
            
            % Determine the boundaries of the payload for equalization
            this.Part1Start = this.NumTailSymbols + this.NumEncodedSymbols ...
                + this.NumTrainSymbols;
            this.Part1End = 1;
            this.Part2Start = this.NumTailSymbols + this.NumEncodedSymbols + 1;
            this.Part2End = this.Part2Start + this.NumTrainSymbols ...
                + this.NumEncodedSymbols + this.NumTailSymbols - 1;
            
            % Header CRC generator
            this.HeaderCRCGen = crc.generator(...
                'Polynomial', [1 0 1 0 0 1 0 0 1], ...
                'FinalXOR', [1 1 1 1 1 1 1 1]);
            % Header CRC detector
            this.HeaderCRCDec = crc.detector(this.HeaderCRCGen);
            
            % Data CRC generator
            this.DataCRCGen = crc.generator(...
                'Polynomial', [1 1 1 0 1 0 0 1 1 0 0 0 1], ...
                'FinalXOR', [1 1 1 1 1 1 1 1 1 1 1 1]);
            % Data CRC detector
            this.DataCRCDec = crc.detector(this.DataCRCGen);
            
            % Convolutional code for both header and data
            this.HeaderConvCode = poly2trellis(this.ConstraintLength, ...
                [this.G4 this.G7 this.G5]);
            this.HeaderTracebackLength = this.NumHeaderBits + 8;
            this.DataTracebackLength = 5 * this.ConstraintLength;
            
            % Interleaver indices for header
            this.HeaderIntrlvVec = genInterleaver(this, 'header');
            % Interleaver indices for data
            this.DataIntrlvVec = genInterleaver(this, 'data');

            % 16-QAM modulator
            this.Modulator = modem.genqammod('Constellation', ...
                this.Constellation, 'InputType', 'Bit');
            % 16-QAM demodulator
            this.Demodulator = modem.genqamdemod(this.Modulator);
            this.Demodulator.DecisionType = 'Approximate LLR';
            
            % Initialize the channel to the default value.  Setting the
            % property executes the set method.
            this.ChannelType = this.ChannelType;
            
            % Create a DFE filter with RLS adaptive algorithm
            hAlg = rls(this.EqualizerForgettingFactor);
            this.Equalizer = dfe(this.EqualizerNumForwardTaps, ...
                this.EqualizerNumFeedbackTaps, ...
                hAlg, this.Modulator.Constellation);
            
            % Create a pulse shaping filter and normalize maximum response to 1
            c0 = commEGPRSWidePulse(this.SamplesPerSymbol);
            this.PulseShapeFilter = dfilt.dffir(c0/max(c0));

            % Initialize properties that depend on the number of samples
            % per symbol.  Setting the SamplesPerSymbol property executes
            % the set method. 
            this.SamplesPerSymbol = 4;
        end
        %-----------------------------------------------------------------------
        function setup(this)
            %SETUP   Get test parameter values from the test console
            %   SETUP(HEGPRS2) gets the test parameter values from the
            %   attached test console and readies the EGPRS2 UBS-7 system,
            %   HEGPRS2, for a simulation run. This method is called by the
            %   test console to set the test parameter values to their
            %   current sweep point values.
            %
            %   Code that needs to be run before each sweep parameter point can
            %   be called in this method.
            %
            %   See also EGPRS2UBS7            

            % Setup SNR
            this.SNR = getTestParameter(this,'SNR');
            
            % Setup SamplesPerSymbol
            this.SamplesPerSymbol= getTestParameter(this,'SamplesPerSymbol');

            % Setup channel type
            this.ChannelType = getTestParameter(this,'ChannelType');
            
            % Setup equalizer parameters
            this.EqualizerForgettingFactor = ...
                getTestParameter(this,'EqualizerForgettingFactor');
            this.EqualizerNumForwardTaps = ...
                getTestParameter(this,'EqualizerNumForwardTaps');
            this.EqualizerNumFeedbackTaps = ...
                getTestParameter(this,'EqualizerNumFeedbackTaps');

            % Setup equalizer delay
            this.EqualizerDelay = ...
                getTestParameter(this,'EqualizerDelay');
        end    
        %-----------------------------------------------------------------------
        function run(this)
            %RUN    Run the EGPRS2 UBS-7 system for one iteration
            %   RUN(HEGPRS2) runs the EGPRS2 UBS-7 system, HEGPRS2, for one
            %   iteration. 
            %
            %   This method is called by the test console during a
            %   simulation. However, it can be called from the command line
            %   in debug mode.
            %
            %   Example: 
            %       % Create an EGPRS2 UBS-7 system 
            %       h = EGPRS2UBS7
            %       % Change the number of forward filter taps to 15
            %       h.EqualizerNumForwardTaps = 15; 
            %       % Run one iteration simulation to make sure that the 
            %       % system runs without errors 
            %       run(h)
            %
            %   See also EGPRS2UBS7            

            % Generate header and data bits
            d = randi([0 1], this.NumDataBits, 1);
            
            % Distribute header and data bits
            [h i1 i2] = distributeBits(this, d);
            setTestProbeData(this, 'TxHeaderBits', h);
            setTestProbeData(this, 'TxData1Bits', i1);
            setTestProbeData(this, 'TxData2Bits', i2);
            
            % Header coding
            hi = encodeHeader(this, h);
            setTestProbeData(this, 'TxHeaderCRC', 0);
            
            % Encode data
            di = encodeData(this, i1, i2);
            setTestProbeData(this, 'TxDataCRC', 0);
            
            % Map encoded data to bursts
            e = mapToBursts(this, hi, di);
            
            % Create channel bursts
            bursts = createChannelBursts(this, e);
            
            % Modulate bursts
            [sHat s] = modulateBursts(this, bursts);

            % Upsample and filter
            y = filter(this.PulseShapeFilter, ...
                upsample(sHat, this.SamplesPerSymbol));
            
            % Simulate channel effects
            r = simulateChannel(this, y);
           
            % Match filter and down sample
            yR = filter(this.PulseShapeFilter, r);
            sHatR = yR(2*this.FilterDelay+1:this.SamplesPerSymbol:...
                this.NumReceivedSamples+2*this.FilterDelay, :);
            
            % Derotate, equalize, and demodulate
            eR = demodulate(this, sHatR, s);
            
            % Demap from bursts
            [hiR diR] = demapFromBurst(this, eR);
            
            % Decode header
            [bR headerErrorFlag] = decodeHeader(this, hiR);
            setTestProbeData(this, 'RxHeaderBits', bR);
            
            % Decode data
            [i1R i2R dataErrorFlag] = decodeData(this, diR);
            setTestProbeData(this, 'RxData1Bits', i1R);
            setTestProbeData(this, 'RxData2Bits', i2R);
            
            % Frame error processing
            setTestProbeData(this, 'RxHeaderCRC', headerErrorFlag);
            if headerErrorFlag
                setTestProbeData(this, 'RxDataCRC', headerErrorFlag);
            else
                setTestProbeData(this, 'RxDataCRC', dataErrorFlag);
            end                
        end
        %-----------------------------------------------------------------------
        function displayChannelTypes(this)
            %displayChannelTypes Display available channel types
            %
            %   See also EGPRS2UBS7            
            
            % Display available channel types in a four column format
            for p=1:length(this.ChannelTypeEnums)/4
                fprintf(1, '''%s''\t''%s''\t''%s''\t''%s''\n', ....
                    this.ChannelTypeEnums{(p-1)*4+1:p*4})
            end
            for q=p*4+1:length(this.ChannelTypeEnums)
                fprintf(1, '''%s''\t', this.ChannelTypeEnums{q})
            end
            fprintf('\n')
        end
    end
    
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function register(this)
            %REGISTER Register test parameters, test probes, and test inputs
            %   REGISTER(HEGPRS2) registers test parameters and test probes
            %   for EGPRS2 UBS-7 system, HEGPRS2.  
            %
            %   This EGPRS2 UBS-7 implementation registers test parameters
            %   and test probes but does not use inputs from a test
            %   console.  If we want to use one, we can register the input
            %   in this method.
            
            % Register test parameters.  Use the current property values as
            % default values.
            registerTestParameter(this, 'SNR', this.SNR, [-50 100]);
            
            registerTestParameter(this, 'ChannelType',...
                this.ChannelTypeEnums{1}, this.ChannelTypeEnums);
            
            registerTestParameter(this, 'SamplesPerSymbol', ...
                this.SamplesPerSymbol, [1 100]);
            
            registerTestParameter(this, 'EqualizerForgettingFactor', ...
            this.EqualizerForgettingFactor, [0 1]);
        
            registerTestParameter(this, 'EqualizerNumForwardTaps', ...
                this.EqualizerNumForwardTaps, [1 100]);
            
            registerTestParameter(this, 'EqualizerNumFeedbackTaps', ...
                this.EqualizerNumFeedbackTaps, [0 100]);
            
            registerTestParameter(this, 'EqualizerDelay', ...
                this.EqualizerDelay, [0 100]);
            
            
            % Register probes to log transmitted and receievd header CRC value
            registerTestProbe(this, 'TxHeaderCRC');
            registerTestProbe(this, 'TxDataCRC');
            
            % Register probes to log transmitted and received header CRC value
            registerTestProbe(this, 'RxHeaderCRC');
            registerTestProbe(this, 'RxDataCRC');
            
            % Register a probe to log transmitted and received header bits
            registerTestProbe(this,'TxHeaderBits')   
            registerTestProbe(this,'RxHeaderBits') 
            
            % Register a probe to log transmitted and received data part 1 bits
            registerTestProbe(this,'TxData1Bits')   
            registerTestProbe(this,'RxData1Bits') 
            
            % Register a probe to log transmitted and received data part 2 bits
            registerTestProbe(this,'TxData2Bits')   
            registerTestProbe(this,'RxData2Bits') 
        end                        
    end
    
    %===========================================================================
    % Private methods
    methods (Access = private)
        function intrlvVec = genInterleaver(this, type)
            %genInterleaver Generate interleaver indices
            %   V = genInterleaver(HEGPRS2, TYPE) returns an interleaver
            %   vector, V, of type, TYPE, for the EGPRS2 UBS-7 system,
            %   HEGPRS2.  TYPE can be 'header' or 'data'.
            
            if strncmpi(type, 'header', 4)
                Nc = this.HeaderInterleaverNc;
                a = this.HeaderInterleaverA;
            else
                Nc = this.DataInterleaverNc;
                a = this.DataInterleaverA;
            end                
            
            B = @(k)(2*mod(k,2)+floor(mod(k,4)/2));
            k = 0:Nc-1;
            jj = Nc*B(k)/4 + mod((floor(k/4) + floor(Nc/16)*B(k))*a, Nc/4);
            intrlvVec(k +1) = jj +1;
        end
        %-----------------------------------------------------------------------
        function [h i1 i2] = distributeBits(this, d)
            %distributeBits Distribute header and data bits
            %   [H I1 I2] = distributeBits(HEGPRS2, B) distributes bits, B, into
            %   header bits, H, data part 1 bits, I1, and data part 2 bits,
            %   I2, for the EGPRS2 UBS-7 system, HEGPRS2.
            
            % Assign header bits
            h = d(1:this.NumHeaderBits);

            % Information part 1
            i1 = d(this.NumHeaderBits+1:this.NumHeaderBits+this.NumInfoBits);

            % Information part 2
            i2 = d(this.NumHeaderBits+this.NumInfoBits+1:this.NumDataBits);
        end            
        %-----------------------------------------------------------------------
        function hi = encodeHeader(this, h)
            %encodeHeader Encode the header bits
            %   HI = encodeHeader(HEGPRS2, H) encodes header bits, H, for
            %   the EGPRS2 UBS-7 system, HEGPRS2, and returns the encoded
            %   bits, HI.  Header encoding involves CRC encoding,
            %   convolutional coding, and interleaving.
            
            % Add CRC to the header
            bHeader = generate(this.HeaderCRCGen, h);

            % First append last 6 bits to the beginning.
            c = [bHeader(end-(this.ConstraintLength-2):end); bHeader];

            % Encode the appended block with a regular convolutional encoder
            C = convenc(c, this.HeaderConvCode);

            % Discard the encoded bits resulted from the first 6 appended bits
            pc = C((this.ConstraintLength-1)*this.RateInverse+1:end);

            % Interleave coded header bits
            hi = intrlv(pc, this.HeaderIntrlvVec);
        end
        %-----------------------------------------------------------------------
        function di = encodeData(this, i1, i2)
            %encodeData Encode data bits
            %   DI = encodeHeader(HEGPRS2, I1, I2) encodes data part 1
            %   bits, I1, and data part 2 bits, I2, for the EGPRS2 UBS-7
            %   system, HEGPRS2, and returns the encoded bits, DI.  Data
            %   encoding involves CRC encoding, convolutional coding,
            %   puncturing, and interleaving.
            
            % Add parity bits to the first part
            b1 = generate(this.DataCRCGen, i1);
            % Convolutionally encode the first part
            c = [b1; zeros(6,1)];
            c1 = convenc(c, this.HeaderConvCode, this.PuncturePattern);
            
            % Add parity bits to the second part
            b2 = generate(this.DataCRCGen, i2);
            % Convolutionally encode the first part
            c = [b2; zeros(6,1)];
            c2 = convenc(c, this.HeaderConvCode, this.PuncturePattern);
            
            % Interleave coded data bits
            dc = [c1; c2];
            di = intrlv(dc, this.DataIntrlvVec);
        end
        %-----------------------------------------------------------------------
        function e = mapToBursts(this, hi, di)
            %mapToBursts Map bits to bursts
            %   E = mapToBursts(HEGPRS2, HI, DI) maps encoded header bit,
            %   HI, and encoded data bits, DI, to four bursts, for the
            %   EGPRS2 UBS-7 system, HEGPRS2.  Four burst are returned in a
            %   matrix, E, where each column is a burst.
            
            % Straightforward mapping.  Each column represents a burst.  Note
            % that, MATLAB arrays start with index 1.
            
            q = zeros(8,1);
            e = zeros(552,4);

            for B=0:3
                e(this.j0, B +1) = di(514*B+this.j0);
                e(this.j1, B +1) = hi(36*B+this.j1-258);
                e(this.j2, B +1) = q(2*B+this.j2-276);
                e(this.j3, B +1) = hi(36*B+this.j3-260);
                e(this.j4, B +1) = di(514*B+this.j4-38);
            end
            
            % Bit swapping
            dummy = e(240+this.kSwap, :);
            e(240+this.kSwap, :) = e(258+this.kSwap, :);
            e(258+this.kSwap, :) = dummy;
        end
        %-----------------------------------------------------------------------
        function bursts = createChannelBursts(this, e)
            %createChannelBursts Create channel bursts
            %   B = createChannelBursts(HEGPRS2, E) creates channel bursts,
            %   B, from bursts, E, by adding tail and training bits, for
            %   EGPRS2 UBS-7 system, HEGPRS2. 
            
            % Create four bursts with tail and training bits.  Each column
            % represents a burst. 
            bursts = [repmat(this.TailBits, 1, 4); ...
                e(1:276, :); ...
                repmat(this.TrainingBits, 1, 4); ...
                e(277:552, :); ...
                repmat(this.TailBits, 1, 4); zeros(10*this.BitsPerSymbol, 4)];
        end
        %-----------------------------------------------------------------------
        function [sHat s] = modulateBursts(this, bursts)
            %modulateBursts Modulate bursts
            %   [SR S] = modulateBursts (HEGPRS2, B) modulates bursts, B,
            %   for the EGPRS2 UBS-7 system, HEGPRS2.  S contains the
            %   modulated symbols, while SR contains the modulated symbols
            %   with phase rotation applied.
            
            % Map bits to symbols
            s = modulate(this.Modulator, bursts);
            
            % Rotate the symbols pi/4 degrees continuously
            sHat = s .* exp(1i*repmat((0:this.NumBurstSymbols-1)', 1, 4)*pi/4);
        end
        %-----------------------------------------------------------------------
        function r = simulateChannel(this, y)
            %simulateChannel Simulate channel effects
            %   R = simulateChannel(HEGPRS2, Y) simulates the effects of
            %   the mobile channel for the EGPRS2 UBS-7 system.
            %   Transmitted bursts, Y, is passed through c channel filter
            %   and added AWGN, to create received bursts, R.
            
            r = zeros(this.NumBurstSymbols*this.SamplesPerSymbol,4);

            % Pass each burst from an independent channel
            for B=0:3
                yCh = filter(this.Channel, y(:,B +1));
                r(:, B +1) = awgn(yCh, this.SNR, this.SignalPower);
            end
        end
        %-----------------------------------------------------------------------
        function eR = demodulate(this, sHatR, s)
            %demodulate Demodulate symbols
            %   ER = demodulate(HEGPRS2, SR, S) demodulates received
            %   symbols, SR, for the EGPRS2 UBS-7 system, HEGPRS2.  A DFE
            %   is used for equalization, where transmitted symbols
            %   without phase rotation, S, are used to train the equalizer.
            %   Equalized symbols are then demodulated to obtain, ER.
            
            % Remove phase rotation
            sR = sHatR .* ...
                exp(-1i*repmat((0:this.NumReceivedSymbols-1)', 1, 4)*pi/4);
            
            eR = zeros(552, 4);

            for B=0:3
                % First part.  Start by resetting the equalizer
                reset(this.Equalizer)
                % Equalize from middle to start
                [sModR dummy er] = equalize(this.Equalizer, ...
                    sR(this.Part1Start-this.EqualizerDelay:-1:this.Part1End, ...
                    B +1), ...
                    s(this.Part1Start:-1:this.Part1Start-31+1, B +1)); %#ok<ASGLU>
                % Estimate noise at the output of the equalizer
                this.Demodulator.NoiseVariance = ...
                    var(er(this.NumTrainSymbols+1:this.NumTrainSymbols ...
                    + this.NumEncodedSymbols));
                % Soft demodulate
                eR(1:276, B +1) = demodulate(this.Demodulator, ...
                    sModR(this.NumTrainSymbols+this.NumEncodedSymbols...
                    :-1:this.NumTrainSymbols+1));
                
                % Second part.  Start by resetting the equalizer
                reset(this.Equalizer)
                % Equalize from middle to start
                [sModR a er] = equalize(this.Equalizer, ...
                    sR(this.Part2Start+this.EqualizerDelay:this.Part2End...
                    +this.EqualizerDelay, B +1), ...
                    s(this.Part2Start:this.Part2Start+31, B +1)); %#ok<ASGLU>
                % Estimate noise at the output of the equalizer
                this.Demodulator.NoiseVariance = var(er(this.NumTrainSymbols...
                    +1:this.NumTrainSymbols+this.NumEncodedSymbols));
                % Soft demodulate
                eR(277:552, B +1) = demodulate(this.Demodulator, ...
                    sModR(this.NumTrainSymbols+1:this.NumTrainSymbols...
                    +this.NumEncodedSymbols));
            end
        end
        %-----------------------------------------------------------------------
        function [hiR diR] = demapFromBurst(this, eR)
            %demapFromBurst Obtain header and data bits from bursts
            %   [HIR DIR] = demapFromBurst(HEGPRS2, ER) extracts header
            %   bits, HIR, and data bits, DIR, from the demodulated bursts,
            %   ER, for the EGPRS2 UBS-7 system, HEGPRS2.
            
            % Bit unswapping
            dummy = eR(240+this.kSwap, :);
            eR(240+this.kSwap, :) = eR(258+this.kSwap, :);
            eR(258+this.kSwap, :) = dummy;
            
            diR = zeros(940,1);
            hiR = zeros(40,1);
            qR = zeros(8,1);

            % Straightforward demapping
            for B=0:3
                diR(514*B+this.j0) = eR(this.j0, B +1);
                hiR(36*B+this.j1-258) = eR(this.j1, B +1);
                qR(2*B+this.j2-276) = eR(this.j2, B +1);
                hiR(36*B+this.j3-260) = eR(this.j3, B +1);
                diR(514*B+this.j4-38) = eR(this.j4, B +1);
            end
        end
        %-----------------------------------------------------------------------
        function [bR headerErrorFlag] = decodeHeader(this, hiR)
            %decodeHeader Decode received header
            %   [B ERR] = decodeHeader(HEGPRS2, HEADER) decodes received
            %   header bits, HEADER, for the EGPRS2 UBS-7 system, HEGPRS2.
            %   The decoded bits, B, are returned together with a flag,
            %   ERR.  If ERR is FALSE, then the header CRC check was
            %   successful.  Otherwise, the decoded header bits have errors.
            
            % Deinterleaving
            pcR = deintrlv(hiR, this.HeaderIntrlvVec);
            
            % Determine the final state, which is the same as initial state
            [cR metric states inputs] = vitdec(pcR, this.HeaderConvCode, ...
                this.HeaderTracebackLength, 'cont', 'unquant'); %#ok<ASGLU>
            % Decode using the determined initial state
            cR = vitdec(...
                [pcR; zeros(this.HeaderTracebackLength*this.RateInverse,1)], ...
                this.HeaderConvCode, this.HeaderTracebackLength, 'cont', ...
                'unquant', metric, states, inputs);
            cR = cR(this.HeaderTracebackLength+1:end, 1);
            
            % Detect if there was an error using the CRC
            [bR headerErrorFlag] = detect(this.HeaderCRCDec, cR);
        end
        %-----------------------------------------------------------------------
        function [i1R i2R dataErrorFlag] = decodeData(this, diR)
            %decodeData Decode received data
            %   [I1 I2 ERR] = decodeData(HEGPRS2, DATA) decodes received
            %   data bits for the EGPRS2 system, HEGPRS2.  Decoded data
            %   bits for part 1 and part 2 are returned in I1 and I2,
            %   respectively.  Also an error flag, ERR, is returned.  If
            %   either of the parts is in error, then ERR is set to TRUE. 
            
            % Deinterleaving
            dcR = deintrlv(diR, this.DataIntrlvVec);
            
            % Get part 1 and 2 of the data
            c1R = dcR(1:1028, 1);
            c2R = dcR(1029:end, 1);
            
            % Convolutional decoding for first part
            b1R = vitdec(c1R, this.HeaderConvCode, this.DataTracebackLength, ...
                'term', 'unquant', this.PuncturePattern);
            % Parity bits for first part
            [i1R errorFlag1] = detect(this.DataCRCDec, b1R(1:462));

            % Convolutional decoding for second part
            b2R = vitdec(c2R, this.HeaderConvCode, this.DataTracebackLength, ...
                'term', 'unquant', this.PuncturePattern);
            % Parity bits for second part
            [i2R errorFlag2] = detect(this.DataCRCDec, b2R(1:462));
            
            dataErrorFlag = errorFlag1 || errorFlag2;
        end
    end

    %===========================================================================
    % Private Static methods
    methods (Access = private, Static)
        function puncPat = calculatePuncturePattern
            %calculatePuncturePattern Calculate puncturing pattern for data
            
            puncPat = ones(1404,1);
            j=[4 8 10 14 20 23 25 29 30];
            for k=0:41
                puncPat(33*k+j +1) = 0;
            end
            puncPat(33*42+[4 8 10 14] +1) = 0;
            puncPat(33*[6 12 18 24 30 36]+20 +1) = 1;
        end
    end
    
    %===========================================================================
    % Set/Get Methods
    methods
        function set.SNR(this, val)
            propName = 'SNR';
            validateattributes(val, {'numeric'},...
                {'finite', 'real', 'scalar'}, ...
                [class(this) propName], propName);
            
            this.SNR = val;
        end
        %-----------------------------------------------------------------------
        function set.ChannelType(this, val)
            propName = 'ChannelType';
            validatestring(val, this.ChannelTypeEnums, ...
                [class(this) propName], propName); %#ok<*MCSUP>

            switch val
                case 'gsmRA250_6c1', 
                    mobileSpeed = 250000;
                    chanType = 'gsmRAx6c1';
                case 'gsmRA250_4c2', 
                    mobileSpeed = 250000;
                    chanType = 'gsmRAx4c2';
                case 'gsmHT50_12c1',
                    mobileSpeed = 50000;
                    chanType = 'gsmHTx12c1';
                case 'gsmHT50_12c2', 
                    mobileSpeed = 50000;
                    chanType = 'gsmHTx12c2';
                case 'gsmHT50_6c1', 
                    mobileSpeed = 50000;
                    chanType = 'gsmHTx6c1';
                case 'gsmHT50_6c2', 
                    mobileSpeed = 50000;
                    chanType = 'gsmHTx6c2';
                case 'gsmTU3_12c1', 
                    mobileSpeed = 3000;
                    chanType = 'gsmTUx12c1';
                case 'gsmTU3_12c2', 
                    mobileSpeed = 3000;
                    chanType = 'gsmTUx12c2';
                case 'gsmTU3_6c1', 
                    mobileSpeed = 3000;
                    chanType = 'gsmTUx6c1';
                case 'gsmTU3_6c2', 
                    mobileSpeed = 3000;
                    chanType = 'gsmTUx6c2';
                case 'gsmEQ100_6', 
                    mobileSpeed = 100000;
                    chanType = 'gsmEQx6';
                case 'gsmTI3_2', 
                    mobileSpeed = 250000;
                    chanType = 'gsmTIx2';
                case '3gppTU3', 
                    mobileSpeed = 3000;
                    chanType = 'gsmTUx';
               case '3gppRA250', 
                    mobileSpeed = 250000;
                    chanType = 'gsmRAx';
               case '3gppHT50'
                    mobileSpeed = 50000;
                    chanType = 'gsmHTx';
                case 'gsmTU50_6c1', 
                    mobileSpeed = 50000;
                    chanType = 'gsmTUx6c1';
            end
            
            maxDopplerShift = (mobileSpeed/3600)*this.Fc/3e8;

            this.Channel = stdchan(this.TSymbol/this.SamplesPerSymbol, ...
                maxDopplerShift, chanType);
            
            this.ChannelType = val;
        end
        %-----------------------------------------------------------------------
        function set.SamplesPerSymbol(this, val)
            propName = 'SamplesPerSymbol';
            validateattributes(val, {'numeric'},...
                {'positive', 'integer','finite', 'real', 'scalar'}, ...
                [class(this) propName], propName);
            
            % Updated channel parameters
            this.Channel.InputSamplePeriod = this.TSymbol / val;

            % Update number of received samples
            this.NumReceivedSamples = this.NumReceivedSymbols * val;

            % Create a pulse shaping filter and normalize maximum response to 1
            c0 = commEGPRSWidePulse(val);
            this.PulseShapeFilter.Numerator = c0/max(c0);
            this.FilterDelay = (length(c0) - 1)/2;

            % Calculate signal power
            this.SignalPower = ...
                10*log10((sum(this.PulseShapeFilter.Numerator.^2)*...
                mean(abs(this.Constellation).^2))/val);
        end
        %-----------------------------------------------------------------------
        function set.EqualizerForgettingFactor(this, val)
            propName = 'EqualizerForgettingFactor';
            validateattributes(val, {'numeric'},...
                {'nonnegative', '<=', 1, 'real', 'scalar'}, ...
                [class(this) propName], propName);

            % Update equalizer parameters
            this.Equalizer.ForgetFactor = val;
        end
        %-----------------------------------------------------------------------
        function set.EqualizerNumForwardTaps(this, val)
            propName = 'EqualizerNumForwardTaps';
            validateattributes(val, {'numeric'},...
                {'positive', 'finite', 'real', 'scalar'}, ...
                [class(this) propName], propName);

            this.Equalizer.nWeights= [val this.EqualizerNumFeedbackTaps];
        end
        %-----------------------------------------------------------------------
        function set.EqualizerNumFeedbackTaps(this, val)
            propName = 'EqualizerNumFeedbackTaps';
            validateattributes(val, {'numeric'},...
                {'nonnegative', 'finite', 'real', 'scalar'}, ...
                [class(this) propName], propName);
            
            this.Equalizer.nWeights= [this.EqualizerNumForwardTaps val];
        end
        %-----------------------------------------------------------------------
        function set.EqualizerDelay(this, val)
            propName = 'EqualizerDelay';
            validateattributes(val, {'numeric'},...
                {'nonnegative', '<=',this.EqualizerNumForwardTaps, ...
                'real', 'scalar'}, ...
                [class(this) propName], propName);
            
            % This property effects other properties. Request a reset before
            % run.
            this.EqualizerDelay = val;
        end
    end
end
