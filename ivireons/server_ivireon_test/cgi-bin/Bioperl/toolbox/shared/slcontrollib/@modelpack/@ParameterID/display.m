function display(this)
% DISPLAY Show object properties in a formatted form

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2006/09/30 00:23:20 $

ws = warning('off', 'modelpack:AbstractMethod');
lw = lastwarn;

str = sprintf('\nParameter Identifier Objects:\n-----------------------------');

for ct = 1:numel(this)
  h    = this(ct);
  name = modelpack.strdisp( h.getFullName );

  str = sprintf( '%s\n(%d) Parameter ''%s'' has the following properties:', ...
                 str, ct, name );
  str = sprintf( '%s\n    Dimensions: %s', str, mat2str(h.getDimensions) );
  str = sprintf( '%s\n         Class: %s', str, h.getClass );

  % Show locations.
  locations = modelpack.strdisp( h.getLocations );
  if ~isempty(locations)
    str = sprintf( '%s\n     Locations: %s', str, locations{1} );
    for k = 2:length(locations)
      str = sprintf( '%s\n                %s', str, locations{k} );
    end
  end

  str = sprintf('%s\n ', str);
end

disp(str)

warning(ws);
lastwarn(lw);
