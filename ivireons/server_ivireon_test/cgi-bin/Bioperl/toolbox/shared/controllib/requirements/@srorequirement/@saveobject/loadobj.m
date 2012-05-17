function this = loadobj(savedData)
%LOADOBJ

% Author(s): A. Stothert 04-Apr-2005
%   Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:37 $

if exist(savedData.class,'class')
   %Recreate class
   this = feval(savedData.class);
   this.loadObject(savedData);
else
   %Cannot recreate class, return generic object
   this = savedData;
end
