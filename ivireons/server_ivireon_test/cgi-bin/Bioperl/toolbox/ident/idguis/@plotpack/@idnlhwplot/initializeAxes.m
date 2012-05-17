function initializeAxes(this,ax,type)
% pre-processing of a newly created plot axes

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/08/01 12:23:01 $

set(this.Figure,'CurrentAxes',ax); 
this.Current.AxesHandles.(type) = ax;
set(ax,'ButtonDownFcn',@(es,ed)this.axesBtnDownFunction(es,type));