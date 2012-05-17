function javaData = matlab2java1d(this,matlabData,varargin)
% Convert one dimensional cell arrays to Java arrays
%
% matlab2java1d(data)

% Author(s): John Glass
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2007/11/09 21:02:39 $

if ~iscell(matlabData) || isempty(matlabData)
    javaData = javaArray('java.lang.Object', 1, 1);
    return
end

if nargin == 3
    arrayclass = varargin{1};
else
    arrayclass = 'java.lang.Object';
end

% Initialize java objects
sizes    = length(matlabData);
javaData = javaArray(arrayclass,  sizes);

for ct = 1:sizes(1)
    current = matlabData{ct};

    if ischar(current)
        javaData(ct) = java.lang.String(current);
    elseif islogical(current)
        javaData(ct) = java.lang.Boolean(current);
    elseif isa(current, 'double')
        javaData(ct) = java.lang.Double(current);
    elseif ishandle(current)
        javaData(ct) = java(current);
    else
      ctrlMsgUtils.error( 'SLControllib:general:InvalidArgument', 'DATA', ...
                          'matlab2java1d', 'slcontrol.Utilities.matlab2java1d');
    end
end
