function updateSmallNegAreOverflow(ntx)
% Update state .SmallNegAreOverflow based on .OptionsRounding

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:22:13 $

% This assessment is only relevant when the unsigned format is utilized.
% Here we determine what happens to negative numbers in the interval
% (0,0.5) --- ok, really, (0,-0.5), but histograms show magnitude-only.
% This interval encompasses all histogram bins beyond the radix line except
% the [0.5,1) bin.  Negatives in interval (-0.5,-inf) all go to -1 or
% higher, and thus guarantee an overflow.  It's only (0,-0.5) that requires
% assessment based on rounding mode.
%
% The assessment is based on rounding mode, and answers: what happens to
% negative numbers in the interval (0,-0.5)?
%   1 = Ceil -> goes to 0
%   2 = Convergent -> goes to 0 (for -0.5, closest even number is 0)
%   3 = Floor -> goes to -1, thus it overflows on unsigned
%   4 = Nearest -> goes to 0 (for -0.5, rounds toward +inf)
%   5 = Round -> goes to 0 on (0,-0.5), goes to -1 on 0.5 (toward -inf for
%       negative numbers)
%   6 = Zero -> goes to 0
%
% NOTE:
%    We do not record individual values, only binned data, so we cannot
%    distinguish 0.5 (-0.5) from the rest of the (1,0.5] bin.  For values
%    that are exactly -0.5, in the "round" mode, we will INCORRECTLY
%    choose the outcome to be UNDERflow; it should be OVERflow.
%    To fix this, we could bin values that are exactly -0.5 separately.

dlg = ntx.hBitAllocationDialog;
switch dlg.BARounding
    case 3 % floor
        ntx.SmallNegAreOverflow = true;
    otherwise
        ntx.SmallNegAreOverflow = false;
end
