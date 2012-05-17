function [dims, nts] = getDimAndTime(testData,timeValues)
    sizeData = size(testData);
    if length(timeValues)==1
        dims = sizeData;
        nts = 1;
    else
        dims = sizeData(1:end-1);
        nts = sizeData(end);
    end
end