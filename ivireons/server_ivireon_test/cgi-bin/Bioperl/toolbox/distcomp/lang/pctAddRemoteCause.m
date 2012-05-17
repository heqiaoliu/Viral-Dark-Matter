function ex = pctAddRemoteCause( ex, cause )
%pctAddRemoteCause - add a cause to an exception, but include the stack

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2009/07/18 15:50:29 $

ex = addCause( ex, pctTransformRemoteException( cause ) );

end

