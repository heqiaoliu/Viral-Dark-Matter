function ts1 = timestamp(Model)
% TIMESTAMP Retrieve information about when a model was created.
%
%   ts = TIMESTAMP(Model);
%
%   ts is returned as a string that gives information about when Model 
%   was created,and when it was last modified.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2006/12/27 21:01:12 $

try
    ts = timemark(Model, 'g');
catch
    ts = '';
end
if nargout
    ts1 = ts;
else
    disp(ts);
end

% FILE END