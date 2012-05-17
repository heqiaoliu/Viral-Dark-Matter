function alphaC = utPIDRefineAlphaC(alphaC,ssFunc)
% URPIDREFINEALPHAC  Refines critical frequencies at AlphaC
%
 
% Author(s): Rong Chen 03-Nov-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/12/04 22:21:14 $

% set PI 
valuePI = 3.1415926359;
if ~isempty(alphaC)
    % refine critical alpha to make sure they are local extrema
    % get boundary for alphaC and the corresponding r values
    rC_original = squeeze(real(freqresp(ssFunc,exp(alphaC*1i))));        
    if length(alphaC)==1
        AlphaBND = [0;valuePI];
    else
        AlphaBND = [0;diff(alphaC)/2+alphaC(1:end-1);valuePI];
    end
    rBND = squeeze(real(freqresp(ssFunc,exp(AlphaBND*1i))));
    % refine each alphaC
    options = optimset('TolFun',eps,'TolX',eps,'Display','off');
    for ct = 1:length(alphaC)
        % refine inside the boundary
        if rBND(ct)>rC_original(ct) && rBND(ct+1)>rC_original(ct)
            % minimum
            alphaC(ct) = fminbnd(@(x) real(freqresp(ssFunc,exp(x*1i))),AlphaBND(ct),AlphaBND(ct+1),options);
        elseif rBND(ct)<rC_original(ct) && rBND(ct+1)<rC_original(ct)
            % maximum
            alphaC(ct) = fminbnd(@(x) -real(freqresp(ssFunc,exp(x*1i))),AlphaBND(ct),AlphaBND(ct+1),options);
        else        
            % alpha=0 case: if r(0) is finite, we have a RRB at z=1
            if AlphaBND(ct)==0 && isfinite(real(evalfr(ssFunc,1)))
                alphaC(ct) = 0;
            % alpha=pi case: if r(pi) is finite, we have a RRB at z=-1
            elseif AlphaBND(ct+1)==valuePI && isfinite(real(evalfr(ssFunc,exp(valuePI*1i))))
                alphaC(ct) = valuePI;                
            else
                alphaC(ct) = NaN;
            end
        end
    end
    % remove fake critical alpha
    alphaC = alphaC(~isnan(alphaC));
end