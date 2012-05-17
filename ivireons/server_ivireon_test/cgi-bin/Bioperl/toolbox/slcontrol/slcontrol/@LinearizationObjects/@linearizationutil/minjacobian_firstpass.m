function J_fp = minjacobian_firstpass(this,J)
% MINJACOBIAN_FIRSTPASS Using the information from the block reduction from
% Simulink to reduce the

%  Author(s): John Glass
%  Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/03/31 00:22:16 $

% Get the block handles
BlockHandles = J.Mi.BlockHandles;

% Get the blocks that have been marked as in the path by the internal
% algorithm
BackwardMark = J.Mi.BackwardMark;
ForwardMark = J.Mi.ForwardMark;
BlocksInPath_Pass1 = ForwardMark & BackwardMark;

% Find the blocks that remain
bh = BlockHandles(BlocksInPath_Pass1);
indu = ismember(J.Mi.InputInfo(:,1),bh);
indy = ismember(J.Mi.OutputInfo(:,1),bh);

% Extract the upper parts of the LFT
J_fp.A = J.A;
J_fp.B = J.B(:,indu);
J_fp.C = J.C(indy,:);
D = J.D(:,indu);
J_fp.D = D(indy,:);
J_fp.stateName = J.stateName; 
J_fp.stateBlockPath = J.stateBlockPath; 

% Extract lower parts of the lft
E = any(J.Mi.E,3);
E = E(indu,:);
J_fp.Mi.E = E(:,indy);
F = J.Mi.F;
J_fp.Mi.F = F(indu,:);
G = J.Mi.G;
J_fp.Mi.G = G(:,indy);
J_fp.Mi.H = J.Mi.H;

% Store the delay data
J_fp.Mi.OutputDelay = J.Mi.OutputDelay(indy);

% Store the I/O Port handles
J_fp.Mi.InputPorts = J.Mi.InputPorts;
J_fp.Mi.InputName = J.Mi.InputName;
J_fp.Mi.OutputPorts = J.Mi.OutputPorts;
J_fp.Mi.OutputName = J.Mi.OutputName;

% Store sample time information
J_fp.Tsx = J.Tsx;
J_fp.Tsy = J.Tsy(indy);
J_fp.Ts = [J_fp.Tsx;J_fp.Tsy];

% Compute the IO Indices given that blocks have been removed in the first
% pass
J_fp.Mi.InputInfo = J.Mi.InputInfo(indu,:);
J_fp.Mi.OutputInfo = J.Mi.OutputInfo(indy,:);
J_fp.Mi.BlockHandles = J.Mi.BlockHandles(BlocksInPath_Pass1);
J_fp.Mi.BlockRemovalData = J.Mi.BlockRemovalData;
