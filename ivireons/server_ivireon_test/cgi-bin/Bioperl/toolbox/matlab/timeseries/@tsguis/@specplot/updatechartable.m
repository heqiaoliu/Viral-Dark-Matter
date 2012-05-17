function updatechartable(view,h,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Updates the characteristic table in response to a ViewChange event.
%% varargin is the unit conversion factor if a unit conversion
%% is in progress.

if length(view.waves)==0
    return % Nothing to do
end

%% Intiailize vars
charTab = h.findtab('Characteristics');
charTable = charTab.Handles.CharTable;
newData = repmat({''},[charTable.getRowCount,charTable.getColumnCount]);
newData(:,1) = repmat({false},[size(newData,1) 1]);

%% Update newData cell array with char props
for row=1:charTable.getRowCount
    if ~isempty(view.waves(1).Characteristics)
        thischar = find(view.waves(1).Characteristics,'Identifier',...
            charTable.getValueAt(row-1,1));
        if ~isempty(thischar) && strcmp(thischar.Visible,'on') 
            newData{row,1} =  true;
        end    
        if nargin>=3 
            thischar.Data.StartFreq = thischar.Data.StartFreq*varargin{1};
            thischar.Data.EndFreq = thischar.Data.EndFreq*varargin{1};
        end  
        newData(row,3:end) = {sprintf('%0.3g',thischar.Data.StartFreq),...
            sprintf('%0.4g',thischar.Data.EndFreq)};
    end
end

%% Get the current data
charTableModel = charTable.getModel;
lastData = cell(size(newData));
for row=1:charTable.getModel.getDataVector.size
     lastData(row,:) = cell(charTable.getModel.getDataVector.get(row-1).toArray);
end

%% If the current data differs from the new data update the char table
%% non-recursively
for row=1:size(newData,1)
   for col=1:size(newData,2)
       if col~=2 && ~isequal(newData{row,col},lastData{row,col})
           charTableModel.setValueAtNoCallback(newData{row,col},row-1,col-1);
       end
   end
end