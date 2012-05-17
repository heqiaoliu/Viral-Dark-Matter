classdef SListMgr < hgsetget
%SLISTMGR Construct a list manager object with single selected element
%
%   Warning: This undocumented function may be removed in a future release.
%
%   H = COMMUTILS.SLISTMGR constructs a default list manager object H.
%
%   A list manager object has the following properties.
%
%   Property Name      Description
%   ----------------------------------------------------------------------------
%   NumberOfElements - Number of elements in the list manager.  This is a
%                      read-only property. 
%
%   commutils.SListMgr methods:
%     add                - Add a new element to the list
%     delete             - Remove an element from the list
%     getElements        - Get the elements in a sorted array
%     setSelectedElement - Set an element as the selected element
%     getSelectedElement - Get the selected element
%     setPosition        - Set the position of an element
%
%   See also COMMUTILS, COMMUTILS.BASECLASS

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2009/07/14 03:52:14 $

%===========================================================================
    % Private properties
    properties (SetAccess = private, GetAccess = private)
        Elements = [];          % Array of elements in the list
        SelectedElementIdx = 0; % Index of the selected element in Elements
        SortedIndecis = [];     % Sorted list of indecis of the elements
    end

    %===========================================================================
    % Private/Dependent properties
    properties (SetAccess = private, GetAccess = public, Dependent)
        NumberOfElements        % Length of the Elements array
    end

    %===========================================================================
    % Public methods
    methods
        function elem = getSelectedElement(this)
            % GETSELECTEDELEMENT Get the selected element of the list
            % E = GETSELECTEDELEMENT(H) returns the selected element of the
            % SLISTMGR object H.

            idx = this.SelectedElementIdx;
            if idx
                % If the list is not empty, return the selected element
                elem = this.Elements(idx);
            else
                elem = [];
            end
        end
        %-----------------------------------------------------------------------
        function setSelectedElement(this, index)
            % SETSELECTEDELEMENT Set the selected element of the list
            % SETSELECTEDELEMENT(H, IDX) sets the selected element of the
            % SLISTMGR object H to the IDXth element of the sorted list. 
            
            % Check the validity of index
            sigdatatypes.checkFiniteNonNegIntScalar(...
                [upper(class(this)) '/SETSELECTEDELEMENT'], 'IDX', index);
            if ( index > this.NumberOfElements )
                error('comm:commutils:SListMgr:InvalidIndex', ['IDX '...
                    'must be less than of equal to the number of elements '...
                    'of the list, which is %d.'], ...
                    this.NumberOfElements);
            end
            
            % Set the selected element index.  Note that, the input INDEX is the 
            % index for the sorted list, since the user sees the sorted list.
            % But the stored index is for the Elements array, not the sorted
            % list.  
            this.SelectedElementIdx = this.SortedIndecis(index);
        end
        %-----------------------------------------------------------------------
        function add(this, newElem)
            % ADD Add a new element to the list
            % ADD(H, ELEM) adds ELEM to the element list of the SLISTMGR object
            % H. 
            
            % Get the elements array
            elems = this.Elements;
            
            % Check the validity of newElement
            if ~isempty(elems)
                sigdatatypes.checkIsA([upper(class(this)) '/ADD'], 'ELEM', newElem, ...
                    class(elems));
            end
            
            % Add newElement to the list
            this.Elements = [elems; newElem];
            
            % Add the index to the sorted list.  New elements are added to the
            % end of the dorted list.
            numElems = this.NumberOfElements;
            this.SortedIndecis = [this.SortedIndecis; numElems];
            
            % Set the selected element to the new element
            this.SelectedElementIdx = numElems;
        end
        %-----------------------------------------------------------------------
        function elem = delete(this, index)
            % DELETE Remove an element from the list
            % DELETE(H, IDX) removes the IDXth element from the sorted list of
            % the SLISTMGR object H. 
            
            % Check the validity of index
            sigdatatypes.checkFiniteNonNegIntScalar(...
                [upper(class(this)) '/DELETE'], 'IDX', index);
            if ( index > this.NumberOfElements )
                error('comm:commutils:SListMgr:InvalidIndex', ['IDX '...
                    'must be less than of equal to the number of elements '...
                    'of the list, which is %d.'], this.NumberOfElements);
            end
            
            % Get the elements and sorted indecis array
            elems = this.Elements;
            sortedIdx = this.SortedIndecis;
            
            % Find the index in the Element array
            elemIndex = sortedIdx(index);
            elem = elems(elemIndex);
            
            % Remove from the list
            this.Elements = elems([1:elemIndex-1, elemIndex+1:end]);
            
            % Update the sorted list
            sortedIdx = sortedIdx([1:index-1, index+1:end]);
            sortedIdx(sortedIdx>elemIndex) = sortedIdx(sortedIdx>elemIndex) - 1;
            this.SortedIndecis = sortedIdx;
            
            % Update the selected
            if this.NumberOfElements == 0
                % The list is empty.  Set selected to 0.
                this.SelectedElementIdx = 0;
            else
                selectedIdx = this.SelectedElementIdx;
                if (selectedIdx == elemIndex)
                    % The selected element is deleted.
                    if index > this.NumberOfElements
                        % The deleted/selected one was the last element in the
                        % sorted list.  Selected the new last element.
                        this.SelectedElementIdx = sortedIdx(index-1);
                    else
                        % Select the one below the deleted one
                        this.SelectedElementIdx = sortedIdx(index);
                    end
                else
                    if (selectedIdx > elemIndex)
                        % The selected index will be one less, since an element
                        % is removed above the selected one.
                        this.SelectedElementIdx = selectedIdx-1;
                    else
                        % The selected index will not change
                    end
                end
            end

        end
        %-----------------------------------------------------------------------
        function [elems idx] = getElements(this)
            % GETSORTEDELEMENTS Get the sorted list of elements
            % [ELEMS IDX] = GETSORTEDELEMENTS(H, ELEMS) returns the sorted list
            % of the elements of the SLISTMGR object H.  IDX is the index of the
            % selected element in the list.
            
            % Get the sorted elements array
            elems = this.Elements(this.SortedIndecis);
            
            % Get the index of the selected element
            selectedIdx = this.SelectedElementIdx;
            if selectedIdx
                % The list is not empty
                idx = find(this.SortedIndecis == selectedIdx);
            else
                idx = 0;
            end
        end
        %-----------------------------------------------------------------------
        function setPosition(this, oldIdx, newIdx)
            % SETPOSITION Set the position of an element in the list
            % SETPOSITION(H, OLDIDX, NEWIDX) sets the position of the OLDIDXth
            % element of the SLISTMGR object H to NEWIDX. 
            
            % Check the validity of oldIdx
            sigdatatypes.checkFiniteNonNegIntScalar(...
                [upper(class(this)) '/SETPOSITION'], 'OLDIDX', oldIdx);
            if ( oldIdx > this.NumberOfElements )
                error('comm:commutils:SListMgr:InvalidIndex', ['OLDIDX '...
                    'must be less than or equal to the number of elements '...
                    'of the list, which is %d.'], this.NumberOfElements);
            end
            
            % Check the validity of newIdx
            sigdatatypes.checkFiniteNonNegIntScalar(...
                [upper(class(this)) '/SETPOSITION'], 'NEWIDX', newIdx);
            if ( newIdx > this.NumberOfElements )
                error('comm:commutils:SListMgr:InvalidIndex', ['NEWIDX '...
                    'must be less than or equal to the number of elements '...
                    'of the list, which is %d.'], this.NumberOfElements);
            end
            
            % Get the sorted indecis array
            sortedIdx = this.SortedIndecis;
            elemIdx = sortedIdx(oldIdx);

            % Determine the indecis of elements that need to be shifted to inset
            % the element to the new position.  Then, shift the elements.
            if newIdx < oldIdx
                % Get the indecis between the newIdx and the oldIdx.
                shiftedIdx = newIdx:oldIdx-1;

                % Shift them down by one to make space for the oldIdx'th element
                sortedIdx(shiftedIdx+1) = sortedIdx(shiftedIdx);
            else
                % Get the indecis between the newIdx and the oldIdx.
                shiftedIdx = oldIdx+1:newIdx;

                % Shift them up by one to make space for the oldIdx'th element
                sortedIdx(shiftedIdx-1) = sortedIdx(shiftedIdx);
            end
            
            % Assign the element to the new position
            sortedIdx(newIdx) = elemIdx;
            
            % Store
            this.SortedIndecis = sortedIdx;
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            %COPY    Make a copy
            %    C = COPY(H) makes a copy of the sorted list manager, H, and
            %    return in C.  The elements of the list are copied using shallow
            %    copy.

            % Create a new object
            h = commutils.SListMgr;
            
            h.Elements = this.Elements;
            h.SelectedElementIdx = this.SelectedElementIdx;
            h.SortedIndecis = this.SortedIndecis;
        end
        %-----------------------------------------------------------------------
        function h = clone(this)
            %CLONE   Make a clone
            %    C = COPY(H) makes a clone of the sorted list manager, H, and
            %    return in C.  The elements of the list are copied using deep
            %    copy.

            % Create a new object
            h = commutils.SListMgr;
            
            if isa(h.Elements(1), 'handle')
                % This is a handle.  We need to assign the copy of the object
                % pointed by the handle
                for p=1:this.NumberOfElements
                    h.Elements(p) = copy(this.Elements(p));
                end
            else
                % This is not a handle.  We can assign directly
                h.Elements = this.Elements;
            end

            h.SelectedElementIdx = this.SelectedElementIdx;
            h.SortedIndecis = this.SortedIndecis;
        end
    end % methods

    %===========================================================================
    % Set/Get methods
    methods
        function numElems = get.NumberOfElements(this)
            numElems = length(this.Elements);
        end
    end
end
%-------------------------------------------------------------------------------
% [EOF]