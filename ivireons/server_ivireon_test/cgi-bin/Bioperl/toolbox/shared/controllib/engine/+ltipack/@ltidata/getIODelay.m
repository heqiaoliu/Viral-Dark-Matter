function iod = getIODelay(D,totalflag)
%GETIODELAY  Extracts I/O delay data.
%
%   IOD = getIODelay(D) returns the I/O delay matrix.
%   For state-space models, getIODelay tests if internal 
%   delays are equivalent to I/O delays and returns the
%   equivalent I/O delay or NaN for each I/O pair.
% 
%   IOD = getIODelay(D,'total') returns the total I/O delay 
%   including the input and output delays.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:14 $
iod = D.Delay.IO;  % default implementation
if nargin>1
   [ny,nu] = size(iod);
   iod = iod + D.Delay.Input(:,ones(1,ny)).' + D.Delay.Output(:,ones(1,nu));
end
