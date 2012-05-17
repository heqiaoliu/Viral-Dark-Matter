function PadeOrder = utComputePadeOrder(this,wb)
%utComputePadeOrder Compute Pade Order based on bandwidth

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/04/21 03:08:32 $

P = this.Loopdata.Plant.getP;

if isa(P,'ltipack.ssdata') && hasdelay(P)
    Delay = P.Delay;
    % Get max delay
    T = max([Delay.Input(:);Delay.Output(:);Delay.Internal(:)]);
    
    % Find lower bound on the pade Order N
    N = ceil(exp(1)*T*wb/4)-1;
    
    % Set accuracy
    DegAccuracy = 1; % 1 degree
    delta = abs(1-exp(1i*DegAccuracy*pi/180)); % error bound
    
    % Iterate on the pade Order N 
    foundN = false;
    while ~foundN
        N=N+1;
        if (2*((exp(1)*T*wb)/4/N)^(2*N+1)) <= delta
            foundN = true;
        end
    end
    PadeOrder = N;
else
    PadeOrder = 0;
end



