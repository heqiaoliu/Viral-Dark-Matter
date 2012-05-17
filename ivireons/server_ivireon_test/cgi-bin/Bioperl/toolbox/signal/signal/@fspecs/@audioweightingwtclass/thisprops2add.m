function p = thisprops2add(this,varargin)
%THISPROPS2ADD   

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:42:19 $

p = fieldnames(this);

% Remove the ResponseType, NormalizedFrequency and Fs properties.
p(1:3) = [];

% Remove WeightingType
p(end-1) = [];

% [EOF]
