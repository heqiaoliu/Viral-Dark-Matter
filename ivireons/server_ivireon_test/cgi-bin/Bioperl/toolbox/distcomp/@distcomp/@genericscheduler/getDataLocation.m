function dataLocation = getDataLocation(scheduler)
%GETDATALOCATION returns the data location for the generic scheduler as a structure
%
%  DATALOCATION = GETDATALOCATION(SCHEDULER)
%
%   This function returns the data location for the generic scheduler as
%   a structure.  The structure can contain the fields 'pc' and 'unix', depending
%   on how the scheduler's data location was originally specified.  The presence
%   of these fields is not guaranteed.  
%
%   It is expected that this function will be called in the submit function.
%
%   Example:
%    % Create a generic scheduler object whose data location is a structure
%    s = findResource('scheduler', 'type', 'generic');
%    s.DataLocation = struct('pc', 'h:\data', 'unix', '/home/data');
%    % Get the scheduler's data location
%    dataLocation = s.getDataLocation;
%    % Get the UNIX data location if it exists.
%    if isfield(dataLocation, 'unix')
%       unixDataLocation = dataLocation.unix;
%    end
%

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2010/04/21 21:14:03 $

dataLocation = scheduler.pReturnStorage.getStorageLocationStruct;
