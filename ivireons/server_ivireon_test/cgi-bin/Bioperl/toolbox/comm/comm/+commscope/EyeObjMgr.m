classdef EyeObjMgr < hgsetget
    %EYEOBJMGR Construct an eye diagram object manager object
    %
    %   Warning: This undocumented function may be removed in a future release.

    % Copyright 2008 The MathWorks, Inc.
    % $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:14:36 $

    %===========================================================================
    % Private properties
    properties (SetAccess = private, GetAccess = private)
        EyeDiagramObjects       % List manager
    end

    %===========================================================================
    % Public methods
    methods
        function this = EyeObjMgr
            % Constructor
            this.EyeDiagramObjects = commutils.SListMgr;
        end
        %-----------------------------------------------------------------------
        function eyeObj = getSelected(this)
            % Get the selected eye diagram object
            eyeObj = getSelectedElement(this.EyeDiagramObjects);
        end
        %-----------------------------------------------------------------------
        function success = setSelected(this, index)
            % Set the selected eye diagram object
            success = 1;
            try
                setSelectedElement(this.EyeDiagramObjects, index);
            catch exception %#ok
                success = 0;
            end
        end
        %-----------------------------------------------------------------------
        function import(this, eyeObjStr)
            % Import the eye diagram object using the eye diagram object
            % structure.  First make a copy of the eye diagram object.
            hEyeCopy = copy(eyeObjStr.Handle);
            hEyeCopy.PrivScopeHandle = eyeObjStr.Handle.PrivScopeHandle;
            eyeObjStr.Handle = hEyeCopy;

            % Add to the list
            add(this.EyeDiagramObjects, eyeObjStr);
        end
        %-----------------------------------------------------------------------
        function success = delete(this, index)
            % Remove the eye diagram object at INDEX in the list.
            success = 1;
            try
                delete(this.EyeDiagramObjects, index);
            catch exception %#ok
                success = 0;
            end
        end
        %-----------------------------------------------------------------------
        function deleteAll(this)
            % Remove all the eye diagram objects.
            for p=1:this.EyeDiagramObjects.NumberOfElements
                delete(this.EyeDiagramObjects, 1);
            end
        end
        %-----------------------------------------------------------------------
        function success = moveup(this, index)
            % Move the eye diagram object at INDEX in the list up, i.e. to index
            % value INDEX-1.  If the object is already at the top, then don't do
            % anything.
            success = 0;

            if index > 1
                setPosition(this.EyeDiagramObjects, index, index-1);
                success = 1;
            end
        end
        %-----------------------------------------------------------------------
        function success = movedown(this, index)
            % Move the eye diagram object at INDEX in the list down, i.e. to
            % index value INDEX+1.  If the object is already at the bottom, then
            % don't do anything.
            success = 0;

            objList = this.EyeDiagramObjects;
            if index < objList.NumberOfElements
                setPosition(objList, index, index+1);
                success = 1;
            end
        end
        %-----------------------------------------------------------------------
        function [eyeObjNames idx] = getSortedNameList(this)
            % [NAMES IDX] = GETSORTEDNAMESLIST(H) returns the cell array list of
            % eye diagram object names in order.  IDX is the index of the
            % selected eye diagram object in the list.

            [eyeObjs idx] = getElements(this.EyeDiagramObjects);

            numObjects = length(eyeObjs);

            if numObjects
                eyeObjNames = cell(numObjects, 1);
                for p=1:numObjects
                    eyeObjNames{p} = ...
                        [eyeObjs(p).Source '_' eyeObjs(p).Name];
                end
            else
                eyeObjNames = '<No eye diagram object loaded>';
                idx = 1;
            end
        end
        %-----------------------------------------------------------------------
        function N = getNumberOfEyeObjects(this)
            % Get the number of eye objects
            N = this.EyeDiagramObjects.NumberOfElements;
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            %COPY    Make a copy of THIS and return in H.
            %   If a property is a handle, instead of using '=', this method
            %   uses copy.  Replace this method with commutils.baseclass
            %   copy once we conver the baseclass to MCOS.

            % Get the class name
            className = class(this);

            % Create a new object
            h = eval(className);
            
            % Get the meta class
            thisClass = metaclass(this);

            % Get the property names
            props = thisClass.Properties;

            % Get the properties of the object
            for p=1:length(props)
                name = props{p}.Name;
                refValue = get(this, name);
                if isa(refValue, 'handle')
                    % This is a handle.  We need to assign the copy of the object
                    % pointed by the handle
                    set(h, name, copy(refValue));
                else
                    % This is not a handle.  We can assign directly
                    set(h, name, refValue);
                end
            end
        end % function copy
        %-----------------------------------------------------------------------
        function eyeObjs = getEyeObjects(this)
            % eyeObjs = getEyeObjects(H) returns the eye diagram objects in the
            % list in a vector. 

            eyeObjs = getElements(this.EyeDiagramObjects);
        end
        %-----------------------------------------------------------------------
        function setFigureHandle(this, hFig)
            numObjs = getNumberOfEyeObjects(this);
            
            if numObjs
                % Store the selected index
                [eyeObjNames selectedIdx] = getSortedNameList(this);

                % We need to first retrieve the eye diagram object
                % structure, set the figure handle, re-import, and
                % remove the old copy, starting from the first element.
                % When we are done, the list will have the same order as
                % the original order.  At the end, we will set the
                % selected element to the original selected element.
                for p=1:numObjs
                    setSelected(this, 1);
                    eyeObj = getSelected(this);
                    delete(this,1);
                    set(eyeObj.Handle, 'PrivScopeHandle', hFig);
                    import(this, eyeObj);
                end
                setSelected(this, selectedIdx);
            end
        end
        %-----------------------------------------------------------------------
    end % methods
    %---------------------------------------------------------------------------
end % classdef
%-------------------------------------------------------------------------------
% [EOF]