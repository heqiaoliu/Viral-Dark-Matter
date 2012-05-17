function K = state2customreg(obj,CumInd,Nx,nu,ny)
% Compute the selector matrix that maps a subset of model
% states and inputs ([X;U]) to the custom regressor's Arguments.
%
% obj: Custom regressor object for which the selector matrix is bein
% computed.
% CumInd: cumulative delay (on output and input variables vertically
% stacked) indices for the idnlarx model to which this regressor belongs.
% Note that computation of K is relative to a state vector defined for a
% particular idnlarx model.
%
% See also idnlarx/state2stdreg, utEvalCustomReg.

% Written by: Rajiv Singh
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:18:22 $

% States: [y1(t-1), y1(t-2),...
%          y2(t-1), y2(t-2),...
%          ...
%          u1(t-1), u1(t-2),...
%          u2(t-1), u2(t-2),...
%          ...
%         ]

Ind = obj.ChannelIndices; % correspond to order: [y1,y2,..,u1,u2,..]
K = zeros(numel(Ind),Nx+nu);
Del = obj.Delays;

for i = 1:numel(Ind)
    if Del(i)==0
        % must be one of the inputs 
        K(i,Nx+Ind(i)-ny) = 1;
    else
        % must be a state
        K(i,CumInd(Ind(i))+Del(i)-1) = 1;
    end
end
