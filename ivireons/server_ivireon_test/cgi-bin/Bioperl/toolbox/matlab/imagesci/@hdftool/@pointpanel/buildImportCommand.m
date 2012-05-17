function cmd = buildImportCommand(this, bImport)
%BUILDIMPORTCOMMAND Create the command that will be used to import the data.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   BIMPORT: THis indicates if the string will be used for import.
%       If this is the case, we will do some extra error checking.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/01/19 02:55:43 $


    % Use the api's to determine a command that will import the data
    infoStruct = this.currentNode.nodeinfostruct;
    varName = get(this.filetree,'wsvarname');
    cmd = [varName ' = hdfread(''' this.filetree.filename '''' ...
        ', ''' infoStruct.Name '''' ];
    
    Fields = this.datafieldApi.getSelectedString();
    cmd = [cmd ', ''Fields'', ''' Fields '''' ]; 

    Level = this.levelApi.getSelectedString();
    if bImport && (str2num(Level) < 1)
        errorStr = 'The level must be greater than zero.';
        errordlg(errorStr,'Invalid subset selection parameter');
        cmd = '';
        return
    end
    cmd = [cmd ', ''Level'', ' Level];

    Box = [this.boxApi.getBoxCorner1Values()';...
           this.boxApi.getBoxCorner2Values()'];
    if ~any(isnan(Box(:))) 
        cmd = [cmd ', ''Box'', {[' num2str(Box(:,1)') '] [' num2str(Box(:,2)') ']}'];
    end
    
    RecordString = this.recordApi.getSelectedString();
    if ~isempty(RecordString)
        RecordNumbers = str2num(RecordString);
        cmd = [cmd ', ''RecordNumbers'', [' RecordString ']' ];
        if bImport && ...
                (any(RecordNumbers<1) || any(RecordNumbers>infoStruct.NumRecords))
            errorStr = 'The Record number must be between 1 and %d.';
            errorStr = sprintf(errorStr, infoStruct.NumRecords);
            errordlg(errorStr,'Invalid subset selection parameter');
            cmd = '';
            return
        end
    end
  
    Time = this.timeApi.getValues();
    if ~any(isnan(Time))
        cmd = [cmd ', ''Time'', [' num2str(Time') ']'];
    end
    
    cmd = [cmd ');'];
    set(this.filetree,'matlabCmd',cmd);

end

