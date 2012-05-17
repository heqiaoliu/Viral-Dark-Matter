function mExceptionCauseFlat = util_get_error_causes(mException)

%   Copyright 2009-2010 The MathWorks, Inc.

    mExceptionCauseFlat = {};    
    assert(isa(mException,'MException'),'Input must be MException');    
    mExceptionCauseFlat = checkCauses(mException,mExceptionCauseFlat,true);    
end

function mExceptionCauseFlat = checkCauses(mException,mExceptionCauseFlat,isRoot)
    if nargin<3
        isRoot = false;
    end
    if ~isempty(mException.cause) 
        for i=1:length(mException.cause)
            mExceptionCauseFlat = checkCauses(mException.cause{i},mExceptionCauseFlat);                
        end        
    elseif ~isRoot
        mExceptionCauseFlat{end+1} = mException;
    end    
end

% LocalWords:  MException
