function p = thisprops2add(this,varargin)
%THISPROPS2ADD   

%   Author(s): V. Pellissier
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:36:33 $

p = fieldnames(this);

% Remove the ResponseType, NormalizedFrequency and Fs properties.
p(1:3) = [];

% Remove privFracdelay
p(end) = [];

% [EOF]
