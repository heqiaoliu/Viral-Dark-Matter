function display(this)
% DISPLAY  Overloaded DISPLAY method for tsdata.qualmetadata
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

%% Codes
%fprintf('\n');
if ~isempty(this.Code) && ~isempty(this.Description)
    if length(this.Code)==length(this.Description)
        %% Heading
        code_col_width = 16;
        str = xlate('Code');
        heading = [str blanks(code_col_width - length(str)) xlate('Description')];
        fprintf('  %s\n', heading);
        fprintf('  %s\n', repmat('-',[1 length(heading)]));
        
        %% Table
        for i=1:length(this.Code)
            try
                str = num2str(this.Code(i));
                fprintf('  %s%s%s\n', ...
                        str, ...
                        blanks(code_col_width - length(str)), ...
                        this.Description{i});    
            catch me
                rethrow(me);
            end
        end        
        fprintf('  %s\n', repmat('-',[1 length(heading)]));
    else
        fprintf('  Quality code and description are not synchronized.\n');
    end
elseif isempty(this.Code)
    fprintf('    No quality code is defined.\n');
elseif isempty(this.Description)
    fprintf('    No quality description is defined.\n');
end

%% General Properties
fprintf('\n  Common Properties:\n');
locPrintSetting('Code:', locGetArrayStr(this.Code));
locPrintSetting('Description:', locGetArrayStr(this.Description));

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
