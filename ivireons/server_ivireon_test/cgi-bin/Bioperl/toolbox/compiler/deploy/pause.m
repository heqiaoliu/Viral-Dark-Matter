function [varargout] = pause(varargin)

% Copyright 2004-2005 The MathWorks, Inc.

  warnStatus = warning('query', 'MCR:READLINE:zerolengthprompt');
  warning('off', 'MCR:READLINE:zerolengthprompt');
  if((nargin==0) ...
      && (nargout==0))
      state = builtin('pause');
      if (strcmp(state,'on'))
          %
          % Call deployed input to block waiting for input.
          %
          input();
      end;
  else
      %
      % All other cases of pause use the pause buildin
      %
      if (nargout==0)
          builtin('pause', varargin{:});
      else
          [varargout{1:nargout}] = builtin('pause', varargin{:});
      end
  end
  warning(warnStatus);
