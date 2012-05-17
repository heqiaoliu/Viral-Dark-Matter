function mycustomsisotoolfcn(G)
% mycustomsisotoolfcn(G)
%
% Creates the following SISO Design Tool session:
%   1) Configuration 4 with the plant specified by G
%   2) Root locus and bode editors for the outer-loop
%   3) Bode editor for the inner-loop.

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2006/01/26 01:45:48 $

% Create initialization object with configuration 4
s = sisoinit(4);

% Set the value of the plant
s.G.Value = G;

% Specify the editors for the Open-Loop Responses
s.OL1.View = {'rlocus','bode'};
s.OL2.View = {'nichols'};

sisotool(s)