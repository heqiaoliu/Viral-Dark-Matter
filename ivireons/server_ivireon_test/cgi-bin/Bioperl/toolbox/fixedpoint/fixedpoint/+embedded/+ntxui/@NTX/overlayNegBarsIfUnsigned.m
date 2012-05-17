function overlayNegBarsIfUnsigned(ntx,negVal,xp,zp)
% If negative values present while unsigned data type selected,
% overlay "overflow" type bars over normal bars, with height equal to
% negative count of the corresponding histogram bin.
%
% The decision to do this for the special case of negative values in the
% underflow region is based on .SmallNegAreOverflow, which depends on
% rounding mode.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1.2.1 $     $Date: 2010/07/06 14:39:12 $

if ~ntx.IsSigned && (ntx.DataNegCnt > 0)
    % Negative values present when using unsigned format
    % Overlay negative histogram data
    if nargin < 2
        % Get bin counts for bar display
        [~,negVal] = getBarData(ntx);
        [xp,zp] = embedded.ntxui.NTX.createXBarData(ntx.BinEdges,ntx.HistBarWidth, ntx.HistBarOffset);
    end
    
    % Bars in the underflow region should be set to zero
    if ~ntx.SmallNegAreOverflow
        % Don't show overflow bars on negative values in the magnitude
        % interval (0,0.5), or what is really (0,-0.5) for the negative
        % value considered here.  The bar [0.5,1) is always overflow.
        % 
        % BinCenters has exponents, not values, so "-1" implies 2^-1, which
        % is 0.5.
        negVal(ntx.BinEdges < -1) = 0;
    end
    
    % Setup negative-bars patch data
    N = numel(negVal);
    yp = [zeros(1,N); negVal; negVal; zeros(1,N)];
    % Set zp to be over "total" bar (which is at z=-2),
    % and below signline (which is at z=-1.9), so we set
    % z=-1.95 ... which is zp+.05, where zp=-2.
    set(ntx.hBarNeg,'vis','on', ...
        'xdata',xp,'ydata',yp,'zdata',zp+.05);
else
    set(ntx.hBarNeg,'vis','off');
end
