function pVerifyUsing1d(methodName, varargin)
%pVerifyUsing1d Assert that codistributed arrays are using codistributor1d


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/05/14 16:51:20 $

if ~all(cellfun(@iIsSupported, varargin))
    errID = sprintf('distcomp:codistributed:%s:CodistributorNotSupported', ...
                    methodName);
    if strcmp(lower(methodName), methodName)
        % All in lower case, so display in upper case.
        dispName = upper(methodName);
    else
        % Method name contains mixed case, so display in mixed case.
        dispName = methodName;
    end
    errMsg = sprintf(['%s is currently supported only for codistributed ', ...
                      'arrays using a 1d codistributor.'], ...
                     dispName);
    E = MException(errID, errMsg);
    throwAsCaller(E);
end

end % End of pVerifyUsing1d.


    
function ok = iIsSupported(X)
    ok = true;
    if isa(X, 'codistributed') && ~isa(getCodistributor(X), 'codistributor1d')
       ok = false;
    end
end
