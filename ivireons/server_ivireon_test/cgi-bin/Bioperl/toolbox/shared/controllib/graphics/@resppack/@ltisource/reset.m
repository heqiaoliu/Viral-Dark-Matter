function reset(this,varargin)
%RESET  Clears dependent data when model changes.

%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:34 $

% REVISIT: Use direct assignments into struct when works
C = this.Cache;
for ct=1:numel(C)
   C(ct).Stable = [];
   C(ct).MStable = [];
   C(ct).DCGain = [];
   C(ct).Margins = [];
end
this.Cache = C;
