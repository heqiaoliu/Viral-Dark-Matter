function updatePropertyDb(this)
%UPDATEPROPERTYDB 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/01/25 22:47:53 $

propNames = {'ColorMap', 'Color'};
figureProps = cell2struct(get(this.Application.Parent, propNames), propNames, 2);

setPropValue(this, 'FigureProperties', figureProps);

% [EOF]
