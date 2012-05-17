function display(this)
% DISPLAY Formatted display of object properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/12/14 15:01:33 $

str = sprintf('\nParameter Value Objects:\n------------------------');

for ct = 1:numel(this)
  h = this(ct);

  name = modelpack.strdisp( h.Name );
  id   = h.getID;
  if ~isempty(id) && ~isempty(id.getPath)
    str = sprintf( '%s\n(%d) Parameter ''%s'' in ''%s'':', ...
                   str, ct, name, id.getPath );
  else
    str = sprintf( '%s\n(%d) Parameter ''%s'':', str, ct, name );
  end

  str = sprintf( '%s\n    Dimensions: %s', str, mat2str(h.getDimensions) );
  str = sprintf( '%s\n         Value: %s', str, LocalMat2Str(h.Value, 4) );

  str = sprintf('%s\n', str);
end

disp(str)

% --------------------------------------------------------------------------
function str = LocalMat2Str(value, N)
try
  str = mat2str(value, N);
catch
  s1  = regexprep( num2str(size(value)), ' *', 'x' );
  str = sprintf('[%s %s]', s1, class(value));
end
