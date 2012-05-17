function handle=safe_get_handle(pathname)

% Copyright 1990-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2008/01/15 19:02:31 $

try
    handle=get_param(pathname,'handle');
catch Mex %#ok<NASGU>
    handle=0;
end
    