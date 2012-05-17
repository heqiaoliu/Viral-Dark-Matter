function [val, loc] = pctdemo_aux_gop_minloc(inval)
%PCTDEMO_AUX_GOP_MINLOC Find minimum value of a variant and its labindex.
%   [val, loc] = pctdemo_aux_gop_minloc(inval) returns to val the minimum value
%   of inval across all the labs.  The labindex where this minimum value
%   resides is returned to loc.

%   Copyright 2007 The MathWorks, Inc.

    out = gop(@iMinLoc, {inval, labindex*ones(size(inval))});
    val = out{1};
    loc = out{2};
end

function out = iMinLoc(in1, in2)
% Calculate the min values and their locations.  Return them as a cell array.
    in1Smallest = (in1{1} < in2{1});
    minVal = in1{1};
    minVal(~in1Smallest) = in2{1}(~in1Smallest);
    minLoc = in1{2};
    minLoc(~in1Smallest) = in2{2}(~in1Smallest);
    out = {minVal, minLoc};
end
