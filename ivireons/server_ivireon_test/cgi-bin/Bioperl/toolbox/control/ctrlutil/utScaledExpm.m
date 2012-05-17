function m = utScaledExpm(a)
% Matrix exponential with pre-scaling.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2006/12/27 20:34:39 $
[s,junk,a] = mscale(a,'noperm','safebal');
m = lrscale(expm(a),s,1./s);