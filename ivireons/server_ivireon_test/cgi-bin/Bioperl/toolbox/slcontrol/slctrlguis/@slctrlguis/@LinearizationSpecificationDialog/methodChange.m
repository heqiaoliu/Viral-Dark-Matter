function methodChange(this, dlgSrc, widgetVal) 
% methodChange

%  Author(s): John Glass
%  Revised:
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:22 $

if widgetVal == 0
    this.Data.SCDBlockLinearizationSpecification.Type = 'Expression';
else
    this.Data.SCDBlockLinearizationSpecification.Type = 'Function';
end

this.refresh(dlgSrc);