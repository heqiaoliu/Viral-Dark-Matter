function p = propstoadd(this,varargin)
%PROPSTOADD   

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:41:48 $

p = fieldnames(this);

% Remove the ResponseType
p(1) = [];

% [EOF]
