function A = getArray(this)
%GETARRAY  Reads array value.
%
%   Array = GETARRAY(ValueArray)

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/12/14 14:55:38 $

A = getArray(this.Storage,this.Variable);

% Set the sample size
s = size(A);
if length(s)>=2
    this.SampleSize = [s(2) 1];
else
    this.SampleSize = s(2:end);
end

% If a time vector is returned as a cell array of datestrs it must be
% converted to numerical form and the metadata assigned accordingly.
% In effect we are performing a setAbsTime with the time being defined 
% by the data src
if strcmpi(this.Variable.Name,'Time') && iscell(A) && ishandle(this.MetaData)
    ref = A{1};
    A = datenum(A);
    A = A-A(1);
    % Update time metadata start and end times
    this.MetaData.getData(A);
    % Overwrite other metadata props
    set(this.MetaData,'Startdate',ref,'Units','days','Format','datestr');
elseif ishandle(this.MetaData)
   % Update time metadata start and end times. Note "End" is a 
   % private property so we can't do the update here
   this.MetaData.getData(A);
else
   error('timeseriesSrcArray:getArray:noMetaData',...
       'Metadata property is empty. A meta data object must be assigned to this property before it can be read.')
end

