function D = zpk(this,idx)
% ZPK Compute ZPK of tuned loop

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/03/26 17:22:14 $

% Not supported for time-delays or frd

if nargin == 1
    idx = this.Nominal;
end

if hasDelay(this) || hasFRD(this)
    ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
        'The Poles and Zeros can not be computed for time-delay or frequency response data systems.')
else
    % Series portion of TunedLoop
    TunedFactors = this.TunedFactors;
    
    % LFT portion of TunedLoop
    D = getTunedLFT(this,'zpk',idx);
    
    for ct = 1:length(TunedFactors)
        D = D * zpk(TunedFactors(ct));
    end
end

