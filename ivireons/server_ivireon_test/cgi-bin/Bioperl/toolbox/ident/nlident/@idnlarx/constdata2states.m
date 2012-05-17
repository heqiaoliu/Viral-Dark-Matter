function X0 = constdata2states(sys,nu,ny,Nx,U0,Y0,MaxDelays)
% Map constant I/O values to a state vector
% MaxDelays: max delay across all outputs for channels 
%            (1-by-(ny+nu) vector)

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:18:41 $

if nargin<7
    MaxDelays = getDelayInfo(sys);
end

X0 = zeros(Nx,1);
offset = 0;
for k = 1:ny
    maxdelk = MaxDelays(k);
    if maxdelk>0 %otherwise no state for this output
        X0(offset+1:offset+maxdelk,1) = Y0(k);
        offset = offset+maxdelk;
    end
end

for k = 1:nu
    maxdelk = MaxDelays(ny+k);
    if maxdelk>0 %otherwise no state for this input
        X0(offset+1:offset+maxdelk,1) = U0(k);
        offset = offset+maxdelk;
    end
end
