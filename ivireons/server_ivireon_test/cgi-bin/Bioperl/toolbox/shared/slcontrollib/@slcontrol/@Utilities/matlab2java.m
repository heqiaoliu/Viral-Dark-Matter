function javaData = matlab2java(this, matlabData)
% MATLAB2JAVA Convert two dimensional cell arrays to Java arrays
%
% matlab2java(data)

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2008/10/31 06:58:38 $

if ~iscell(matlabData) || isempty(matlabData)
  javaData = javaArray('java.lang.Object', 1, 1);
  return
end

% Initialize java objects
sizes    = size(matlabData);
javaData = javaArray('java.lang.Object',  sizes);

for i = 1:sizes(1)
  for j = 1:sizes(2)
    current = matlabData{i,j};

    if isempty(current)
      % Don't do anything.  
    elseif ischar(current)
      javaData(i,j) = java.lang.String(current);
    elseif islogical(current)
      javaData(i,j) = java.lang.Boolean(current);
    elseif isa(current, 'double')
      javaData(i,j) = java.lang.Double(current);
    elseif ishandle(current)
      javaData(i,j) = java(current);
    else
      ctrlMsgUtils.error( 'SLControllib:general:InvalidArgument', ...
                          'DATA', 'matlab2java', 'slcontrol.Utilities.matlab2java');
    end
  end
end
