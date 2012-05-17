function b = isOptionsEnabled(this, type, row)
%ISOPTIONSENABLED True if the object is OptionsEnabled

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/07/23 18:44:06 $

% If there are no visible types, always return false.
if isempty(setdiff(this.Driver.RegisterDb.SortedTypeNames, this.HiddenTypes))
    b = false;
    return;
end

if nargin < 3
    type = this.Driver.RegisterDb.SortedTypeNames{this.SelectedType+1};
    row  = this.SelectedExtension(this.SelectedType+1);
end

hRegisters = findVisibleRegisters(this, type);
hRegister  = hRegisters(row+1);
hConfig    = findConfig(this.Driver.ConfigDb, hRegister.Type, hRegister.Name);

enab = hConfig.Enable;
if ~enab
    hDlg = get(this, 'Dialog');
    if ~isempty(hDlg)
        enab = logical(str2double(hDlg.getTableItemValue([type '_table'], row, 0)));
    end
end

% We need to make sure that the configuration has the propertyDb.  It might
% never have been enabled in this session.
mergePropDb(hRegister, hConfig, this.MessageLog);

try
    if enab && ~isempty(feval(hRegister, 'getPropsSchema', hConfig, []))
        b = true;
    else
        b = false;
    end
catch ME
    b = false;
    
    hMessageLog = this.MessageLog;
    if isempty(hMessageLog)
        rethrow(ME);
    else
        % Send error to MessageLog
        summary = 'Cannot edit options.';
        details=sprintf([ ...
            'The getPropsSchema method did not return a valid dialog structure.  ' ...
            'Cannot edit options for this extension.<br>' ...
            '<ul>' ...
            '<li>Type:  %s' ...
            '<li>Name:  %s' ...
            '<li>Error: %s' ...
            '<li>File: %s' ...
            '</ul>'], ...
            hConfig.Type, hConfig.Name, ME.message, ME.stack(1).file);
        hMessageLog.add('Fail','Extension',summary,details);
    end
end

% [EOF]
