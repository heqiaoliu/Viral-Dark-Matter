function y = utEvalCustomReg(sys, u, cumDel, Nx, Ny, ynum)
%Evaluate all custom regressors for ynum'th output
%   This function is a used by nonlinear ARX model block in Simulink; 
%   sys: idnlarx model
%
%   states: current value of all states
%   u:      current value of all inputs and states = [states,inputs]
%   cumDel: cumulative channel-wise delay on variables [y1,y2,..,u1,u2,..]
%   Ny:     number of outputs
%   ynum: output number (useful for multi-output models).

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:17:10 $


% states: y1(t-1), y1(t-2),... y1(t-n1),
%         y2(t-1), y2(t-2),... y2(t-n2),
%         u1(t-1), u1(t-2),... u1(t-m1),
%         u2(t-1), u2(t-2),... u2(t-m2), etc

% channel delays: [n1, n2,..., m1, m2,...]
% cumulative sum of channel delays: cumDel (starts at 0).

% Algorithm:
% A custom regressor input ("Arguments") maps to either a state or one of
% the current inputs. Process:
%   1. Read ChannelIndices from a regressor
%   2. For a given ChannelIndex: I = ChannelIndex(i), find out
%      corresponding delay: Del = Delays(i);
%   3. If I<=Ny || Del ~=0, value = states [cumDel(I) + Del];
%      If I>Ny && Del==0, value = u [I-Ny];
%

states = u(1:Nx);
u = u(Nx+1:end);
if nargin<6
    ynum = 1;
end

cust = sys.CustomRegressors; 
if Ny>1
    cust = cust{ynum};
end
Ncust = numel(cust);
y = zeros(Ncust,1);
for k = 1:Ncust
    thisreg = cust(k);
    
    % parse Arguments of thisreg
    L = length(thisreg.Arguments);
    inputCell = cell(1,L);
    for i = 1:L
        I = thisreg.ChannelIndices(i);
        Del = thisreg.Delays(i);
        if (I<=Ny || Del~=0)
            inputCell{i} = states(cumDel(I) + Del);
        else
            inputCell{i} = u(I-Ny);
        end
    end
    %inputCell
    y(k) = thisreg.Function(inputCell{:}); % scalar
end
