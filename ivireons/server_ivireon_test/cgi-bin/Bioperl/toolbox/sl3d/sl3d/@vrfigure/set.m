function set(vrfig, varargin)
%SET Set a virtual reality figure property.
%   SET(F, PROPNAME, PROPVALUE) sets a specified property PROPNAME
%   of the virtual reality figure F to given value PROPVALUE.
%
%   SET(F, PROPNAME, PROPVALUE, PROPNAME, PROPVALUE, ...)
%   changes the given set of properties of the figure.
%
%   See VRFIGURE/GET for a detailed list of world properties.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2009/05/07 18:29:23 $ $Author: batserve $


% use this overloaded SET only if the first argument is of type VRFIGURE
if ~isa(vrfig, 'vrfigure')
  builtin('set', vrfig, varargin{:});
  return;
end

% prepare pair of cell array of names and arguments
[propname, propval] = vrpreparesetargs(numel(vrfig), varargin, 'property');

% create the renamed properties table
renametbl = { 'InfoStrip', 'StatusBar';
              'PanelMode', 'NavPanel';
              'Title',     'Name';
            };

% loop through vrfigures
for i=1:size(propval, 1)
  fh = vrfig(i).handle;
  fig = vrfig(i).figure;
  % loop through property names
  for j=1:size(propval, 2)
    val = propval{i, j};
    % handle the renamed properties
    newname = renametbl(strcmpi(propname{j}, renametbl(:,1)), 2);
    if ~isempty(newname)
      newname = newname{1};
      warning('VR:obsoleteproperty', 'The property "%s" has been renamed to "%s". The old name still works, but will stop working in future releases.', ...
            propname{j}, newname);
      propname{j} = newname;
    end
    switch lower(propname{j})
        % 'World', 'Handle'
      case {'world', 'handle' }
        error('VR:propreadonly', 'Figure property ''%s'' is read-only.', propname{j});
      otherwise
        if fig == 0
          % vrsfunc handles errors automatically
          if fh ~= 0
            vrsfunc('SetFigureProperty', fh, propname{j}, val);
          end
        else
          % MATLAB figure mode
          set(fig, propname{j}, val);
        end
    end
  
  
  end %end for2

end %end for1

