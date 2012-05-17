function axesBtnDownFunction(this,ax,type)
% Axes button down function for all axes in IDNLHW plot. Store the handle
% of the source axes.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/08/01 12:22:54 $

this.Current.AxesHandles.(type) = ax;
