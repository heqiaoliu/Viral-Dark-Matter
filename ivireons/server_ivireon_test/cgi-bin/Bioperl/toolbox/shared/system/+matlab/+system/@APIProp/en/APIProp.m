classdef APIProp
%matlab.system.APIProp Property handling services for all System objects
%
%  This class provides property handling services and consistent behavior
%  across all System objects. Also, it declares (and provides default
%  implementations of) several methods that may be overridden in subclasses
%  to control display and tunability behavior

   
  %   Copyright 1995-2010 The MathWorks, Inc.

    methods
        function out=APIProp
            % Pass inputs to the parser, if we have any
        end

        function disp(in) %#ok<MANU>
            % DISP   Display System object
            %   DISP(H) displays the System object, H. Refer to the MATLAB DISP
            %   reference page for more information.
            %
            %   See also get, set, disp.
        end

        function get(in) %#ok<MANU>
            % GET    Get System object properties.
            %   V = GET(H, 'PropertyName') returns the value of the specified
            %   property for the System object, H.  If 'PropertyName' is replaced
            %   by a cell array of strings containing property names, GET returns a
            %   cell array of values.
            %
            %   S = GET(H) returns a structure in which each field name is the name
            %   of a property of H and each field contains the value of that
            %   property.
            %
            %   See also set, disp.
        end

        function getFixptRestrictions(in) %#ok<MANU>
            %RES=getFixptRestrictions(THIS,PROP) Return numerictype restrictions
            %   Return a cell array of restrictions for the input PROPERTY. These
            %   restrictions will be used to validate numerictype settings for the
            %   relevant PROP.
            %   Restrictions may be:
            %     Zero or one of:
            %       'SIGNED' | 'UNSIGNED' | 'AUTOSIGNED' | 'SPECSIGNED'
            %     And zero or one of
            %       'SCALED' | 'NOTSCALED'
            %     And zero or one of
            %       'ALLOWFLOAT'
            %
            %   'AUTOSIGNED' means the Signedness property of the numerictype
            %   object must be set to 'Auto'. 'SPECSIGNED' means the Signedness
            %   property of the numerictype object must NOT be set to 'Auto'
            %   (i.e., it must be 'Signed' or 'Unsigned').
            %
            %   'NOTSCALED' means the scaling must not be specified.
            %
            %   Not giving a restriction for signedness or scaling means that the
            %   relevant property for the numerictype object may be anything,
            %   including 'not specified'.
            %
            %   'ALLOWFLOAT' will allow numerictype settings with DataType equal
            %   to 'double' or 'single'.
        end

        function getHiddenProps(in) %#ok<MANU>
            %getHiddenProps Return list of 'currently irrelevant' properties
            %   Return a list of all props that are 'turned off' or irrelevant
            %   based on the current property values.
        end

        function getTunableProps(in) %#ok<MANU>
            %getTunableProps Return list of tunable properties
            %   Return a list of all props that are tunable
        end

        function isBooleanProp(in) %#ok<MANU>
            %status = ismember(prop,getBooleanProps(this));
        end

        function isFixptProp(in) %#ok<MANU>
            %status = ismember(prop,getFixptDisplayProps(this));
        end

        function isHiddenProp(in) %#ok<MANU>
            % getHiddenProps may very well be looking at hidden prop values - turn
            % off the warning for now
            % %%%
            % NOTE: The method 'allowHiddenAccess' will be going away soon!
            % NOTE: Do not call it outside of this class!
            % %%%
        end

        function isTunableProp(in) %#ok<MANU>
            %status = ismember(prop,getTunableProps(this));
        end

        function parseInputs(in) %#ok<MANU>
            %parseInputs - Parse System object constructor input arguments
            %   Parse System object constructor input arguments for value-only and
            %   property-value pairs and setup the System object accordingly
        end

        function set(in) %#ok<MANU>
            %SET    Set System object property values
            %   SET(H,'PropertyName',PropertyValue) sets the value of the specified
            %   property for the System object, H.
            %
            %   SET(H,'PropertyName1',Value1,'PropertyName2',Value2,...) sets
            %   multiple property values with a single statement.
            %
            %   Given a structure S, whose field names are object property names,
            %   SET(H,S) sets the properties identified by each field name of S with
            %   the values contained in the structure.
            %
            %   A = SET(H, 'PropertyName') returns the possible values for the
            %   specified property of the System object, H. The returned array is a
            %   cell array of possible value strings or an empty cell array if the
            %   property does not have a finite set of possible string values.
            %
            %   A = SET(H) returns all property names and their possible values for
            %   the System object, H. The return value is a structure whose field
            %   names are the property names of H, and whose values are cell arrays
            %   of possible property value strings or empty cell arrays.
            %
            %   See also get, disp.
        end

    end
    methods (Abstract)
    end
    properties
        %Description System object description
        %   This property gives a short description of the System object's
        %   functionality. It is a virtual (Dependent) property, used only in
        %   the object display.
        Description;

    end
end
