function setAliases(this, aliases)
% SETALIASES sets the alias of each channel of the port identified by THIS.
% The list of aliases is a flat list whose length matches the total number of
% channel associated with this port.  A single string can be used to assign
% the same alias to each channel.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:59:59 $

% Create a default alias string if no alias is specified.
if (nargin < 2 || isempty(aliases)), aliases = ''; end

% If a single string is specified
if ischar(aliases)
  % Apply it to all the channels
  len = prod(this.getDimensions);
  this.Aliases(1:len) = {aliases};
elseif (length(aliases(:)) == prod(this.getDimensions))
  % The length of the alias strings match the number of channels
  this.Aliases = aliases(:);
else
  % Report mismatch error
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end
