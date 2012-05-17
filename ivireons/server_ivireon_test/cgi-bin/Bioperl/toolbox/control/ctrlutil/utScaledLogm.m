function [m,exitflag] = utScaledLogm(a)
% Matrix logarithm with pre-scaling.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/02/08 22:30:12 $
[s,~,a] = mscale(a,'noperm','safebal');
sw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
[m,exitflag] = logm(a);
m = lrscale(m,s,1./s);
