function p = thisprops2add(this,varargin)
%THISPROPS2ADD   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:28:06 $

p = propstoadd(this);

% Remove the NormalizedFrequency and Fs properties.
p(1:2) = [];


% [EOF]
