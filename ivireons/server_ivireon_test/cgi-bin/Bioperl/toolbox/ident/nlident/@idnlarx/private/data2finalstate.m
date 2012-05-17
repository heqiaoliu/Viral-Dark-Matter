function X = data2finalstate(sys,u,y,x0)
%DATA2FINALSTATE map I/O data to value of final states.
% States should be interpreted to be at time sample after the latest time
% for which data is supplied.
%
% Calling Syntax:
%   XFINAL = DATA2FINALSTATE(SYS, U, Y, X0)
%
%   X0: state values at time 0. X0 is optional (default zeros). Note that
%   X0 need not be the time corresponding to the time values of the first
%   sample in provided data vectors (U, Y).
%
%   Y: NsampU-by-ny matrix; 
%   U: NsampY-by-nu matrix; where [ny, nu] = size(SYS).
%   Nsamp* can be less than or greater than the number of model states. U
%   and Y have values for increasing time i.e., the last sample is the most
%   recent. 
%
%   NOTE: This is an internal function, not intended for users. Use
%   data2state instead.
%
% See also idnlarx/data2state, idnlarx/findstates, idnlarx/getDelayInfo.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:11:19 $

% get channel delay related information from the model
Delays = getDelayInfo(sys);
Nx = sum(Delays);             % number of states
cumDel = cumsum(Delays)+1;
CumInd = [1,cumDel(1:end-1)]; 
[ny, nu] = size(sys);

if nargin<4 || (ischar(x0) && strncmpi(x0,'z',1))
    x0 = zeros(Nx,1);
elseif ~isequal(size(x0),[Nx,1])
    ctrlMsgUtils.error('Ident:analysis:data2stateX0Size',Nx)
end

X = x0;
Nr = size(y,1);  
if Nr==0
    return;
end

for k = 1:ny
    maxdelk = Delays(k);
    if maxdelk>0 %otherwise no state for this output
        Len = min(maxdelk,Nr)-1;
        X(CumInd(k):CumInd(k)+Len,1) = y(end:-1:end-Len,k);
    end
end


Nr = size(u,1);  
if Nr==0
    return;
end

for k = 1:nu
    maxdelk = Delays(ny+k);
    if maxdelk>0 %otherwise no state for this input
        Len = min(maxdelk,Nr)-1;
        X(CumInd(ny+k):CumInd(ny+k)+Len,1) = u(end:-1:end-Len,k);
    end
end
