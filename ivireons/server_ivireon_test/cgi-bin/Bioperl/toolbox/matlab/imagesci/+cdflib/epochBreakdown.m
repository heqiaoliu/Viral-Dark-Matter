function timev = epochBreakdown(epochTime)
%cdflib.epochBreakdown Decompose EPOCH value
%   timeVec = cdflib.epochBreakdown(epochTime) decomposes an EPOCH
%   value into individual components.  timeVec will have 7 x n elements,
%   where n is the number of epoch16 values.
%
%     timeVec(1,:)  = year AD, e.g. 1994
%     timeVec(2,:)  = month, 1-12
%     timeVec(3,:)  = day, 1-31
%     timeVec(4,:)  = hour, 0-23
%     timeVec(5,:)  = minute, 0-59
%     timeVec(6,:)  = second, 0-59
%     timeVec(7,:)  = msec, 0-999
%
%   This function corresponds to the CDF library C API routine 
%   EPOCHbreakdown.
%
%   Example:
%       timeval = [1999 12 31 23 59 59 0];
%       epoch = cdflib.computeEpoch(timeval);
%       timevec = cdflib.epochBreakdown(epoch);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.computeEpoch.


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/05/13 17:40:41 $

error ( nargchk(1,1,nargin,'struct') );
timev = cdflibmex('epochBreakdown',epochTime);
