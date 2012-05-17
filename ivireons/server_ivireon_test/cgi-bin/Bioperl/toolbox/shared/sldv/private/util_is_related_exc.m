function [out, excp] = util_is_related_exc(mException, errorIds)
% Check the mException and find out whether its id or id's of one of the
% matches one of the ids in the errorIds. errorIds can be a cell array of
% ids. 

%   Copyright 2009 The MathWorks, Inc.
    excp = [];    
    out = false;    
    [isMatch, cExcp] = checkCausesID(mException,errorIds);
    if any(strcmp(mException.identifier,errorIds)) || isMatch
        out = true;          
        if(nargout > 1)
            if(isempty(cExcp))
                excp = mException;
            else
                excp = cExcp;
            end
        end
    end        
end

function [out, matchExcp] = checkCausesID(mException,errorIds)
    out = false;
    matchExcp = [];
    causes = mException.cause;
    for idx=1:length(causes)
        causeExcp = causes{idx};
        if any(strmatch(causeExcp.identifier,errorIds)) 
            out = true;
            matchExcp = causeExcp;
            break;
        end
        [isMatch, cExcp] = checkCausesID(causeExcp,errorIds);
        if isMatch
            out = true;
            matchExcp = cExcp;
            break;
        end
    end
end

