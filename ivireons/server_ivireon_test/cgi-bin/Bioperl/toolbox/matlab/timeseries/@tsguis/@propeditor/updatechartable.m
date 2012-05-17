function updatechartable(h,view,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Updates the characteristic table in response to a ViewChange event.
%% varargin is the unit conversion factor if a unit conversion
%% is in progress.

waves = view.allwaves;
if length(waves)==0
    return % Nothing to do
end

%% Intiailize vars
charTab = h.findtab('Characteristics');
charTable = charTab.Handles.CharTable;
newData = repmat({''},[charTable.getRowCount,charTable.getColumnCount]);
newData(:,1) = repmat({false},[size(newData,1) 1]);

%% Update newData cell array with char props
for row=1:charTable.getRowCount
    if ~isempty(waves(1).Characteristics)
        thischar = find(waves(1).Characteristics,'Identifier',...
            charTable.getValueAt(row-1,1));
        if ~isempty(thischar) && strcmp(thischar.Visible,'on') 
            newData{row,1} =  true;
        end    
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