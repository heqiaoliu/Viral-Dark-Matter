function CustRegGains = state2customreg(sys,CumInd,Nx,LenCust)
%STATE2CUSTOMREG returns a cell array of state-to-cusotmreg argument
%selector gain matrices.
% usage: CustRegGains = state2customreg(sys)
%        CustRegGains = state2customreg(sys,CumInd,Nx,LenCust)

% Written by: Rajiv Singh
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:19:05 $

error(nargchk(1, 4, nargin,'struct'))

CustReg = sys.CustomRegressors;
if ~iscell(CustReg)
    CustReg = {CustReg};
end
[ny,nu] = size(sys);

if nargin<2
    Delays = getDelayInfo(sys);
    CumInd = [1,cumsum(Delays(1:end-1))+1];
    Nx = sum(Delays); % number of states
    LenCust = zeros(1,ny);
    if ~isempty(CustReg)
        if ny==1
            LenCust = numel(CustReg);
        else
            for ky = 1:ny
                LenCust(ky) = numel(CustReg{ky});
            end
        end
    end
end

CustRegGains = cell(ny,1);
for i = 1:ny
    if LenCust(i)>0
        Ci = CustReg{i};
        CustRegGains{i} = cell(1,LenCust(i));
        for j = 1:LenCust(i)
            CustRegGains{i}{j} = state2customreg(Ci(j),CumInd,Nx,nu,ny);
        end
    end
end
