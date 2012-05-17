function p = thisprops2add(this,varargin)
%THISPROPS2ADD   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:26:36 $

p = fieldnames(this);

% Remove the ResponseType, NormalizedFrequency and Fs properties.
p(1:3) = [];

% Remove privFracdelay
p(end) = [];

% [EOF]
