function nodes = load(this, filename)
% LOAD Loads projects from the file FILENAME.
%
% load(filename)

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2007/11/09 20:59:21 $

if isempty(filename)
  ctrlMsgUtils.error( 'SLControllib:explorer:EmptyFileName' );
end

% Load data from file.
ws = warning('off'); lw = lastwarn;
try
  s = load(filename, '-mat');
catch E
  throw(E)
end
warning(ws); lastwarn(lw)

% Extract projects from data.
if isfield(s, 'Projects') && isa(s.Projects, 'explorer.projectnode')
  nodes = s.Projects;

  % Remember where the nodes were loaded from.
  set(nodes, 'SaveAs', filename);
else
  ctrlMsgUtils.error( 'SLControllib:explorer:NoValidProjectsInFile', filename );
end
