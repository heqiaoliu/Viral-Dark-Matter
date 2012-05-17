function [InactiveBlocks, InactiveConnections, InactiveSignals] = findinactive(Diagram,Compidx,OLIC)
% ------------------------------------------------------------------------%
% Function:FindInactive
% Purpose: Determines inactive blocks based on the open loop loopstatus
% ------------------------------------------------------------------------%

%   Author(s): C. Buhr
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.10.1 $ $Date: 2005/11/15 00:54:43 $

BlockNums = [1:length(Diagram.B)]';

E = eye(size(OLIC));

% Note: Emod is unitary so Emod'=inv(Emod)
Emod = E([Compidx,1:Compidx-1,Compidx+1:end],:);

% Reorder blocks and block names using coordinate transformation
NewOLIC = Emod*OLIC*Emod';
NewBlockNums = Emod*BlockNums;

% Generate 
%           D | C
% NewOLIC = -----
%           B | A
%
A = NewOLIC(2:end,2:end);
B = NewOLIC(2:end,1);
C = NewOLIC(1,2:end);
D = NewOLIC(1,1);

% Compute structurally minimal realization
[an,bn,cn,en,keep] = smreal(A,B,C,[]);

% Reconstruct a min realization of OLIC and associated block names
MinOLIC = [D, cn; bn, an];

% Find inactive connectins
InactiveConnections = find(~ismember([1:length(Diagram.L)], MinOLIC));

% Find inactive blocks, note: shift to account for block associated with D matrix
InactiveBlocks = NewBlockNums(find(false == keep)+1)'; 

% Find inactive signals
Blocks = {Diagram.B(InactiveBlocks).Identifier};
Signals = {Diagram.S.Block}; 
InactiveSignals = find(ismember(Signals,Blocks) == true);
