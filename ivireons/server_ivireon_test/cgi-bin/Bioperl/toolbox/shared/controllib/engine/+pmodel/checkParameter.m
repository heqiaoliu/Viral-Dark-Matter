function p = checkParameter(p,Name,Size)
% Checks that P is a parameter with the specified
% name and (optionally) size.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:36:44 $
if ~isa(p,'param.Continuous')
   ctrlMsgUtils.error('Control:pmodel:badp',Name)
elseif ~strcmp(p.Name,Name)
   ctrlMsgUtils.error('Control:pmodel:rename',Name)
end
% Optional size check
if nargin>2 && ~isequal(getSize(p),Size)
   ctrlMsgUtils.error('Control:pmodel:resize',Name)
end
% Make sure value is a full double array
p.Value = double(full(p.Value));
