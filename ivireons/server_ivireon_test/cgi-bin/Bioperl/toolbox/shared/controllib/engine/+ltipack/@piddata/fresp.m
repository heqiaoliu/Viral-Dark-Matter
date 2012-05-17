function [h,InfResp] = fresp(PID,w)
% Frequency response of PID.

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:17 $

% Form vector s of complex frequencies
s = ltipack.utGetComplexFrequencies(w,PID.Ts);
% convert to internal parameterization
[P I D T] = utGetPIDT(PID);
% compute frequency response of the integrator    
[valI valD] = utGetIntFreqResp(PID, s);
% compute response of PID
h = P + I*valI + D./(T+valD);    
h = permute(h,[2 3 1]);
% extra output
if nargout>1
    InfResp = any(isinf(h));
end
