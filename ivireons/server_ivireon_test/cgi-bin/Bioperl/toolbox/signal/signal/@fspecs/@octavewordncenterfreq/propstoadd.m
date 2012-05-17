function p = propstoadd(this,varargin)
%PROPSTOADD   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:26:34 $

p = fieldnames(this);

% Remove the ResponseType
p(1) = [];

% Remove privLthOctave
p(end) = [];

% [EOF]
