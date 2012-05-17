function [val, loc] = pctdemo_aux_gop_maxloc(inval)
%PCTDEMO_AUX_GOP_MAXLOC Find maximum value of a variant and its labindex.
%   [val, loc] = pctdemo_aux_gop_maxloc(inval) returns to val the maximum value
%   of inval across all the labs.  The labindex where this maximum value
%   resides is returned to loc.

%   Copyright 2007 The MathWorks, Inc.

    out = gop(@iMaxLoc, {inval, labindex*ones(size(inval))});
    val = out{1};
    loc = out{2};
end

function out = iMaxLoc(in1, in2)
% Calculate the max values and their locations.  Return them as a cell array.
    in1Largest = (in1{1} >= in2{1});
    maxVal = in1{1};
    maxVal(~in1Largest) = in2{1}(~in1Largest);
    maxLoc = in1{2};
    maxLoc(~in1Largest) = in2{2}(~in1Largest);
    out = {maxVal, maxLoc};
end
