function Hd = maxflat(this, varargin)
%MAXFLAT   Design a FIR maximally flat filter.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:30:42 $

Hd = design(this, 'maxflat', varargin{:});
