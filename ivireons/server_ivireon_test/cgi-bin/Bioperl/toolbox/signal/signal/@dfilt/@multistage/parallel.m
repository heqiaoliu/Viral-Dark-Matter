function Hd = parallel(varargin)
%PARALLEL Connect filters in parallel.
%   Hd = parallel(Hd1,Hd2,...) is equivalent to Hd=dfilt.parallel(Hd1,Hd2,...).
%   The block diagram looks like:
%
%           |->  Hd1 ->|
%      x ---|          |--> y
%           |->  Hd2 ->|
%                ...
%           |->  Hdn ->|
%
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:19:14 $

Hd = dfilt.parallel(varargin{:});