function initApproximateLLR(h, M, symbolMapping)
% INITAPPROXIMATELLR initialize/pre-compute properties required for
% Approximate LLR computation

%   @modem/@qamdemod

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:15:25 $

% clear private properties used for LLR computations
clearLLRPrivProps(h);

nBits = log2(M);

% convert SymbolMapping into binary form
binMapping = de2bi(symbolMapping(:), 'left-msb');
% compute PrivS0 and PRIVS1
[PrivS0, varNotUsed] = find(binMapping == 0); %#ok
[PrivS1, varNotUsed] = find(binMapping == 1); %#ok

if (mod(nBits,2) == 0) && ~strcmpi(h.SymbolOrder, 'user-defined')
    % Square QAM & Binary/Gray mapping - use optimized algorithm

    %---------------------------------------
    % compute secondary constellation - start
    nPtsPerRail = 2^(nBits/2);
    nBinsPerRail  = 2*nPtsPerRail;

    % here 0.5=minDist/4=2/4
    tmpConstPtsR = -((nBinsPerRail/2)-1+0.5):1:(nBinsPerRail/2)-1+0.5;
    tmpConstPtsI = ((nBinsPerRail/2)-1+0.5):-1:-((nBinsPerRail/2)-1+0.5);
    tmpConstellation = complex((tmpConstPtsR'*ones(1,length(tmpConstPtsR)))', ...
                                tmpConstPtsI'*ones(1,length(tmpConstPtsR)));
    % rotate to account for phaseOffset
    tmpConstellation = exp(i*h.PhaseOffset) * tmpConstellation;
    % compute secondary constellation - end
    %---------------------------------------
        
    % Call CPP-mex function to compute private props PrivMinIdx0 and PrivMinIdx1
    % returned values - privMinIdx0 & privMinIdx1 - are int32 matrices
    % 'PrivS0' and 'PrivS1' are converted to int32 as the core CPP function
    % uses them as int32_T. To convert them from ML indices to C/CPP indices,
    % 1 is subtracted.
    [privMinIdx0, privMinIdx1] = initApproxLLR_QAM(M, ...
                                                   log2(M), ...
                                                   tmpConstellation, ...
                                                   h.Constellation, ...
                                                   int32(symbolMapping), ...
                                                   int32(PrivS0-1), ...
                                                   int32(PrivS1-1));

    % convert to double and store for later use
    privMinIdx0 = double(privMinIdx0(:));
    privMinIdx1 = double(privMinIdx1(:));
    setPrivProp(h, 'PrivMinIdx0', privMinIdx0);
    setPrivProp(h, 'PrivMinIdx1', privMinIdx1);
    
else
    % Cross QAM or (Square QAM & User-defined mapping) - use non-optimized
    % algorithm
    setPrivProp(h, 'PrivS0', PrivS0);
    setPrivProp(h, 'PrivS1', PrivS1);
end

%--------------------------------------------------------------------
% [EOF]