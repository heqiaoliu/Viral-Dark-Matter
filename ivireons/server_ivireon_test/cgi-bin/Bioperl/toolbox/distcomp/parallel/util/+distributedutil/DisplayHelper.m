%DISPLAYHELPER - base class for implementing disp(lay) for distributed
%objects.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/02/06 14:17:14 $

classdef DisplayHelper
    properties ( Access = protected )
        % Properties passed directly into the constructor
        Name
        ClassName
        Value

        % Derived property
        IsTruncated
    end

    
    methods ( Abstract )
        doDisp( obj );
        doDisplay( obj );
    end
    
    methods ( Abstract, Access = protected )
        formatEndTruncationMsg( obj );
    end
    
    methods ( Access = protected )
        
        function nameLine( obj, type, rangeStr, truncMessage )
        % nameLine: display the "D(:,:,2,3,4) = < msg > " line if
        % required. 
        % type: 'display' or 'disp'
        % rangeStr: a string like '(:,:,2,3,4)' if required
        % truncMessage: a message to display at the end of the nameLine if required.
            if strcmp( type, 'display' )
                show = true;
                name = obj.Name;
            else
                % disp - only show this line if there's a range
                if isempty( rangeStr )
                    show = false;
                else
                    show = true;
                    name = '';
                end
            end
            if show
                fprintf( 1, '%s%s%s =%s\n%s', ...
                         obj.separator(), name, rangeStr, truncMessage, obj.separator() );
            end
        end
        
        function showEndTruncationMessage( obj )
        % showEndTruncationMessage - common function for the final truncation message
            if obj.IsTruncated
                fprintf( 1, '%s\n%s', obj.formatEndTruncationMsg(), obj.separator() );
            end
        end
        
        function s = separator( obj ) %#ok<MANU>
            if isequal( get( 0, 'FormatSpacing' ), 'compact' )
                s = '';
            else
                s = sprintf( '\n' );
            end
        end
    end
end

