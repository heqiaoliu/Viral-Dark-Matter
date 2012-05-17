classdef IEEE80211b < testconsole.SystemBasicAPI
%IEEE80211b IEEE80211b communications system
%   This class extends the testconsole.SystemBasicAPI and implements DBPSK
%   modulation, Barker code spreading, and pulse shaping on a perfectly
%   synchronized 802.11b link and over a Rayleigh flat fading channel with
%   additive white Gaussian noise. 
%
%   The following is a list of properties of the IEEE80211b system.
%
%   IEEE80211b properties:
%
%   EsNo           - Energy per symbol to noise power spectral density ratio(*)
%   Doppler        - Rayleigh channel Doppler shift(*)
%   FilterOrder    - Root raised cosine filter order in symbols
%   RollOffFactor  - Root raised cosine filter roll off factor
%   SamplesPerChip - Number of samples per chip
%
%   (*) Also registered as test parameter
%
%   IEEE80211b methods:
%
%   run      - Run the IEEE 802.11b system for one iteration
%   reset    - Reset the IEEE 802.11b system
%   register - Register test parameters and test probes
%   setup    - Get test parameter values from the test console
%            
%   See also IEEE80211bErrorCalculator, EGPRS2UBS7, commtest.MPSKSystem, 
%            commtest.ErrorRate

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 15:57:09 $
    
    %===========================================================================
    % Define properties needed for the 802.11b system
    %===========================================================================
    %Public properties
    properties
        %EsNo   Energy per symbol to noise power spectral density ratio
        EsNo = 0;
        %Doppler Rayleigh channel Doppler shift
        Doppler = 200;
        %FilterOrder Root raised cosine filter order in symbols
        FilterOrder = 5;
        %RollOffFactor Root raised cosine filter roll off factor
        RollOffFactor = 0.7;
        %SamplesPerChip Number of samples per chip
        SamplesPerChip = 8;                                
    end
    %===========================================================================
    %Constant properties        
    properties (Hidden,Constant)
        %M      Modulation order
        %   Set to 2 since this is a DBPSK system.
        M = 2;        
        %Barker Barker sequence
        Barker = [1 -1  1  1 -1  1  1  1 -1 -1 -1]';
        %SpreadingRate Spreading rate
        SpreadingRate = 11;
        %SymbolRate Symbol rate 
        %   The 802.11b standard defines a rate of 1 Mbps
        SymbolRate = 1e6;
    end
    %===========================================================================
    %Private properties            
    properties (Access = private)
        %Mod    DPSK modulator
        Mod
        %Demod  DPSK demodulator
        Demod
        %RayleighChannel Rayleigh channel
        RayleighChannel
        %PulseShapeFdesign Pulse shape filter specs
        PulseShapeFdesign
        %RRCFilterTx Transmitter root raised cosine pulse shaping filter
        RRCFilterTx
        %RRCFilterRx Receiver root raised cosine pulse shaping filter        
        RRCFilterRx
        %RxDelayedDataBuffer Delayed received data buffer
        RxDelayedDataBuffer
        %SNR Signal to noise ratio
        SNR
        %PacketSize Packet size
        %   Length of each transmitted frame
        PacketSize
        %FirstFrameFlag First frame flag
        %   True if currently in the first frame transmission of a new
        %   simulation sweep value       
        FirstFrameFlag = false;    
        %DelayInChips Delay given in chips
        %   Delay, in chips, caused by the transmitter and receiver pulse
        %   shaping filters.
        DelayInChips
        %DelayInSamples
        DelayInSamples
        %ExtraChipDelay Extra chip delay
        %    Extra delay added to a received frame to align it to the 11 chip
        %    boundary.
        ExtraChipDelay        
        %TotalDelayInSymbols Total delay in symbols
        %    Total delay, in symbols, after the received frame has been aligned
        %    to the 11 chip boundary.
        TotalDelayInSymbols          
    end
    %===========================================================================
    % Define protected methods
    %===========================================================================
    methods (Access = protected)
        function register(obj)
            %REGISTER Register test parameters and test probes

            %Data source registration
            % Register a 'RandomIntegerSource' data source. The error rate test
            % console will provide a bit stream of length specified in its
            % FrameLength property. 
            registerTestInput(obj,'RandomIntegerSource')

            %Test parameter registration
            % Register a test parameter named 'EsNo' which corresponds to energy
            % per symbol to noise power spectral density ratio. Set its default
            % value to 0. Note that EsNo is also defined as a public property.
            registerTestParameter(obj,'EsNo',obj.EsNo);
                        
            % Register a test parameter named 'Doppler' which corresponds to the
            % Doppler shift of the Rayleigh channel. Set its default value to
            % 200 Hz and limit the sweep values to be inside the [0 500] Hz
            % range.
            registerTestParameter(obj,'Doppler',obj.Doppler,[0 500]);
            
            % Register a test parameter named 'M' which corresponds to
            % modulation order, set its default value to 2. This parameter is
            % registered to enable the system to use a RandomIntegerSource
            % source data provided by the test console. Limit the simulation to
            % M = 2 since this is strictly a DBPSK system, this is done by
            % setting the valid range vector to [2 2].
            registerTestParameter(obj,'M',obj.M,[2 2]);            
                        
            %Test probe registration
            % Register a probe named 'TxInputSymbols' to log symbol streams at
            % the transmitter input
            registerTestProbe(obj,'TxInputSymbols')
            % Register a probe named 'RxOutputSymbols' to log symbol streams at
            % the receiver output
            registerTestProbe(obj,'RxOutputSymbols')
        end   
        %=======================================================================        
        function input = generateDefaultInput(obj)
            %generateDefaultInput Generate data when in debug mode
            
            %Generate a bit stream of 8192 bits (802.11b packet size) when in
            %debug mode.
            input = randi([0 obj.M-1],8192,1);
        end
    end
    %===========================================================================
    % Define public methods
    %===========================================================================
    methods
        function obj = IEEE80211b
            %IEEE80211b Construct a IEEE80211b communications system
            
            %System description
            obj.Description = 'IEEE 802.11b physical layer';
            
            % Define a root raised cosine filter with default roll-off factor of
            % 0.7 and with an order that spans a 5 chips duration. The
            % designRRCFilters method also calculates the delays caused by the
            % filters.          
            designRRCFilters(obj);
            
            % Define a DPSK modulator and demodulator
            obj.Mod = modem.dpskmod('M', obj.M, 'InitialPhase', 0);
            obj.Demod = modem.dpskdemod('M', obj.M, 'InitialPhase', 0);
            
            % Define a Rayleigh channel            
            ts = 1/(obj.SymbolRate*obj.SpreadingRate*obj.SamplesPerChip);
            obj.RayleighChannel = rayleighchan(ts, obj.Doppler, 0, 0);
            obj.RayleighChannel.ResetBeforeFiltering = 0;
            obj.RayleighChannel.StorePathGains = 1;
                        
            % Calculate default SNR value so that the system can be run in debug
            % mode without having to call the setup method first.             
            calculateSNR(obj);
            
            % Initialize the Rx delayed data buffer so that the system can be
            % run in debug mode without having to call the reset method first. 
            obj.RxDelayedDataBuffer = zeros(obj.ExtraChipDelay,1);
        end
        %=======================================================================
        function setup(obj)
            %SETUP  Setup method for the communications system
            
            % Get the current EsNo value from the test console and calculate
            % SNR.
            obj.EsNo = getTestParameter(obj,'EsNo');
            calculateSNR(obj);
                        
            % Get the current Doppler spread value and set the Rayleigh channel
            % accordingly.
            obj.Doppler = getTestParameter(obj,'Doppler');
            obj.RayleighChannel.MaxDopplerShift = obj.Doppler;
        end
        %=======================================================================
        function reset(obj)
            %RESET  Reset communications system
            
            % Reset the modulator, demodulator, filter, and channel objects
            reset(obj.Mod)
            reset(obj.Demod)
            reset(obj.RRCFilterTx)
            reset(obj.RRCFilterRx)
            reset(obj.RayleighChannel)
            
            % reset the Rx delayed data buffer
            obj.RxDelayedDataBuffer = zeros(obj.ExtraChipDelay,1);
            
            % Set the FirstFrameFlag to true when reset is called
            obj.FirstFrameFlag = true;            
        end
        %=======================================================================
        function run(obj)
            %RUN    Run the IEEE 802.11b system for one iteration
            
            % Generate source outputs of length specified in the test console
            % FrameLength property
            txMsg = getInput(obj,'RandomIntegerSource');
            obj.PacketSize = length(txMsg);
                                               
            % Log transmitted data
            setTestProbeData(obj,'TxInputSymbols',txMsg);
            
            % Transmitter_______________________________________________________
            txSymbols = modulate(obj.Mod, txMsg);
            
            % Spread symbols with Barker code, upsampling by spreading rate.
            txChips = reshape(obj.Barker*txSymbols',[],1);
            
            % Upsample chips by SamplesPerChip factor
            txSamples = upsample(txChips,obj.SamplesPerChip);
            
            % Pulse-shape transmitted symbols
            txSamplesPulseShaped = filter(obj.RRCFilterTx,txSamples);
                        
            %Channel____________________________________________________________
            % Transmit though Rayleigh Channel with AWGN
            chOut = filter(obj.RayleighChannel,txSamplesPulseShaped);                                     
            chnlOutput  = awgn(chOut,obj.SNR,'measured');
            
            %Receiver___________________________________________________________
            
            % Filter received signal with pulse-shaping filter
            rxSamplesPulseShaped = filter(obj.RRCFilterRx,chnlOutput);
            
            % Downsample - sample chips
            rxChips = downsample(rxSamplesPulseShaped,obj.SamplesPerChip);
            
            % Add chip delay to move signal to 11 chip boundary
            rxDelayedChips = ...
                [obj.RxDelayedDataBuffer; rxChips(1:end-obj.ExtraChipDelay)];
            
            % Store delayed chips
            obj.RxDelayedDataBuffer = rxChips((end-obj.ExtraChipDelay+1):end);
            
            % Despread by multiplying by Barker sequence
            rxSymbols = obj.Barker'*reshape(rxDelayedChips, ...
                obj.SpreadingRate,obj.PacketSize);
            
            % Make a column and normalize
            rxSymbols = rxSymbols(:)/obj.SpreadingRate;
            
            % Demodulate
            rxOutput = demodulate(obj.Demod, rxSymbols);
            
            %Log received data
            setTestProbeData(obj,'RxOutputSymbols',rxOutput);
            
            % Set a structure with user data that we want to log to the test
            % console so that it can be used by the user-defined error
            % calculator function.
            userDataStruct.TxRxDelay = obj.TotalDelayInSymbols;
            userDataStruct.FirstFrameFlag = obj.FirstFrameFlag;
            
            % Log the user data
            setUserData(obj,userDataStruct);
                        
            % Set the FirstFrameFlag to false. It will be set to true the next
            % time reset is called.
            obj.FirstFrameFlag = false;            
        end
        %=======================================================================
        % Set methods 
        %=======================================================================
        function set.SamplesPerChip(obj,value)

            validateattributes(value,...
                {'numeric'},...
                {'finite','positive','scalar','integer'}, ...
                [class(obj) '.' 'SamplesPerChip'],...
                'SamplesPerChip');
            
            obj.SamplesPerChip = value;
            
            % Re-design the RRC filters
            designRRCFilters(obj)            
        end
        %=======================================================================
        function set.FilterOrder(obj,value)

            validateattributes(value,...
                {'numeric'},...
                {'finite','positive','scalar','integer'}, ...
                [class(obj) '.' 'FilterOrder'],...
                'FilterOrder');
            
            obj.FilterOrder = value;
            
            % Re-design the RRC filters
            designRRCFilters(obj)
        end        
        %=======================================================================
        function set.RollOffFactor(obj,value)

            validateattributes(value,...
                {'numeric'},...
                {'scalar','>=',0,'<=',1}, ...
                [class(obj) '.' 'RollOffFactor'],...
                'RollOffFactor');
            
            obj.RollOffFactor = value;
            
            % Re-design the RRC filters            
            designRRCFilters(obj)
        end   
    end
    %=======================================================================
    % Helper methods (private)
    %=======================================================================
    methods (Access = private)
        function designRRCFilters(obj)
            %designRRCFilters Design RRC filters
            
            obj.PulseShapeFdesign  = fdesign.pulseshaping(obj.SamplesPerChip,...
                'Square Root Raised Cosine','Nsym,Beta',...
                obj.FilterOrder,obj.RollOffFactor); 
            
            % Design the RRC filters according to the specification in the
            % PulseShapeFdesign property. Set the PersistentMemory property of
            % the filters to true so that filter states are saved at each
            % iteration.
            obj.RRCFilterTx = design(obj.PulseShapeFdesign);
            obj.RRCFilterRx = design(obj.PulseShapeFdesign);
            obj.RRCFilterTx.PersistentMemory = true;
            obj.RRCFilterRx.PersistentMemory = true;
            
            % Calculate delays caused by the filtering operations
            calculateDelays(obj);                        
        end
        %=======================================================================        
        function calculateDelays(obj)
            %Calculate delays
            %   Calculate delay due to tx-rx pulse-shaping filters.
            obj.DelayInSamples = 2*order(obj.RRCFilterTx)/2;
            obj.DelayInChips = obj.DelayInSamples/obj.SamplesPerChip;
            
            if obj.DelayInChips <= obj.SpreadingRate
                obj.ExtraChipDelay = obj.SpreadingRate - obj.DelayInChips;
            else
                obj.ExtraChipDelay  = obj.SpreadingRate - ...
                    mod(obj.DelayInChips,obj.SpreadingRate);
            end
            obj.TotalDelayInSymbols = ...
                (obj.DelayInChips + obj.ExtraChipDelay)/obj.SpreadingRate;
        end
        %=======================================================================                
        function calculateSNR(obj)
            % calculateSNR
            obj.SNR = obj.EsNo + 10*log10(1/obj.SpreadingRate) + ...
                10*log10(1/obj.SamplesPerChip);
        end        
    end
end