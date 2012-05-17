function [ab,bb,cb,db] = augstate(a,b,c,d)
%AUGSTATE  Appends states to the outputs of a state-space model.
%
%   ASYS = AUGSTATE(SYS)  appends the states to the outputs of 
%   the state-space model SYS.  The resulting model is:
%      .                       .
%      x  = A x + B u   (or  E x = A x + B u for descriptor SS)
%
%     |y| = [C] x + [D] u
%     |x|   [I]     [0]
%
%   This command is useful to close the loop on a full-state
%   feedback gain  u = Kx.  After preparing the plant with
%   AUGSTATE,  you can use the FEEDBACK command to derive the 
%   closed-loop model.
%
%   See also FEEDBACK, SS.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%AUGSTATE Augment states to the outputs of a state space system.
% 	[Ab,Bb,Cb,Db] = AUGSTATE(A,B,C,D) appends the states to the
%	outputs of the system (A,B,C,D).  The resulting system is:
%	         .
%	         x = Ax + Bu
%
%	        |y| = |C| x + |D| u
%	        |x|   |I|     |0|
%
%	This command prepares the plant so that the FEEDBACK command can
%	be used to form the closed loop system with a full state feedback
%	gain matrix.
%
%	See also: PARALLEL,SERIES,FEEDBACK, and CLOOP

%	Clay M. Thompson 6-26-90, AFP 12-1-95
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.4 $  $Date: 2010/02/08 22:29:57 $
if nargin>0 && ~isnumeric(a)
   ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','augstate',class(a))
end
error(nargchk(4,4,nargin));
error(abcdchk(a,b,c,d));

na = size(a,1);
[~,m] = size(b);
ab = a; bb = b;
cb = [c;eye(na)];
db = [d;zeros(na,m)];
