function y = generate(this, data, varargin)
%GENERATE   Generate NRZ modulated signal
%   GENERATE(H, DATA) modulates input data bits, DATA, using NRZ modulated
%   signaling.  DATA must be a column vector with element values 0 or 1.  The
%   NRZ pulse properties are defined by the NRZ pulse generator object H.  
%
%   GENERATE(H, DATA, JITTER) generates NRZ modulated signals as in the previous
%   case but also injects jitter.  JITTER is a column vector of real jitter
%   values.  Jitter values are normalized with sampling frequency.  The length
%   of DATA and JITTER vectors must be equal.  The difference of consecutive
%   jitter values must be less than the symbol duration. 
%
%   EXAMPLES:
%
%     % Create an NRZ pulse generator object
%     h = commsrc.nrz;
%     % Generate binary data
%     data = rand(20, 1) > 0.5;
%     % Generate NRZ modulated signal
%     y = generate(h, data);
%     plot(y)
%
%     % Generate random jitter
%     jitter = randn(20, 1)/50;
%     % Generate NRZ modulated signal and inject jitter
%     y = generate(h, data, jitter);
%     hold on; plot(y, 'r'); hold off;
%
%   See also COMMSRC.NRZ, COMMSRC.NRZ/DISP, COMMSRC.NRZ/RESET.

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2009/05/23 07:48:24 $

% Parse and validate input arguments
[jitter dataLen] = parseGenerateArgs(this, data, varargin{:});

% Gather needed information to generate the output
sqrtEps = sqrt(eps);
riseRate = this.RiseRate;
fallRate = this.FallRate;
numRiseSamps = this.NumRiseSamps;
numFallSamps = this.NumFallSamps;
high = this.HighLevel;
low = this.LowLevel;

% Append the last transmitted data symbol index to DATA
data = [this.LastData; data];

% Obtain symbols from symbol numbers
symbols = this.OutputLevels(data+1);

% Get jittered clock
[clk nClk rClk] = getJitteredClock(this, dataLen, jitter);

% Determine difference between adjacent data levels.  We will use this vector to
% decide if we have a falling transition, a rising transition, or no transition.
change = diff(symbols);

% Generate output. 
y = zeros(nClk(end)-1, 1);
for p=1:length(clk)-1
    if change(p) < -sqrtEps
        % This is a high-to-low transition
        
        % Calculate the end time of the integer part of the fall time
        t1 = floor(clk(p)+numFallSamps);
        
        y(nClk(p)) = high + fallRate*rClk(p);
        for q=nClk(p)+1:t1
            y(q) = y(q-1) + fallRate;
        end
        y(t1+1:nClk(p+1)-1) = low;
    elseif change(p) > sqrtEps
        % This is a low-to-high transition

        % Calculate the end time of the integer part of the rise time
        t1 = floor(clk(p)+numRiseSamps);
        
        y(nClk(p)) = low + riseRate*rClk(p);
        for q=nClk(p)+1:t1
            y(q) = y(q-1) + riseRate;
        end
        y(t1+1:nClk(p+1)-1) = high;
    else
        % No transition
        y(nClk(p):nClk(p+1)-1) = symbols(p+1);
    end
end

% Store state
this.LastData = data(p+1);
this.LastJitter = jitter(end);

%---------------------------------------------------------------------------
% [EOF]