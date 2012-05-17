function enableSpecChange(this, dlgSrc, widgetVal) 
% enableSpecChange

%  Author(s): John Glass
%  Revised:
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:18 $
if widgetVal
    this.Data.SCDEnableBlockLinearizationSpecification = 'on';
else
    this.Data.SCDEnableBlockLinearizationSpecification = 'off';
end

this.refresh(dlgSrc);