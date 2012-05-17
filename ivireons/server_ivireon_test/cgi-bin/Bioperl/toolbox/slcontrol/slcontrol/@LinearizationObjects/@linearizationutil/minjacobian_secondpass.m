function J_sp = minjacobian_secondpass(this,J)
% MINJACOBIAN_SECONDPASS This is the second pass at block reduction.

%  Author(s): John Glass
%  Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/03/31 00:22:18 $

% Extract the upper parts of the LFT
A = J.A; B = J.B; C = J.C; D = J.D;
nx = size(A,1);
nu = size(B,2);
ny = size(C,1);

% Extract lower parts of the lft
E = J.Mi.E; F = J.Mi.F; G = J.Mi.G; H = J.Mi.H;

% Extract other data
InputInfo = J.Mi.InputInfo;
BlockInputs = InputInfo(:,1);
OutputInfo = J.Mi.OutputInfo;
BlockOutputs = OutputInfo(:,1);
stateBlockPath = J.stateBlockPath;
stateName = J.stateName;
Tsx = J.Tsx;
Tsy = J.Tsy;
BlockHandles = J.Mi.BlockHandles;

% Compute the minimal realization
[Acmr,Bcmr,Ccmr,Ejunk,signalmask] = smreal_lft(this,A,B,C,D,E,F,G);

% Minimal states are both controllable and observable
StateMask = signalmask(1:nx);
OutputMask = signalmask(nx+(1:ny));
OutputBlocksHit = unique(BlockOutputs(OutputMask));
InputMask = signalmask(nx+ny+(1:nu));
InputBlocksHit = unique(BlockInputs(InputMask));

% Loop over each block to determine if it is in the list
blockmask = false(length(BlockHandles),1);

% Identify the blocks that are in the linearization path
for ct = 1:numel(BlockHandles)
    if (any(find(BlockHandles(ct) == InputBlocksHit))) && ... 
            (any(find(BlockHandles(ct) == OutputBlocksHit)));
        blockmask(ct) = true;
    end
end

% Get the signals that are not in the linearization
indx = find(StateMask); indu = find(InputMask); indy = find(OutputMask);
nx_red = length(indx);
nu_red = length(indu);
ny_red = length(indy);

A = Acmr(1:nx_red,:);
A = A(:,1:nx_red);
B = Acmr(1:nx_red,:);
B = B(:,nx_red+ny_red+(1:nu_red));
C = Acmr(:,1:nx_red);
C = C(nx_red+(1:ny_red),:);
D = Acmr(:,nx_red+ny_red+(1:nu_red));
D = D(nx_red+(1:ny_red),:);
E = Acmr(:,nx_red+(1:ny_red));
E = E(nx_red+ny_red+(1:nu_red),:);
F = Bcmr(nx_red+ny_red+(1:nu_red),:);
G = Ccmr(:,nx_red+(1:ny_red));

% Eliminate other data
InputInfo = InputInfo(indu,:);
OutputInfo = OutputInfo(indy,:);
stateBlockPath = stateBlockPath(indx);
stateName = stateName(indx);
Tsx = Tsx(indx);
Tsy = Tsy(indy);

% Store the new Jacobian data
J_sp.A = A;
J_sp.B = B;
J_sp.C = C;
J_sp.D = D;
J_sp.Mi.E = E;
J_sp.Mi.F = F;
J_sp.Mi.G = G;
J_sp.Mi.H = H;

J_sp.Mi.InputInfo = InputInfo;
J_sp.Mi.OutputInfo = OutputInfo;
J_sp.Mi.InputName = J.Mi.InputName;
J_sp.Mi.InputPorts = J.Mi.InputPorts;
J_sp.Mi.OutputName = J.Mi.OutputName;
J_sp.Mi.OutputPorts = J.Mi.OutputPorts;
J_sp.Mi.OutputDelay = J.Mi.OutputDelay(indy);
J_sp.Mi.BlockRemovalData = J.Mi.BlockRemovalData;
J_sp.Mi.BlockHandles = BlockHandles(blockmask);
J_sp.Tsx = Tsx;
J_sp.Tsy = Tsy;
J_sp.Ts =[Tsx;Tsy];
J_sp.stateBlockPath = stateBlockPath;
J_sp.stateName = stateName;
