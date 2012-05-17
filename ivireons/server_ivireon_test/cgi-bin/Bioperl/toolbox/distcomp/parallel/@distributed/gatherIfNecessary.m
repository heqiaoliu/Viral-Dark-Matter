function argsCell = gatherIfNecessary( varargin )
;%#ok undocumented

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/12/29 02:00:17 $

argsCell = varargin;
for ii=1:length( argsCell )
    if isa( argsCell{ii}, 'distributed' )
        argsCell{ii} = gather( argsCell{ii} );
    end
end
end
