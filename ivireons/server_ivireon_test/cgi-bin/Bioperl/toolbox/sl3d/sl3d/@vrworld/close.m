function close(w)
%CLOSE Close a virtual world.
%   CLOSE(W) closes the virtual world referred to by VRWORLD handle W.
%   If the open count of a virtual world decreases to zero, its internal
%   representation is deleted from memory.
%
%   If W is an array of handles all the virtual worlds are closed.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2009/11/07 21:29:53 $ $Author: batserve $

% do it
for i = 1:numel(w)
    
  % issue a warning for invalid world but do not fail
  if ~isvalid(w(i))
    warning('VR:invalidworld', 'Attempt to close an invalid world.');
    continue;
  end
  
  if get(w(i), 'OpenCount') == 1   % world is about to close - close all figures
    close(get(w(i), 'Figures'));
    delete(get(w(i), 'Canvases'));

    % wait until all figures close
    while true
      [~, figs5] = vrsfunc('VRT3ListViews', w(i).id);
      if isempty(figs5)
        break;
      end
      drawnow;
    end

  end
  vrsfunc('VRT3SceneClose', w(i).id);
end
