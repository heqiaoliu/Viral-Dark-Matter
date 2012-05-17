function datatypeChanged(ntx)
% Title of axis changed, signaling a change in data type
% However, it could be a dummy title when DTX is off

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:06 $

% Reset SNR sufficient-statistics:
%fprintf('Resetting SNR state...\n'); % xxx
ntx.SSQ        = 0;  % Sum of Squared Data (for SNR)
ntx.SSQE       = 0;  % Sum of Squared Quantization Error (for SNR)
ntx.NumSSQE    = 0;  % Independent sample count for SSQE/SNR
