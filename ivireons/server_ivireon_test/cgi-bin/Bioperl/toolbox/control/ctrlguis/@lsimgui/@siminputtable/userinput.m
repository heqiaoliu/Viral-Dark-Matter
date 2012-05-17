function userinput(h)

% USERINPUT This method updates the inputtable.inputsignal struct array to
% refelect
% user entries into the table. The following rules of interpretation are
% used:

% 1. If the variable name has not changed then assume the user is referring to the same variable
%    (from whatever source) and update the intervals and column to reflect the
%    new entry
% 
% 2. If the variable name has changed then the 
% 	 new variable is assumed to exist in the workspace (if this is not the case an error is generated
% 	 and the user is prompted to import the variable directly). The new variable is then imported 
% 	 from the workspace.

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2007/12/14 14:28:55 $

% Determine which entries have changed
I = strcmp(h.celldata,h.lastcelldata);

if any(I(:,2)==false)  % One or more input strings have changed
    editedInput = find(I(:,2)==false);
    % Note, editInput must be scalar since the table can only be edited
    % one row at a time
    
    % Retrieve any specified indexing information
    try
        [newvarname, rowcoltxt] = localParseVarName(h.celldata{editedInput,2});
    catch
        localAbort(h,ctrlMsgUtils.message('Control:lsimgui:userinput7'))
        return 
    end
    
    if strcmp(newvarname,h.inputsignal(editedInput).name) 
    
        % Variable name has not changed, we only need to update row
        % interval, col    
        
        % If the signal is from a text/Excel file just verify that the 
        % row and columns as entered are valid and update the new
        % interval
        if any(strcmpi(h.inputsignal(editedInput).source,{'xls','asc','csv','sig'}));
             try
                 x = (1:h.inputsignal(editedInput).size(1))';
                 theserows = eval(['x(' rowcoltxt ')']);
             catch
                localAbort(h,xlate('This type of data must be indexed as a column vector'));
                return      
             end
             if ~isequal(theserows(:)',theserows(1):theserows(end))
                localAbort(h,ctrlMsgUtils.message('Control:lsimgui:userinput5'))
                return                    
             else
                h.inputsignal(editedInput).interval = [theserows(1) theserows(end)];
             end        
        elseif any(strcmpi(h.inputsignal(editedInput).source,{'wor','mat','ini'}))
             try
                 h.inputsignal(editedInput) = reloaddata(h, h.inputsignal(editedInput),rowcoltxt);
             catch
                 localAbort(h,xlate('Expression must begin with a valid variable name'));
             end    
        end
            
        if ~h.syncinterval % Give the user a change to abort of they don't like the new time interval 
             localAbort(h,'');
             return
        end
        

    else
        % a new variable name has been entered (assumed in the workspace)           
        try      
            sigStruc = h.inputsignals(editedInput);
            sigStruc.construction = '';
            sigStruc.subsource = newvarname;
            sigStruc.source = 'wor';
            sigStruc.name = newvarname;
            h.inputsignals(editedInput) = reloaddata(h, sigStruc,rowcoltxt);
        catch
            localAbort(h,ctrlMsgUtils.message('Control:lsimgui:userinput1'));
            return              
        end   
        if ~h.syncinterval %abort if necessary
            localAbort(h,'');
            return
        end       
                
    end
end 

% Disable table listeners to avoid loop
set(h.listeners,'enabled','off');
h.update;
set(h.listeners,'enabled','on');

%-------------------- Local Functions ---------------------------

function signal = reloaddata(h,signal,rowcoltxt)

% this function reloads the "values" when signal 
% fields source,subsource, file, and column in the have been specified
switch lower(signal.source(1:3))
case 'wor'
    % Need to check var exists to prevent user typing [1 2 3] into table
    if ~any(strcmp(signal.subsource,evalin('base','who')))
        ctrlMsgUtils.error('Control:lsimgui:userinput1')
    end
    try
       rawdata = evalin('base', signal.subsource);
    catch
        ctrlMsgUtils.error('Control:lsimgui:userinput2')
    end
case 'mat'
    whostr = ['who(''-file'',' signal.construction ')'];
    if ~any(strcmp(signal.subsource,evalin('base',whostr)))
        ctrlMsgUtils.error('Control:lsimgui:userinput3')
    end
    try
       rawdata = getfield(load(signal.construction, signal.subsource),signal.subsource);
    catch
        ctrlMsgUtils.error('Control:lsimgui:userinput4')
    end
case 'ini'
    respinputdata = h.guistate.Simplot.Input.Data;
    rawdata = zeros(length(respinputdata(1).Amplitude),length(respinputdata));
    for k=1:length(respinputdata)
        rawdata(:,k) = respinputdata(k).Amplitude;
    end
end

sraw = size(rawdata);
signal.size = size(rawdata);


rowcoords = reshape(1:prod(sraw),sraw);
% Rows is a matrix identifying the matrix position by row
% of the selected data starting in the first column
if isempty(rowcoltxt)
    rowcoltxt = ':,:';
end
rows = eval(['rowcoords(' rowcoltxt ')']);
if ndims(rawdata)<=2 && min(size(rows))==1
    if size(rows,1)>1 % Column extraction
       signal.transposed = false;
       width = sraw(1);
    else
       signal.transposed = true;
       % Switch the sense of measuring rows so that it identifies
       % the column position starting with the first row
       colcoords = reshape(1:prod(sraw),[sraw(2) sraw(1)])';
       rows = colcoords(rows(:)); % Column identifiers
       width = sraw(2);
    end   
    % Check for contiguous intervals
    if ~isequal(rows(:)',rows(1):rows(end))
        ctrlMsgUtils.error('Control:lsimgui:userinput5')
    end
    signal.column = ceil(rows(1)/width);
    signal.interval = [rows(1) rows(end)]-(signal.column-1)*width;
else
    ctrlMsgUtils.error('Control:lsimgui:userinput6')
end

% Extract data
if signal.transposed
   signal.values = rawdata(signal.column,:)';
else
   signal.values = rawdata(:,signal.column);
end

function [varname, rowcoltxt] = localParseVarName(inpstring)

% Look for brakets indicating that row/col information is available
startofbracket = strfind(inpstring,'(');
endofbracket = strfind(inpstring,')');
if isempty(startofbracket) 
    varname = inpstring;
    rows = [];
    cols =[];
elseif ~isempty(startofbracket)  && isempty(endofbracket) 
    ctrlMsgUtils.error('Control:lsimgui:userinput7')
else
    varname = inpstring(1:startofbracket-1);
end

% Now remove any trailing or leading spaces
tempStr = deblank(varname);
varname = deblank(tempStr(end:-1:1)); 
varname = varname(end:-1:1);

% row and col text
rowcoltxt = inpstring(startofbracket+1:endofbracket-1);


function localAbort(h, msg)

if ~isempty(msg)
    errordlg(msg,'Linear Simulation Tool','modal');
end
h.celldata = h.lastcelldata;
h.setCells(h.lastcelldata);


