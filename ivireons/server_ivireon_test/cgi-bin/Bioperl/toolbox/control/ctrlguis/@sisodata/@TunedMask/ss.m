function D = ss(this)
%SS   Get SS model of tunable model.
%
%   D = SS(MODEL) returns the @ssdata representation of MODEL.
% 

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:47:10 $
if isempty(this.SSData.d)
   % Recompute normalized state-space model
   this.SSData = ss(this.zpkdata);
end
D = this.SSData;
