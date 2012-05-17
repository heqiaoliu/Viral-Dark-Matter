function setAliases(this, aliases)
% SETALIASES sets the aliases for the individual elements of the state
% identified by THIS.
%
% A single string can be used to assign the same alias to each element.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/11/09 21:01:23 $

% Create a default alias string if no alias is specified.
if (nargin < 2 || isempty(aliases)), aliases = ''; end

numAliases = prod(this.getDimensions);

% If a single string is specified
if ischar(aliases)
  % Apply it to all the channels
  temp(1:numAliases) = {aliases};
  this.Aliases = temp(:);
elseif ( length(aliases(:)) == numAliases )
  % The length of the alias strings match the number of channels
  this.Aliases = aliases(:);
else
  % Report mismatch error
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end
