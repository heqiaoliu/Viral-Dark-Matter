classdef sorteddisp < hgsetget
%SORTEDDISP Class definition for sorted display of the class properties
%   This is an abstract class to support displaying the class properties in a
%   given order.
%
%   sigutils.sorteddisp methods:
%     disp  - Display the class properties 
%
%   See COMMSRC.PATTERN for an example subclass of SIGUTILS.SORTEDDISP.
%
%   See also SIGUTILS, SIGUTILS.PVPAIRS.

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $  $Date: 2009/07/14 03:59:31 $

    %===========================================================================
    % Public methods
    methods
        function disp(this)
%DISP   Display properties of a MATLAB object
%   DISP(H) displays properties of the MATLAB object H.

%   Properties are displayed in the order defined
%   by the getSortedDispProps method, which can be overwritten by the
%   subclass.  getSortedDispProps method may return a subset of properties
%   that can be displayed.  Then, only the ones returned by
%   getSortedDispProps method are displayed.

            %If displaying a single object use custom display. If trying
            %to display a vector of objects, then use the built-in display
            %function.            
            if isscalar(this)
                
                % This method displays the object properties in a
                % structure-like fashion in a given order.
                
                % Get the order of the properties
                sortedList = getSortedPropDispList(this);
                
                % Build a structure of properties
                s = get(this);
                
                % Find properties to be removed and remove from the
                % structure
                fn = setdiff(fieldnames(s), sortedList);
                s = rmfield(s, fn);
                
                % Order the fields
                s = orderfields(s, sortedList);
                
                % display the resulting structure
                disp(s);
            else
                builtin('disp', this);
            end
        end
    end
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function sortedList = getSortedPropDispList(this)
            % Get the sorted list of the properties to be displayed.  Overwrite
            % this method in the subclass to customize.
            
            sortedList = properties(this);
        end
    end
end
%---------------------------------------------------------------------------
% [EOF]