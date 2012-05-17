function varargout = getActiveCode(mdl, varargin)
% Get the active code object from a model

% Copyright 2003-2004 The MathWorks, Inc.
  
  hMdl = get_param(mdl, 'Object');
 
  h = getActiveCodeObj(hMdl);
  if nargout > 0
      varargout{1} = h;
  end
  
  if nargin > 1 % refresh code object from current working directory
      if ~isempty(h)  % when activeCodeObj exists
          refresh(h, pwd); 
          ed = DAStudio.EventDispatcher;
          ed.broadcastEvent('HierarchyChangedEvent', h);
      end
  end