function count = construct_tt_error(method, ids, msg, throwFlag, openFcn)
% CONSTRUCT_CODER_ERROR(IDS,MSG,THROWFLAG)

%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2005/06/24 11:28:58 $
persistent sErrorCount;

if(isempty(sErrorCount))
    sErrorCount = 0;
end

switch(method)
    case 'reset'
        sErrorCount = 0;
    case 'add'
        if nargin < 5
            openFcn = [];
        end
        
        if nargin < 4
            throwFlag = 0;
        end
        
        sErrorCount = sErrorCount+1;
        if(isempty(msg))
            msg = 'Unexpected internal error';
            throwFlag = 1;
        end
        construct_error(ids, 'Parse', msg, throwFlag, openFcn);
    case 'get'
end
count = sErrorCount;
