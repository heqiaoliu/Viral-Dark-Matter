function y = filter(varargin)
%FILTER Discrete-time filter.
%   Y = FILTER(Hd,X) filters the data X using the discrete-time filter Hd.
%
%   Y = FILTER(Hd,X,DIM) filters array X along dimension DIM.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/08/05 19:00:47 $

y = super_filter(varargin{:});
