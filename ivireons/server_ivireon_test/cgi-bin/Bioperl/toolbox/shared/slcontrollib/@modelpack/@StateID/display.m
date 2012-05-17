function display(this)
% DISPLAY Show object properties in a formatted form

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2006/09/30 00:25:20 $

ws = warning('off', 'modelpack:AbstractMethod');
lw = lastwarn;

str = sprintf('\nState Identifier Objects:\n-------------------------');

for ct = 1:numel(this)
  h    = this(ct);
  name = modelpack.strdisp( h.getFullName );

  str = sprintf( '%s\n(%d) State ''%s'' has the following properties:', ...
                 str, ct, name );
  str = sprintf( '%s\n     Dimensions: %s', str, mat2str(h.getDimensions) );
  str = sprintf( '%s\n    Sample time: %s', str, mat2str(h.getTs) );

  str = sprintf('%s\n ', str);
end

disp(str)

warning(ws);
lastwarn(lw);
