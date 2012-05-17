function viewerTitle = viewertitle(viewer, fullpath)
% VIEWERTITLE Return a window title for a Signal & Scope Manager viewer
%
%   Input: 
%       viewer   - Name of a Simulink Signal & Scope Manager viewer
%       fullpath - True if the viewer's fullpath name is used
%
%   viewertitle('viewerName') returns a title suitable for displaying in
%   the viewer's graphical window.  The title includes the viewer's name
%   and a list of all named signals attached to the viewer.
%
%
%   Copyright 1994-2005 The MathWorks, Inc.
  
  names = [];
  
  %
  % The iorec of the viewer is a cell array of structures describing
  % a connection to a signal.
  %
  iorec = get_param(viewer,'iosignals');
  
  %
  % Length of the iorec is equal to the number of viewer axes.
  %
  nSets = length(iorec);
  
  %
  % Search through each viewer axis of the iorec.
  %
  for i=1:nSets
    ioset = iorec{i};
    nSigs = length(ioset);
    
    %
    % Search through the signal connections for this viewer axis
    %
    for j=1:nSigs
      name = '';
      
      %
      % Any signal with a non-empty RelativePath is a connection
      % inside a model reference or stateflow chart.  We do not
      % list these signals in the title.
      %
      if isempty(ioset(j).RelativePath)
        %
        % Must be a port handle or -1.  If its a port handle, grab the
        % line, if it exists, and save the name, if it exists.
        %
        h = ioset(j).Handle;
        if (h ~= -1)
          line = get(h,'line');
          if (line ~= -1)
            name = get(line, 'name');
          end
        end

        %
        % Save this name to the other names found so far.
        %
        if ~isempty(name)
          if isempty(names)
            names = name;
          else
            names = [names ', ' name];
          end
        end
      end
    end
  end
  
  %
  % Construct the viewer title.
  %
  if fullpath
    viewerName = getfullname(viewer);
  else
    viewerName = get_param(viewer,'name');
  end
  
  if isempty(names)
    viewerTitle = ['Viewer: ' viewerName];
  else
    viewerTitle = ['Viewer: ' viewerName ' (' names ')'];
  end
