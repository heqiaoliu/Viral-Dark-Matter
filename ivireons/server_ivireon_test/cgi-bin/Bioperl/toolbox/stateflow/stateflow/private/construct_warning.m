function varargout = construct_warning( ids, warnType, warnMsg, openFcn)

    if nargin < 4
        openFcn = [];
    end

    if(nargout==0)
        construct_error( ids, warnType, warnMsg, -2, openFcn);
    else
        varargout = cell(1,max(1,nargout));
        varargout{:} = construct_error( ids, warnType, warnMsg, -2, openFcn);
    end
    
% Copyright 2002-2005 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2005/06/24 11:28:59 $
