function WS = findParametersWS(this, names)
% FINDPARAMETERSWS Finds what workspace (model vs. base) parameters should be
% resolved in.
%
% NAMES can contain expressions such as: K, P(2), C{3}, S.a(1), etc.
%
% WS is a cell array of strings with components: 'base', 'model'.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:39:30 $

model = this.Name;

% Set default workspace to 'base'
WS    = cell( size(names) );
WS(:) = {'base'};

% Find parameters that live in the 'model' workspace
s    = whos( get_param( model, 'ModelWorkspace' ) );
vars = modelpack.varnames(names);
InMWS = ismember( vars, {s.name} );
WS(InMWS) = {'model'};
