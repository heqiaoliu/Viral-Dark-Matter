function y = generate(this, data, varargin)
%GENERATE   Generate RZ modulated signal
%   GENERATE(H, DATA) modulates input data bits, DATA, using RZ modulated
%   signaling.  DATA must be a column vector with element values 0 or 1.  The
%   RZ pulse properties are defined by the RZ pulse generator object H.  
%
%   GENERATE(H, DATA, JITTER) generates RZ modulated signals as in the previous
%   case but also injects jitter.  JITTER is a column vector with of jitter
%   values.  Jitter values are normalized with sampling frequency.  The length
%   of DATA and JITTER vectors must be equal.  Jitter values must be less then
%   the symbol duration.
%
%   EXAMPLES:
%
%     % Create an RZ pulse generator object
%     h = commsrc.rz;
%     % Generate binary data
%     data = rand(20, 1) > 0.5;
%     % Generate RZ modulated signal
%     y = generate(h, data);
%     plot(y)
%
%     % Generate random jitter
%     jitter = randn(20, 1)/50;
%     % Generate RZ modulated signal and inject jitter
%     y = generate(h, data, jitter);
%     hold on; plot(y, 'r'); hold off;
%
%   See also COMMSRC.RZ, COMMSRC.RZ/DISP.

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2009/05/23 07:48:25 $

% Parse and validate input arguments
[jitter dataLen] = parseGenerateArgs(this, data, varargin{:});

% Gather needed information to generate the output
riseRate = this.RiseRate;
fallRate = this.FallRate;
onDuration = this.OnDuration;
numRiseSamps = this.NumRiseSamps;
numFallSamps = this.NumFallSamps;

% Obtain symbols from symbol numbers
onLevel = this.OutputLevels;

% Get jittered clock
[clk nClk rClk] = getJitteredClock(this, dataLen, jitter);

% Generate output.
y = zeros(nClk(end)-1, 1);
for p=1:length(clk)-1
    if data(p)
        % This is an on signal
        t1 = floor(clk(p)+numRiseSamps);  % end of the integer part of the rise time
        t2 = clk(p)+numRiseSamps+onDuration;  % end of the on time
        nt2 = floor(t2);  % integer part of the end of the on time
        rt2 = 1 - (t2 - nt2);  % fractional part of the end of the on time
        t3 = floor(clk(p)+numRiseSamps+onDuration+numFallSamps);  % end of the integer part of the fall time
        
        % Generate rise signal
        y(nClk(p)) = riseRate*rClk(p);
        for q=nClk(p)+1:t1
            y(q) = y(q-1) + riseRate;
        end
        % Generate on signal
        y(t1+1:nt2) = onLevel;
        % Generate fall signal
        y(nt2+1) = onLevel + fallRate*rt2;
        for q=nt2+2:t3
            y(q) = y(q-1) + fallRate;
        end
        % Generate off signal
        y(t3+1:nClk(p+1)-1) = 0;
    else
        % No transition
        y(nClk(p):nClk(p+1)-1) = 0;
    end
end

% Store state
this.LastJitter = jitter(end);

%---------------------------------------------------------------------------
% [EOF]