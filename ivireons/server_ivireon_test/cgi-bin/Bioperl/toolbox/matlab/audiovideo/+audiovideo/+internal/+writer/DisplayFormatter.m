classdef (Hidden) DisplayFormatter
    %DisplayFormatter Utility class to format the display of VideoWriter objects.
    %   DisplayFormatter is used to format the disp and getdisp of VideoWriter
    %   objects.  It attempts to mimic the default display of MATLAB
    %   classes, but adds in VideoWriter specific functionality.
    %
    %   This is an internal class and is not intended for use in customer
    %   code.
    %
    %   DisplayFormatter methods:
    %      getDisplayHeader - Return the display header for an object.
    %      getDisplayFooter - Return the display footer for an object.
    %      getPropertiesString - Return the string for the property display.
    
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.3.2.1 $ $Date: 2010/06/17 14:12:22 $
    
    methods (Static)
        function header = getDisplayHeader(obj)
            % getDisplayHeader Return the display header for an object.
            %   header = getDisplayHeader(obj) returns the header string
            %   for the object obj.  The header string is designed to
            %   reflect the appearance of the default MATLAB Class object
            %   display except that subclasses are not displayed.
            
            hotlinks = feature('hotlinks');
            myclass = class(obj);
            
            if hotlinks
                header = sprintf('\n  <a href="matlab:help %s">%s</a>\n\n', myclass, myclass);
            else
                header = sprintf('\n  %s\n\n', myclass);
            end
        end
        
        function footer = getDisplayFooter(obj)
            % getDisplayFooter Return the display footer for an object.
            %   header = getDisplayFooter(obj) returns the footer string
            %   for the object obj.  The footer string is designed to
            %   reflect the appearance of the default MATLAB Class object
            %   display.  Currently VideoWriter objects do not have user
            %   visible events or interesting superclasses, so links to
            %   those elements are not displayed.
            
            hotlinks = feature('hotlinks');
            myclass = class(obj);

            if hotlinks
                footer = sprintf('  <a href="matlab:methods(''%s'')">Methods</a>\n\n', myclass);
            else
                footer = sprintf('\n');
            end
        end
        
        function props = getPropertiesString(obj, displayProps, propPretext)
            %getPropertiesString Return the string for the property display.
            %   string = getPropertiesString(obj, displayProps,
            %   propPretext) will return a string which mimics the default
            %   property display for the object specified by obj.  The
            %   properties displayed are in the displayProps argument.
            %   This argument also determines the order in which properties
            %   are displayed.  The optional propPretext argument will
            %   insert a string before the display of the property name for
            %   each property.  This is useful when displaying the
            %   properties of a sub-object.
            %
            %   Properties and values are separated by a colon and all
            %   property names are right justified.
           
            largestPropLen = max(cellfun('length', displayProps));
            
            props = '';
            
            for i = 1:length(displayProps)
                curProp = displayProps{i};
                curPropValue = audiovideo.internal.writer.DisplayFormatter.propValToString(obj.(curProp));
                spaces = repmat(' ', [1 (largestPropLen - length(curProp) + 2)]);
                props = sprintf('%s  %s%s%s: %s\n', props, spaces, propPretext, curProp, curPropValue);
            end
            
             props = strrep(props, '\', '\\');
             props = strrep(props, '%', '%%');
        end
    end    
    
    methods (Static, Access=private)
        function str = propValToString( val )
            switch lower(class(val))
                case 'cell'
                    str = '{';
                    for ii=1:length(val)
                        str = sprintf('%s''%s''', str, val{ii});
                        if (ii ~= length(val))
                            str = sprintf('%s,', str);
                        end
                    end
                    str = sprintf('%s}', str);
                case 'char'
                    str = sprintf('''%s''', val);
                otherwise
                    str = num2str(val);
            end
        end
    end
end

