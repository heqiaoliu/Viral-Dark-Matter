function name = getBlock(this)
% GETBLOCK Returns the full name of the block containing to the port
% identified by THIS.
%
% ATTN: Model name is not part of the full name.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:39 $

n = numel(this);

if n == 1
  name = LocalGetName(this);
else
  name = cell(n,1);
  for ct = 1:n
    name{ct} = LocalGetName(this(ct));
  end
end

% ----------------------------------------------------------------------------
function name = LocalGetName(h)
if ~isempty(h.Path)
  path = sprintf('%s/', h.Path);
else
  path = '';
end

% Construct the block name
name = sprintf('%s%s', path, h.Name);
