function display(this)
% DISPLAY  Overloaded DISPLAY method for tsdata.datametadata
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

%% General Settings
fprintf('  Common Properties:\n');
locPrintSetting('Units:', sprintf('''%s''', this.Units));

%% Interpolation
if ~isempty(this.Interpolation)
    locPrintSetting('Interpolation:', ...
                    sprintf('%s (%s)', this.Interpolation.Name, ...
                            class(this.Interpolation)));
end

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
function locPrintSetting(labelStr, valStr, sizeLabel)
    
    if nargin > 2
        label_len = length(sizeLabel);        
    else
        label_len = length(labelStr);
    end
    
    fprintf('    %s%s %s\n', ...
            blanks(17-label_len), ...
            labelStr, ...
            valStr);
end

%% function locGetArrayStr ------------------------------------------------
function str = locGetArrayStr(val)
    str = sprintf('%dx', size(val));
    str = sprintf('[%s %s]', str(1:end-1), class(val));
end