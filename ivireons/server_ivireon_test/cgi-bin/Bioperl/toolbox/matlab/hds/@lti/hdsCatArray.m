function sys = hdsCatArray(dim,varargin)
%HDSCATARRAY  Horizontal or vertical array concatenation.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:15:04 $
sys = stack(dim,varargin{:});