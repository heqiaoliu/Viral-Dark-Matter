function fr = evalfr(PID,s)
%EVALFR  Evaluates frequency response at a single (complex) frequency.

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:16 $

if isnan(s)
    fr = NaN;
else
    % convert to internal parameterization
    [P I D T] = utGetPIDT(PID);
    % compute frequency response of the integrator    
    [valI valD] = utGetIntFreqResp(PID, s);
    % compute response of PID
    fr = P+I*valI+D/(T+valD);    
end

