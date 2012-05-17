classdef pvpairs  < hgsetget
%PVPAIRS Class definition for property-value pair construction utility
%   This is an abstract class to support the property-value pair construction of
%   MATLAB objects.
%
%   See COMMSRC.PATTERN for an example subclass of SIGUTILS.PVPAIRS.
%
%   See also SIGUTILS, SIGUTILS.SORTEDDISP.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2009/03/30 23:57:44 $

    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function sortedList = getSortedPropInitList(this)
            % GETSORTEDPROPINITLIST returns a list of properties in the order in
            % which the properties must be initialized.  If order is not
            % important, returns an empty cell array.

            sortedList = {};
        end

        %-----------------------------------------------------------------------
        function initPropValuePairs(this, varargin)
            % INITPROPVALUEPAIRS Initialize/set property-value pairs stored in
            % VARARGIN for the object THIS. Odd elements of VARARGIN are
            % property names; even elements are property values.

            try
                nPropValue = length(varargin);
                if floor(nPropValue/2) ~= nPropValue/2
                    error(generatemsgid('InvalidParamValue'), ['Number of ' ...
                        'values must be same as number of properties.']);
                end

                if ~iscellstr(varargin(1:2:end))
                    error(generatemsgid('InvalidPropValue'), ...
                        ['Property names must be strings.  Type '...
                        '"help %s" for proper usage.'], class(this));
                end

                % Get sorted arguments list
                sortedArgIdx = processArgList(this, varargin(1:2:end));

                % Set the properties.  Since we already checked that all the
                % properties are writable, we set them without further check.
                for k=sortedArgIdx
                    if ~isWritableProp(this, varargin{2*k-1})
                        % A read-only property is specified - error out
                        error(generatemsgid('ReadOnlyProperty'), ['%s is a ' ...
                            'read-only property.'], varargin{2*k-1});
                    else
                        set(this, varargin{2*k-1}, varargin{2*k});
                    end
                end
            catch exception
                throwAsCaller(exception);
            end
        end
    end

    %===========================================================================
    % Private methods
    methods (Access = private)
        function flag = isWritableProp(this, propName)
            % Check if the property is writable

            prop = findprop(this, propName);

            if isempty(prop)
                error(generatemsgid('NotAProperty'), ['%s is not a property '...
                    'of %s'], propName, class(this))
            end

            if strncmp(prop.SetAccess, 'public', 2)
                flag = 1;
            else
                flag = 0;
            end
        end
        %-----------------------------------------------------------------------
        function sortedArgList = processArgList(this, args)
            % Determine the sorted index list of arguments according to the
            % output of the getSortedPropInitList method. 

            % Get the sorted list
            sortedList = getSortedPropInitList(this);

            % Determine the end of list.  If we find an argument that is not in
            % the list, we will place it at the end.
            endOfList = length(sortedList);

            if ~isempty(sortedList)
                sortedArgList = zeros(size(args));
                for p=1:length(args)
                    % Find the index of the property in the sorted list and put
                    % into the sortedArgList array.  If the property is not in
                    % the sortedList, then it is not imported when it is set.
                    % In that case, put it at the end of the sortedArgList.
                    idx = strmatch(args{p}, sortedList,'exact');
                    if ~isempty(idx)
                        sortedArgList(p) = idx;
                    else
                        sortedArgList(p) = endOfList+1;
                        endOfList = endOfList + 1;
                    end
                end
                [dummy sortedArgList] = sort(sortedArgList);
            else
                sortedArgList = 1:length(args);
            end
        end
    end
end
%-------------------------------------------------------------------------------
% [EOF]