classdef BaseClass < hgsetget
    % BaseClass definition for MIMO package
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/06/11 15:56:48 $
    
    
    %===========================================================================
    % Protected properties
    properties (SetAccess = protected, GetAccess = protected)
        % The property Constructed is used by subclasses to speed up object
        % construction and initialization.
        %
        % The object constructor (e.g., h = mimo.Channel) calls the construct
        % method (construct.m).  In turn, the construct method usually calls the
        % initialize method.  However, both the object constructor and the
        % construct method generally call set methods, and some of these set
        % methods call the initialize method (if a property has a significant
        % effect on the initial conditions of an object).  The purpose of the
        % Constructed property is to avoid multiple calls to the initialize
        % method during object construction.
        %
        % The property Constructed is initialized to false.  After an object is
        % completely constructed and initialized, Constructed is set to true.
        % Set methods that call the initialize method use the following code:
        %    if h.Constructed, initialize(h); end
        Constructed = false;
    end % properties protected
    
    %===========================================================================
    % Protected methods
    methods
        function disp(h, props)
            %DISP  Object display.
            
            %If h is a vector use the built-in disp method
            if isscalar(h)
                error(nargchk(1, 2, nargin));
                
                % Create a structure, g, whose field names and field values are
                % equal to the object's property names and property values,
                % respectively.
                g = get(h);
                
                if nargin==2  % Property list specified
                    % Build a new structure, s, containing fields listed in the
                    % cell array 'props'. Set the field values to the respective
                    % field values of g. Remove fields of g which exist in s,
                    % thus leaving g with fields that don't appear in s.
                    for n = 1:length(props)
                        x = props{n};
                        s.(x) = g.(x);
                        g = rmfield(g, x);
                    end
                else
                    % Structure uses *all* object properties.
                    s = g;
                end
                
                % Display the structure.
                disp(s);
            else
                builtin('disp', h);                
            end
        end % disp
    end % protected methods    
end % classdef
% EOF