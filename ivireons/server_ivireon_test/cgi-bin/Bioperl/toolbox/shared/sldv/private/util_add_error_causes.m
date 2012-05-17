function util_add_error_causes(modelH, mExceptionCauseFlat)

%   Copyright 2009-2010 The MathWorks, Inc.

    for idx=1:length(mExceptionCauseFlat)
        if isa(mExceptionCauseFlat{idx},'MSLException') && ...
                ~isempty(mExceptionCauseFlat{idx}.handles) && ...
                ~isempty(mExceptionCauseFlat{idx}.handles{1}) 
            avtcgirunsupcollect('push',filterHandles(mExceptionCauseFlat{idx}.handles{1}),'simulink', ...
                    mExceptionCauseFlat{idx}.message,...
                    mExceptionCauseFlat{idx}.identifier);
        else
            avtcgirunsupcollect('push',modelH,'simulink', ...
                    mExceptionCauseFlat{idx}.message,...
                    mExceptionCauseFlat{idx}.identifier);
        end
    end  
end

function blockH = filterHandles(blockH)
    if length(blockH)>1
        blockH = get_param(bdroot(blockH(1)),'Handle');
    end
end
% LocalWords:  MSL
