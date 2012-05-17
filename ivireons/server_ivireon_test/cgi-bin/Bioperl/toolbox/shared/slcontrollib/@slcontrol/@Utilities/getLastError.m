function msg = getLastError(this, ME)
% Extracts error message from LASTERROR or MException, ME, by stripping off
% the path from it.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2010/01/25 22:41:27 $

if (nargin < 2), ME = lasterror; end

[head, msg] = strtok( ME.message, sprintf('\n') );
if isempty(msg)
  msg = head;
end

% ME argument needed since lasterror does not contain causes.
if (nargin > 1)
  for k = 1:length(ME.cause)
    [h,m] = strtok( ME.cause{k}.message, sprintf('\n') );
    if isempty(m)
      m = h;
    end
    msg = sprintf('%s\n     %s', msg, m);
  end
end
