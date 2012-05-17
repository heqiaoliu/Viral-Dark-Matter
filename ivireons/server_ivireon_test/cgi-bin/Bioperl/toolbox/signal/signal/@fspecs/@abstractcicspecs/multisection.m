function [Hm,meas] = multisection(this,M,R)
%CICDESIGN   Shared design gateway for CICDECIM/CICINTERP.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/18 14:26:00 $

do = this.getdesignobj('multisection');

Hdo = feval(do);

Hm = design(Hdo,this,R,M);

% [EOF]
