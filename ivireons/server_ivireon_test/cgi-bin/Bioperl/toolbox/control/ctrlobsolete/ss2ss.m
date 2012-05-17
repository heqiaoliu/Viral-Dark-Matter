function [at,bt,ct,dt] = ss2ss(a,b,c,d,t)
%SS2SS  Change of state coordinates for state-space models.
%
%   SYS = SS2SS(SYS,T) performs the similarity transformation z = Tx on 
%   the state vector x of the state-space model SYS. The resulting 
%   state-space model is described by:
%
%               .       -1        
%               z = [TAT  ] z + [TB] u
%                       -1
%               y = [CT   ] z + D u
%
%   or, in the descriptor case,
%
%           -1  .       -1        
%       [TET  ] z = [TAT  ] z + [TB] u
%                       -1
%               y = [CT   ] z + D u  .
%
%   SS2SS is applicable to both continuous- and discrete-time models. 
%   For arrays of state-space models SYS, the transformation T is applied
%   to each individual model in the array.
%
%   See also CANON, BALREAL, SS.

% Old help 
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%SS2SS Similarity transform.
%	[At,Bt,Ct,Dt] = SS2SS(A,B,C,D,T) performs the similarity 
%	transform z = Tx.  The resulting state space system is:
%
%		.       -1        
%		z = [TAT  ] z + [TB] u
%		       -1
%		y = [CT   ] z + Du
%
%	See also: CANON,BALREAL and BALANCE.

%	Clay M. Thompson  7-3-90
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.4 $  $Date: 2010/03/31 18:13:35 $
if nargin>0 && ~isnumeric(a)
   ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','ss2ss',class(a))
end
error(nargchk(5,5,nargin));
error(abcdchk(a,b,c,d));

at = t*a/t; bt = t*b; ct = c/t; dt = d;
