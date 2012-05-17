function display(this)
% DISPLAY  Overloaded DISPLAY method for tsdata.timemetadata
%
% Copyright 2005-2009 The MathWorks, Inc.

%% Class name
mc = metaclass(this);
bHotLinks = feature('hotlinks');
if bHotLinks
    fprintf('  <a href="matlab: help %s">%s</a>\n', mc.Name, mc.Name);
else
    fprintf('  %s\n', mc.Name);
end

%% Print the package name
if ~isempty(mc.ContainingPackage)
    fprintf('  Package: %s\n\n', mc.ContainingPackage.Name);
else
    fprintf('\n');
end

%% Heading including empty, uniform, etc. 
if this.Length == 0
    fprintf('  Empty timeseries TimeMetaData object.\n');
elseif ~isnan(this.Increment)
    fprintf('  Uniform Time:\n');
    locPrintSetting(xlate('Length'), num2str(this.Length), true);
    locPrintSetting(xlate('Increment'), ...
                    sprintf('%d %s',this.Increment, this.Units), true);
   
else
    fprintf('  Non-Uniform Time:\n');   
    locPrintSetting(xlate('Length'), num2str(this.Length), true);
end

%% Start and End
if this.Length>0
    fprintf('\n  Time Range:\n');
    
    % If a start date is defined use it to convert the relative start and
    % end times into absolute start and end times with the right format
    if ~isempty(this.StartDate)
        if tsIsDateFormat(this.Format)
            startstr = datestr(datenum(this.Startdate)+tsunitconv('days',this.Units)*this.Start,this.Format);
            endstr = datestr(datenum(this.Startdate)+tsunitconv('days',this.Units)*this.End,this.Format);
        else
            startstr = datestr(datenum(this.Startdate)+tsunitconv('days',this.Units)*this.Start,'dd-mmm-yyyy HH:MM:SS');
            endstr = datestr(datenum(this.Startdate)+tsunitconv('days',this.Units)*this.End,'dd-mmm-yyyy HH:MM:SS');
        end
    else
        startstr = sprintf('%d %s', this.Start, this.Units);
        endstr = sprintf('%d %s', this.End, this.Units);      
    end  
    
    locPrintSetting('Start', startstr, true);
    locPrintSetting('End', endstr, true);
end

%% General Settings
fprintf('\n  Common Properties:\n');
locPrintSetting('Units:', sprintf('''%s''', this.Units));
locPrintSetting('Format:', sprintf('''%s''', this.Format));
locPrintSetting('StartDate:', sprintf('''%s''', this.StartDate));

%% Custom defined properties
if ~isempty(this.UserData)
    locPrintSetting('UserData:', locGetArrayStr(this.UserData));
end

%% Links for methods and properties
if bHotLinks
    fprintf('\n  <a href="matlab: properties(''%s'')">More properties</a>, ', mc.Name);
    fprintf('<a href="matlab: methods(''%s'')">Methods</a>\n\n', mc.Name);
else
    fprintf('\n');
end

end

%% HELPER FUNCTIONS =======================================================

%% function locPrintSetting -----------------------------------------------
function locPrintSetting(labelStr, valStr, leftAlign)
    
    label_len = length(labelStr);
        
    if nargin > 2 && leftAlign
        fprintf('    %s%s %s\n', ...
                labelStr, ...
                blanks(12-label_len), ...
                valStr);       
    else
        fprintf('    %s%s %s\n', ...
                blanks(12-label_len), ...
                labelStr, ...
                valStr);
    end    
end

%% function locGetArrayStr ------------------------------------------------
function str = locGetArrayStr(val)
    str = sprintf('%dx', size(val));
    str = sprintf('[%s %s]', str(1:end-1), class(val));
end