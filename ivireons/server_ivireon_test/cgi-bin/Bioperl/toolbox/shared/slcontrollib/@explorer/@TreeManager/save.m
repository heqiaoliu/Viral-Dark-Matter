function save(this, nodes, filename)
% SAVE Saves projects into the file FILENAME.
%
% save(nodes, filename)

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2007/11/09 20:59:25 $

if isempty(filename)
  ctrlMsgUtils.error( 'SLControllib:explorer:EmptyFileName' );
end

% Save data to file.
restoredFlags = get(nodes, {'Dirty'});
restoredFiles = get(nodes, {'SaveAs'});
try
  set(nodes, 'Dirty', false, 'SaveAs', filename);
  Projects = nodes; % Used in next command as variable name
  save(filename, 'Projects', '-mat')
catch E
  % Restore previous Dirty flags and filenames if error.
  set(nodes, {'Dirty'},  restoredFlags);
  set(nodes, {'SaveAs'}, restoredFiles);
  throw(E)
end
