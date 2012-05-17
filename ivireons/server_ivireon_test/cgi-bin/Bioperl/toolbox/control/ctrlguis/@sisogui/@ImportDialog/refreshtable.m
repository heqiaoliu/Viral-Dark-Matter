function refreshtable(this)
%REFRESHTABLE  Refreshes the table 

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/04/21 03:07:45 $

TableModel = this.Handles.TableModel;

% Table column names
tablecolnames = javaArray('java.lang.Object',2);
tablecolnames(1) = java.lang.String(sprintf('System'));
tablecolnames(2) = java.lang.String(sprintf('Data'));

numrows = TableModel.getRowCount;
numSystems = length(this.ImportList);

% Turn off table listener during update
this.Handles.TableListener.Enabled = 'off';

% Check if number of table rows has changed
if (numSystems ~= numrows) && (numSystems ~= 0)
    % Initialize size of table model
    tabledata = javaArray('java.lang.Object',numSystems,2);
    jm = TableModel.getClass.getMethod('setDataVector',[tabledata.getClass,tablecolnames.getClass]);
    awtinvoke(TableModel,jm,tabledata,tablecolnames);
end
  
if isempty(this.ImportList)
    awtinvoke(TableModel,'clearRows');
else
    for k = 1:numSystems
        rowdata = LocalCreateTableData(this.Design.(this.ImportList{k}));
        % update Table model
        for counter = 1:length(rowdata)
            awtinvoke(TableModel,'setValueAt(Ljava.lang.Object;II)',java.lang.String(rowdata{counter}),(k-1),(counter-1));
        end
    end


end

% Force updating of table before turning listener back on
drawnow;

% Turn on table listener after update
this.Handles.TableListener.Enabled = 'on';

%---------------------Local Functions--------------------------------------

% ------------------------------------------------------------------------%
% Function: LocalCreateTableData
% Purpose:  Parses System to generate strings for table
%           Name, Data
% ------------------------------------------------------------------------%
function rowdata = LocalCreateTableData(System)

isFRD = isa(System.Value,'frd');
if isa(System.Value,'double')
    z = [];
    p = [];
    k = System.Value;
elseif ~isFRD
    [z,p,k] = zpkdata(System.Value,'v');
end
if ~isFRD && isempty(z) && isempty(p)
    % static gain
    expr = sprintf('%.4g',k);
elseif isempty(System.Variable)
    % result of expression such as rss(5)
    expr = sprintf('< current value >');
else
    expr = sprintf('< %s >',System.Variable);
end

rowdata = { System.Name, expr};
            

       