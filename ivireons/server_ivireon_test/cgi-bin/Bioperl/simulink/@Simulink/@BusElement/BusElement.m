function h = BusElement
% SIMULINK.BUSELEMENT  Object to describe elements of bus signal
%
%   SIMULINK.BUSELEMENT calls the default constructor which returns an object with:
%   - Name:           'a'
%   - DataType:       'double'
%   - Complexity:     'real'
%   - Dimensions:     1
%   - DimensionsMode: 'Fixed'
%   - SamplingMode:   'Sample based'
%   - SampleTime:     -1
%
%   You can configure the object properties after instantiation.
%
% See also: BUSEDITOR, SIMULINK.BUS

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/21 22:00:24 $

h = Simulink.BusElement;
