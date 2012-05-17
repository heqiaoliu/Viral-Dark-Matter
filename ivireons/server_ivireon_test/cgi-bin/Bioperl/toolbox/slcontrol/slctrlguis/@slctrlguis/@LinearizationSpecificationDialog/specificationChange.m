function specificationChange(this, dlgSrc, widgetVal) 
% specificationChange

%  Author(s): John Glass
%  Revised:
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:31 $

this.Data.SCDBlockLinearizationSpecification.Specification = widgetVal;
this.refresh(dlgSrc);