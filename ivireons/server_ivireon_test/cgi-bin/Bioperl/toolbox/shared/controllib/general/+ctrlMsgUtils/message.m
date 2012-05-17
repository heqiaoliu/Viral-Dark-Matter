function Str = message(ID,varargin)
% message Package method for getting string from message ID.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:37:03 $


try
    mObj = MessageID(ID);
    Str = mObj.message(varargin{:});
catch e
    rethrow(e);
end
    

