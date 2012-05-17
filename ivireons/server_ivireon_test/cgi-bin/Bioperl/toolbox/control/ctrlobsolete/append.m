function [aa,bb,cc,dd] = append(a1,b1,c1,d1,a2,b2,c2,d2)
%APPEND  Appends model inputs and outputs. 
%
%   M = APPEND(M1,M2, ...) constructs the aggregate model
% 
%                 [ M1  0  .. 0 ]
%             M = [  0  M2      ]
%                 [  :      .   ]
%                 [  0        . ]
%
%   by concatenating the input and output vectors of the models M1, M2,... 
%   APPEND takes any combination of input/output model types (see
%   INPUTOUTPUTMODEL for an overview of available types). 
%
%   If M1,M2,... are arrays of models, APPEND returns a model array M of 
%   the same size where 
%      M(:,:,k) = APPEND(M1(:,:,k),M2(:,:,k),...) .
%
%   See also INPUTOUTPUTMODEL/BLKDIAG, SERIES, PARALLEL, FEEDBACK, INPUTOUTPUTMODEL.

% Old help
%APPEND Append together the dynamics of two state-space systems.
%	[A,B,C,D] = APPEND(A1,B1,C1,D1,A2,B2,C2,D2)  produces an aggregate
%	state-space system consisting of the appended dynamics of systems
%	1 and 2.  The resulting system is:
%	         .
%	        |x1| = |A1 0| |x1| + |B1 0| |u1|
%	        |x2|   |0 A2| |x2| + |0 B2| |u2|
%
%	        |y1| = |C1 0| |x1| + |D1 0| |u1|
%	        |y2|   |0 C2| |x2| + |0 D2| |u2|
%
%	See also: SERIES, FEEDBACK, CLOOP, PARALLEL.

%   Copyright 1986-2009 The MathWorks, Inc.
% 	$Revision: 1.1.8.4 $  $Date: 2010/03/31 18:13:14 $

if nargin~=8,
   error('Wrong number of input arguments for obsolete matrix-based syntax.')
end
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
error(abcdchk(a1,b1,c1,d1));
error(abcdchk(a2,b2,c2,d2));

[aa,bb,cc,dd] = ssdata(append(ss(a1,b1,c1,d1),ss(a2,b2,c2,d2)));

