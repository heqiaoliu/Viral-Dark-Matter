function tstablecb(h,row,col,thisModel)

% Copyright 2005-2006 The MathWorks, Inc.

%% tstsble datachange callback method.

%% Get current table data
tableData = cell(h.Handles.tsTable.getModel.getData);

%% Get data objects and find the total # of cols
totalcols = 0;
maxrowinds = 0;
row = row+1;
col = col+1;
if ~isempty(h.Plot) && ishandle(h.Plot) 
    if col==4
        dataobjs = get(h.Plot.Waves,{'Data'});
        for k=1:length(dataobjs)
            thissize = h.Plot.Waves(k).Data.getsize;
            totalcols = thissize(1)+totalcols;
            if k~=row % Maximum row ind, excluding this row
                maxrowinds = max(maxrowinds,max(h.Plot.Waves(k).RowIndex));
            end
        end
    end
    % Clear any selection modes
    h.Plot.setselectmode('None');
end
        
if col==4 % Axes index update
    newIndices = eval(tableData{row,col},'[]');
    % Try removing then adding square brakets in case of a user typo
    if isempty(newIndices)
        modtableData = strrep(tableData{row,col},'[','');
        modtableData = sprintf('[ %s ]',strrep(modtableData,']',''));
        newIndices = eval(modtableData,'[]');
    end 
    if isempty(newIndices) || ~isnumeric(newIndices) || any(isnan(newIndices)) || ...
            any(~isfinite(newIndices)) || any(floor(newIndices)<=0) || ...
            any(abs(newIndices-floor(newIndices))>0)
        errordlg('Invalid subplot index','Time Series Tools',...
            'modal')
        % Revert
        h.Handles.tsTable.getModel.setValueAtNoCallback(['[' num2str(h.Plot.waves(row).RowIndex(:)') ']'],...
            row-1,col-1);
        return
    end
    
    %% Repeat scalar vals
    rsize = h.Plot.Waves(row).Data.getsize;
    if isscalar(newIndices)
        newIndices = repmat(newIndices,[rsize(1),1]);
    end
    if length(newIndices)~=rsize(1)
         msg = sprintf('The length of the subplot index vector must equal the number of columns in the time series (%d)',...
             rsize(1));
         errordlg(msg,'Time Series Tools','modal')
         % Revert
         h.Handles.tsTable.getModel.setValueAtNoCallback(['[' num2str(h.Plot.waves(row).RowIndex(:)') ']'],...
             row-1,col-1);
         return       
    end

    if max(newIndices)>totalcols
         msg = sprintf('The largest subplot index vector cannot be larger than the sum of all the columns of all the time series in the plot: %d',...
             totalcols);
         errordlg(msg,'Time Series Tools','modal')
         % Revert
         h.Handles.tsTable.getModel.setValueAtNoCallback(['[ ' num2str(h.Plot.waves(row).RowIndex(:)') ' ]'],...
             row-1,col-1);
         return       
    end        
        
    if isempty(h.Plot) || ~ishandle(h.Plot)
        h.tstable;
    else
        h.refreshAxes(h.Plot.Waves(row),newIndices);
    end
    h.Handles.tsTable.getModel.setValueAtNoCallback(['[ ' num2str(h.Plot.waves(row).RowIndex(:)') ' ]'],...
            row-1,col-1);
elseif col==5 % Visibility update
    offon = {'off','on'};
    h.Plot.waves(row).Visible = offon{double(tableData{row,col})+1};
end