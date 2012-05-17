function str = pGetResource(type,key,varargin)
%pGetResource - Resource manager interface for the Comparison Tool
%
% str = pGetResource('message',key,varargin
% pGetResource('error',key,varargin)
% pGetResource('warning',key,varargin)

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

    msg = MessageID(key);
    str = msg.message(varargin{:});
    switch type
      case 'error'
          % No point in having this function in the error call stack, 
          % so throw the error as if from the caller.
          E = MException(key,'%s',str);
          throwAsCaller(E);
      case 'warning'
        warning(key,'%s',str);
      case 'message'
      otherwise
        % Internal error.  No need to translate.
        error('MATLAB:Comparisons:Internal','Unknown action: %s',type);
    end
end
