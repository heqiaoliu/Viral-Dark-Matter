function Ncycles_final = computeSineSettleCycles(A,B,C,Ts,gap_desired,wvec,varargin)
%computeSineSettleCycles Compute the number of cycles to drive a linear
%system to steady state.
%
%  Ncycles_nominated = utComputeSineSettleCycles(SYS,THRESH,W)computes an
%  approximation of the time required for the system SYS to converge to a
%  steady state response for a sinusoidal input at frequency W.  Steady
%  state is defined by the time t > Tss where |y(t) - yss(t)| < THRESH.
%
%  Ncycles_nominated = utComputeSineSettleCycles(SYS,THRESH,W,BW)computes an
%  approximation of the time required for the system SYS to converge to a
%  steady state response for a sinusoidal input at frequency W.  Steady
%  state is defined by the time t > Tss where |y(t) - yss(t)| < THRESH
%  while ignoring frequency components in y(t) less then BW.  BW is
%  specified in rad/s.

%   Author: John Glass
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2009/06/11 16:08:51 $

if nargin == 7
    cutoff_factor = varargin{1};
else
    cutoff_factor = inf;
end

Ncycles_final = zeros(size(wvec));
if isempty(A)
    return;
end

% Get the block diagonal factorization after pre-scaling the system
[T,At_full,BLK] = bdschur(A);

% Transform the system
Bt_full = T\B;
Ct_full = C*T;

for ct = 1:numel(wvec)
    w = wvec(ct);
    % Compute the gap for this frequency taking the maximum
    % for MIMO cases.
    thresh = gap_desired(:,:,ct);
    thresh = max(thresh(:));
    % Protect against zero threshold, taking %1 of the input
    % amplitude
    if thresh == 0
        thresh = obj.Amplitude*0.01;
    end    
    
    % Compute the initial settle time
    quarter_cycle_t = pi/(2*w);
    
    % Compute term ((A-j*w*I)^-1 * b + (A+j*w*I)^-1 * b) / 2.  Use the real
    % case to ensure that the scaling can be correlated to G(jw).
    At = At_full; Bt = Bt_full; Ct = Ct_full;
    if Ts
        R = ((At-exp(1j*w*Ts)*eye(size(At)))\Bt+(At-exp(-1j*w*Ts)*eye(size(At)))\Bt)/2;
    else
        R = ((At-1j*w*eye(size(At)))\Bt+(At+1j*w*eye(size(At)))\Bt)/2;
    end
    
    % Eliminate terms specified in cutoff_factor by block.  Also determine if a
    % block is complex.
    blk_offset = 0;
    indkeep = true(size(At,1),1);
    
    % Remove frequencies below w/cutoff_factor
    for blk_ct = 1:numel(BLK)
        blk_ind = blk_offset+(1:BLK(blk_ct));
        wn = damp(At(blk_ind,blk_ind),Ts);
        indkeep(blk_ind) = wn > w/cutoff_factor;
        blk_offset = blk_offset + BLK(blk_ct);
    end
    
    At = At(indkeep,indkeep);
    R = R(indkeep,:);
    Ct = Ct(:,indkeep);
    
    % Compute the state transition matrix
    if Ts
        k = floor(quarter_cycle_t/Ts);
        M = At^k;
    else
        M = expm(At*quarter_cycle_t);
    end
    Ncycles = 1;
    Mrolling = M*R;
    fy = @(Mrolling)abs(Ct)*abs(Mrolling);
    
    % Step forward in time by 1/4 cycle increments until the system has settled
    isSettled = false;
    while ~isSettled
        if any(any(fy(Mrolling) >= thresh))
            Ncycles = Ncycles + 1;
            Mrolling = M*Mrolling;
        else
            Ncycles_nominated = Ncycles;
            Mrolling_test = Mrolling;
            isHit = false;
            % Step four 1/4 cycles to ensure that we don't have a false trigger
            % of settling.
            for ct_test = 1:8
                Mrolling_test = M*Mrolling_test;
                if any(any(fy(Mrolling_test) >= thresh))
                    isHit = true;
                end
            end
            % If there are not any hits then we are settled
            if ~isHit
                isSettled = true;
            else
                Ncycles = Ncycles + 1;
                Mrolling = M*Mrolling;
            end
        end
    end
    Ncycles_final(ct) = ceil(Ncycles_nominated/4);
end


