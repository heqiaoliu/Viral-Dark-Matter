function updateColorMap(this, eventStruct) %#ok
%UPDATECOLORMAP Set new color map and scaling parameters into scope
%  Sets image datatype conversion handler, and colormap scaling.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/03/31 18:43:20 $

this.ColorMap.DataType         = this.DataType;
this.ColorMap.isIntensity      = this.isIntensity;
this.VideoInfo.DisplayDataType = this.ColorMap.DisplayDataType;

% [EOF]
