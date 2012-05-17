function flag = ReadCSVFile(h,FileName) 
% READEXCELFILE populates the spreadsheet in the activex/uitable
% the input option should be either 'ActiveX' or 'uiTable'

% Author: Rong Chen 
%  Copyright 2005-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $ $Date: 2010/04/21 21:33:46 $

import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;


flag = true;
if ishandle(h.Handle.bar)
   waitbar(40/100,h.Handle.bar);
end

% Read data from an csv file whose name is supplied from outside
try
    [dataStruct,~,headerlines] = importdata(FileName);
    if isstruct(dataStruct)
        thisData = cell(size(dataStruct.data,1)+headerlines,size(dataStruct.data,2));
        if isfield(dataStruct,'textdata')
            thisData(1:size(dataStruct.textdata,1),1:size(dataStruct.textdata,2)) =...
                dataStruct.textdata;
        end 
        thisData(headerlines+1:end,end-size(dataStruct.data,2)+1:end) = ...
            num2cell(dataStruct.data);   
    elseif isnumeric(dataStruct)
        thisData = num2cell(dataStruct);
    elseif iscell(dataStruct)
        thisData = dataStruct;
    else
        error('csvImportdlg:ReadCSVFile:invFile','Invalid file');
    end
catch %#ok<CTCH>
    errordlg(xlate('This is not a valid text file.'),'Time Series Tools',...
        'modal');
    delete(h.Handle.bar);
    flag = false;
    return
end

% Save the size of each sheet
tmpSize = size(thisData);
h.IOData.originalSheetSize = tmpSize;
h.IOData.currentSheetSize = tmpSize;
if ishandle(h.Handle.bar)
    waitbar(.6,h.Handle.bar);
end
% Save the rawdata into memory
h.IOData.rawdata = thisData;
if ishandle(h.Handle.bar)
   waitbar(.8,h.Handle.bar);
end
% Create the table
columnLetters = cell(1,size(h.IOData.rawdata,2));
for k=1:length(columnLetters)
     columnLetters{k} = h.findcolumnletter(k);
end
h.Handles.tsTable = javaObjectEDT('com.mathworks.toolbox.timeseries.ImportTable',...
    h,columnLetters,size(h.IOData.rawdata,1),size(h.IOData.rawdata,2));



