function outData = xlsInterp(h,headEnd,interpMethod,selectedCols)

% Copyright 2004-2005 The MathWorks, Inc.

numdata = h.numdata;

% find the start row for the numeric data
numericStart = min(find(all(isnan(numdata)')'==false));
if isempty(numericStart) %no numeric data
    outData = [];
    return
end

% the specified header is smaller than the default used by xlsread
if headEnd < numericStart 
    if numericStart>1
        warndlg(sprintf('Using the minimum valid header size of %s row(s)',num2str(numericStart-1)), ...
            sprintf('Excel File Import'),'modal')
    end
    thisData = numdata(numericStart:end,selectedCols);
else
    thisData = numdata(headEnd:end,selectedCols); 
end
outData = zeros(size(thisData));
switch lower(interpMethod)
case xlate('skip rows')
    if min(size(thisData))>=2
        goodRows = find(max(isnan(thisData)')'==0);
    else
        goodRows = find(isnan(thisData)==0);
    end
    outData = thisData(goodRows,:);
case xlate('skip cells')
    numericcells = ~isnan(thisData);
    allowedLength = min(sum(numericcells));
    if allowedLength>1
         outData = zeros(allowedLength,size(thisData,2));
         if allowedLength<max(sum(numericcells)) 
            msg = sprintf('Imported columns have differing lengths, truncating to the shortest column length of %d',...
              allowedLength);
            junk = warndlg(msg,sprintf('Excel File Import'),'modal')
         end
    else
         errordlg(sprintf('One or more imported columns has less than 2 valid rows, aborting import'), ...
            sprintf('Excel File Import'),'modal')
         return
    end
    % dimensions are shortest skipped column x all selected rows
    for col=1:length(selectedCols)
        I = find(numericcells(:,col));
        outData(1:allowedLength,col) = thisData(I(1:allowedLength),col);
    end 
case xlate('linearly interpolate')
    for col=1:length(selectedCols)
        I = isnan(thisData(:,col));
        if I(1) == 1 | I(end) == 1
            errordlg(sprintf('Cannot extrpolate over non-numeric data'), ...
                sprintf('Excel File Import'),'modal');
            outData = [];
            return
        else
            ind = find(I==0);
            y = thisData(ind,col);
            xraw = 1:size(thisData,1);
            if length(xraw)>=2 && length(ind)>=2
                outData(:,col) = interp1(ind,y,xraw,'linear')';
            else
                errordlg(sprintf('Cannot interpolate less than 2 points'), ...
                    sprintf('Excel File Import'),'modal')
                outData = [];
            end
        end
    end
case sprintf('zero order hold')
    for col=1:length(selectedCols)
        I = isnan(thisData(:,col));
        if I(1) == 1 
            errordlg(sprintf('Cannot start with non-numeric data. Use header specification to exclude these cells'),...
                sprintf('Excel File Import'),'modal');
            return
        else
            temp = thisData(find(~I),col);
            outData(:,col) = temp(cumsum(~I));
        end
    end    
end

if isempty(outData) || min(size(outData))<1
    errordlg(sprintf('One or more columns has no numeric data, aborting copy'), ...
        sprintf('Excel File Import'),'modal')
    outData = [];
    return
end