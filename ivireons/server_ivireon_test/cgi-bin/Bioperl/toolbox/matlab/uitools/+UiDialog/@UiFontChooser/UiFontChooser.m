classdef UiFontChooser < UiDialog.AbstractDialog
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/04/11 15:38:13 $
    properties
       %InitialFont refers to the font structure that gets applied to the dialog 
       InitialFont;
       %SelectedFont refers to the font structure that is returned by
       %the dialog upon selection by clicking ok
       SelectedFont
       %Title to be set on the dialog
       Title;
       
    end

      
    properties(SetAccess='public',GetAccess='public', Dependent=true)
        % Bunch of dependent properties not held as a state in the
        % object but a convenient property used for creating the
        % object. These properties are mere reflections of InitialFont
        % and they do not exist on their own. eg:
        % UiFontChooser('FontName','Arial') would reflect on the
        % InitialFont structure automatically. Any changes to the
        % InitialFont structure also updates these three properties.
        FontName;
        FontStyle; 
        FontSize;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Dependent property set&get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = set.InitialFont(obj, v)
            if isempty(v)
                
                % Do nothing and retain the font struct as it was
                % created by the object
            elseif (~isstruct(v))% || ~ismember(0,isfield(v,{'FontName','FontSize','FontAngle','FontWeight','FontUnits'})))
                error('MATLAB:UiFontChooser:InvalidFont','Font set must be of type struct');

            else
                %It is a structure and hence we take those properties
                %we are interested in, namely
                %FontName, FontAngle, FontWeight, FontUnits and
                %FontSize. Populate InitialFont based only on the
                %fields supplied. Incomplete structs are also allowed.
                if isfield(v,'FontName')
                    obj.InitialFont.FontName = v.FontName;
                end
                if isfield(v,'FontAngle')
                    obj.InitialFont.FontAngle = v.FontAngle;
                end
                if isfield(v,'FontWeight')
                    obj.InitialFont.FontWeight = v.FontWeight;
                end
                if isfield(v,'FontUnits')
                    obj.InitialFont.FontUnits = v.FontUnits;
                end
                if isfield(v,'FontSize')
                    obj.InitialFont.FontSize = v.FontSize;
                end
            end
            
             % Pass the Title property from the MCOS object to the java
        % object.
        function setPeerTitle(obj,v)
            if ~ischar(v)
                error('MATLAB:UiFontChooser:InvalidTitle','Title must be a string');
            end
            obj.Peer.setTitle(v);
        end 

        end

        function out = get.FontName(obj)
           out = obj.InitialFont.FontName;
        end
        function obj = set.FontName(obj, v)
           obj.InitialFont.FontName = v;
        end
        
        function out = get.FontStyle(obj)
            out = convertToStyle(obj,obj.InitialFont.FontWeight,obj.InitialFont.FontAngle);
        end
        
        function obj = set.FontStyle(obj, v)
            [obj.InitialFont.FontWeight,obj.Font.FontAngle] = convertFromStyle(obj,v);
        end
        
        function out = get.FontSize(obj)
            out = obj.InitialFont.FontSize;
        end
        function obj = set.FontSize(obj, v)
            obj.InitialFont.FontSize = v;
        end
        
    end
    
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other set&get methods for other properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        function obj = set.Title(obj,v)
            if ~ischar(v)
               error('MATLAB:UiFontChooser:InvalidTitle','Title set is invalid'); 
            end
            obj.Title = v;
        end
    end
    
    methods
        %Initializes the data members of the class.
        function initialize(obj)
            obj.InitialFont = defaultFont(obj);
            obj.Title = 'Font';
            
        end
        
       
        
        %Creates a default font structure. Also used to initialize the
        % object.
        function defStruct = defaultFont(obj)
            defStruct.FontName = 'Arial';
            defStruct.FontUnits = 'points';
            defStruct.FontSize = 10;
            [defStruct.FontWeight,defStruct.FontAngle] = convertFromStyle(obj,0);
        end
        
        % Returns 1 if v is one of the properties of this class.      
        function bool = isValidFieldName(obj,v)
            switch v
                case {'InitialFont','Title','FontName','FontStyle','FontSize'}
                    bool = true;
                otherwise
                    bool = false;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor - 2 ways to assign values to data members
        % 1. Property value pairs - 
        %    UiFontChooser('Title','Atitle','FontName,'Arial')
        % 2. Direct assignment
        %    a = UiFontChooser
        %    a.FontName = 'Arial
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = UiFontChooser(varargin)
            initialize(obj);
            if rem(length(varargin), 2) ~= 0
                error('MATLAB:UiFontChooser:UnpairedParamsValues','Param/value pairs must come in pairs.');
            end

            for i = 1:2:length(varargin)

                if ~ischar(varargin{i})
                    error ('MATLAB:UiFontChooser:illegalParameter', ...
                        'Parameter at input %d must be a string.', i);
                end

                fieldname = varargin{i};
                if isValidFieldName(obj,fieldname)
                    obj.(fieldname) = varargin{i+1};
                else
                    error('MATLAB:UiFontChooser:illegalParameter','Parameter "%s" is unrecognized.', ...
                        varargin{i});
                end
            end
            createPeer(obj);
        end
        % The only member function to open the dialog and make a
        % selection
        function show(obj)
            setPeerTitle(obj,obj.Title);
            setPeerInitialFont(obj,obj.InitialFont);
            jSelectedFont = obj.Peer.showDialog([]);
            if ~isempty(jSelectedFont)
                [fontWeight,fontAngle] = convertFromStyle(obj,jSelectedFont.getStyle);
                obj.SelectedFont    = struct('FontName',char(jSelectedFont.getName),'FontWeight',...
                    fontWeight,'FontAngle',fontAngle,'FontSize',jSelectedFont.getSize,'FontUnits','points');
                
            else
                obj.SelectedFont = [];
            end
        end
        % Member function to convert from style values[0..3] to a valid FontWeight
        % and FontAngle.
        function [fontWeight, fontAngle] = convertFromStyle(obj,fontstyle)
            switch fontstyle
                case 0,
                    fontWeight = 'normal';
                    fontAngle = 'normal';
                case 1,
                    fontWeight = 'bold';
                    fontAngle = 'normal';
                case 2,
                    fontWeight = 'normal';
                    fontAngle = 'italic';
                case 3,
                    fontWeight = 'bold';
                    fontAngle = 'italic';
                otherwise
                    fontWeight = 'normal';
                    fontAngle = 'normal';

            end
        end
        % Member function to convert to style values given strings
        % FontWeight and FontAngle.
        function fontStyle = convertToStyle(obj,fontWeight,fontAngle)
            switch [lower(fontWeight),lower(fontAngle)]
                case ['normal','normal']
                    fontStyle = 0;
                case ['bold','normal']
                    fontStyle = 1;
                case ['normal','italic']
                    fontStyle = 2;
                case ['bold','italic']
                    fontStyle = 3;
                otherwise
                    fontStyle = 0;
            end
            
        end
        
    end
    
    methods(Access = 'private')
        % Create a java peer object -com.mathworks.widgets.fonts.FontDialog
        function createPeer(obj)
            if ~isempty(obj.Peer)
                delete(obj.Peer);
            end
            obj.Peer = handle(awtcreate('com.mathworks.widgets.fonts.FontDialog','Ljava.lang.String;',obj.Title),'callbackproperties');
        end
        % Pass the InitialFont property From the MCOS object to the
        % java object
        function setPeerInitialFont(obj,v)
            if ~isstruct(v)
                error('MATLAB:UiFontChooser:InvalidInitialFont','InitialFont set must be of type struct');
            end
            javaFont = java.awt.Font(obj.FontName,obj.FontStyle,obj.FontSize);
            obj.Peer.setSelectedFont(javaFont);
        end
    end
    
    methods(Access='protected')
         % Pass the Title property from the MCOS object to the java
        % object.
        function setPeerTitle(obj,v)
            if ~ischar(v)
                error('MATLAB:UiFontChooser:InvalidTitle','Title must be a string');
            end
            obj.Peer.setTitle(v);
        end 
    end
            
    
end