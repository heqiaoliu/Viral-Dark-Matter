function display(ts,hotLinks)
% DISPLAY  Overloaded DISPLAY method for timeseries
%
% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.8.10 $  $Date: 2010/04/05 22:22:25 $

%% Call builtin display for arrays
if length(ts)~=1
    builtin('disp',ts);
    return
end

%% Class name
mc = metaclass(ts);
if nargin==2
    bHotLinks = hotLinks;
else
    bHotLinks = feature('hotlinks');
end
if bHotLinks
    fprintf('  <a href="matlab: help %s">%s</a>\n\n', mc.Name, mc.Name);
else
    fprintf('  %s\n\n', mc.Name);
end

%% Duplicate times
if ts.hasduplicatetimes
    if bHotLinks
        % Create the helpview M code to scroll to the Duplicate Times
        % remark on the timeseries reference page and embed it in the
        % hyperlink.
        doclink = sprintf('helpview(''%s/techdoc/helptargets.map'',''timeseries_dup_time'')',docroot);
        fprintf('  Timeseries contains <a href="matlab: %s">duplicate times</a>.\n\n',doclink);
    else
        fprintf('  Timeseries contains duplicate times.\n\n');
    end
end
    
%% General Settings
fprintf('  Common Properties:\n');
if ischar(ts.Name)
    locPrintSetting('Name:', sprintf('''%s''', ts.Name));
else
    locPrintSetting('Name:', '');
end
       
%% Time
locPrintSetting('Time:', locGetArrayStr(ts.Time));
if bHotLinks
    str = sprintf('<a href="matlab: fprintf([''%s''])">[1x1 %s]</a>', ...
                  locGetHyperLinkDispString(evalc('ts.TimeInfo')), ...
                  class(ts.TimeInfo));
else
    str = class(ts.TimeInfo);
end
locPrintSetting('TimeInfo:', str);            

%% Data     
locPrintSetting('Data:', locGetArrayStr(ts.Data));     
if bHotLinks 
    str = sprintf('<a href="matlab: fprintf([''%s''])">[1x1 %s]</a>', ...
                  locGetHyperLinkDispString(evalc('ts.DataInfo')), ...
                  class(ts.DataInfo));                
else
    str = class(ts.DataInfo);
end
locPrintSetting('DataInfo:', str);             

%% Quality - only print if there is quality defined
if ~isempty(ts.Quality)     
    locPrintSetting('Quality:', locGetArrayStr(ts.Quality));    
    if bHotLinks
        str = sprintf('<a href="matlab: fprintf([''%s''])">[1x1 %s]</a>', ...
                      locGetHyperLinkDispString(evalc('ts.QualityInfo')), ...
                      class(ts.QualityInfo)); 
    else
        str = class(ts.QualityInfo);
    end
    locPrintSetting('QualityInfo:', str);             
end
    
%% Events
if ~isempty(ts.Events)
    locPrintSetting('Events:', locGetArrayStr(ts.Events));
end

%% User Data
if ~isempty(ts.UserData)
    locPrintSetting('UserData:', locGetArrayStr(ts.UserData));
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
function locPrintSetting(labelStr, valStr)

    label_len = length(labelStr);
    
    fprintf('    %s%s %s\n', ...
            blanks(13-label_len), ...
            labelStr, ...
            valStr);
end

%% function locGetArrayStr ------------------------------------------------
function str = locGetArrayStr(val)
    str = sprintf('%dx', size(val));
    str = sprintf('[%s %s]', str(1:end-1), class(val));
end


%% function locGetArrayStr ------------------------------------------------
function str = locGetHyperLinkDispString(varName)
    str = varName;
    str = strrep(str, '''', '''''');    
    str = strrep(str, '"', ''' char(34) ''');
    str = strrep(str, '<', ''' char(60) ''');
    str = strrep(str, '>', ''' char(62) ''');
    str = strrep(str, sprintf('\n'), '\n');    
end