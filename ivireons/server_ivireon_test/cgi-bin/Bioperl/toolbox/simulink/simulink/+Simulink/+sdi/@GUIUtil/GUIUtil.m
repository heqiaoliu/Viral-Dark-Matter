classdef GUIUtil

    % A collection of utilities used in our HG GUIs
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    methods (Static = true)

    function HDialog = CreateDialog(Title)
        HDialog = dialog('Name',        Title,    ...
                         'Resize',      'on',     ...
                         'WindowStyle', 'normal', ...
                         'Visible',     'off',    ...
                         'Units',       'pixels'  ...
                         );
    end

    function HButton = CreateHGButton(Parent, Title)
        HButton = uicontrol('Parent',   Parent,       ...                            
                            'FontSize', 10,           ...
                            'Units',    'pixels',     ...
                            'Style',    'pushbutton', ...
                            'String',   Title         ...
                            );
    end

    function CenterDialogOnScreen(HDialog, DialogW, DialogH)
        % Get screen dimensions
        ScreenSize = get(0, 'ScreenSize');

        if DialogW > ScreenSize(3)
            DialogW = ScreenSize(3);
        end
        
        if DialogH > ScreenSize(4)
            DialogH = ScreenSize(4);
        end

        % Center the dialog on the screen
        DialogPos(1) = (ScreenSize(3) - DialogW) / 2;
        DialogPos(2) = (ScreenSize(4) - DialogH) / 2;
        DialogPos(3) = DialogW;
        DialogPos(4) = DialogH;

        if DialogPos(1) < 0
            DialogPos(1) = 0;
        end
        
        if DialogPos(2) < 0
            DialogPos(2) = 0;
        end

        % Set dialog position
        set(HDialog, 'Position', DialogPos);
    end

    function [NewDialogW, NewDialogH] = LimitDialogExtents(HDialog,    ...
                                                           MinDialogW, ...
                                                           MinDialogH)
        % Get dialog position
        OldDialogPos = get(HDialog, 'Position');

        % Cache originally requestion position and extents
        OldDialogX = OldDialogPos(1);
        OldDialogY = OldDialogPos(2);
        OldDialogW = OldDialogPos(3);
        OldDialogH = OldDialogPos(4);

        % Validate position and extents to specified mins
        NewDialogX = OldDialogX;
        NewDialogY = OldDialogY;
        NewDialogW = max(OldDialogW, MinDialogW);
        NewDialogH = max(OldDialogH, MinDialogH);

        % Adjust for the new Y to keep dialog from jumping
        if   (OldDialogW < MinDialogW) ...
          || (OldDialogH < MinDialogH)
            NewDialogY = OldDialogY + OldDialogH - NewDialogH;
        end

        % Form new position matrix
        NewDialogPos = [NewDialogX, NewDialogY, NewDialogW, NewDialogH];
        
        % Update dialog position
        set(HDialog, 'Position', NewDialogPos);
    end

    function [Button, Container] = CreateButton(Parent, Text, IconName)
        % Create button
        Button = javaObjectEDT('com.mathworks.mwswing.MJButton');
        
        % Set text
        Button.setText(Text);
        
        % Set icon if present
        if ~isempty(IconName)
            Icon = javaObjectEDT('javax.swing.ImageIcon', IconName);
            Button.setIcon(Icon);
        end
        
        % Make button HG accessible
        [~, Container] = javacomponent(Button, [0 0 1 1], Parent);
        
        % Position via pixels
        set(Container, 'Units', 'pixels');
    end

    function [TT,              ...
              TTComponent,     ...
              TTContainer,     ...
              TTModel,         ...
              TTSortableModel, ...
              TTScrollPane     ...
              ] = CreateTreeTable(HDialog, RowHeight, ClickCountToStart)
    
        TT           = javaObjectEDT('com.jidesoft.grid.TreeTable');
        TTScrollPane = javaObjectEDT('javax.swing.JScrollPane');
        TTScrollPane.getViewport.setView(TT);
        [TTComponent, TTContainer] = javacomponent(TTScrollPane, ...
                                                   [0 0 1 1],    ...
                                                   HDialog);
        TTModel  = javaObjectEDT('javax.swing.table.DefaultTableModel');
        TTSortableModel = javaObjectEDT('com.jidesoft.grid.SortableTableModel', ...
                                        TTModel);
        TT.setModel(TTSortableModel);
        TT.setClickCountToStart(ClickCountToStart);
        TT.setRowHeight(RowHeight);
        TT.setShowSortOrderNumber(false);
        TTScrollPane.getViewport.setBackground(java.awt.Color.white);
        set(TTContainer, 'Units', 'pixels');
    end

    function IconPath = CreateSDIIconPath(IconName)
        IconPath = fullfile(matlabroot,  ...
                            'toolbox',   ...
                            'simulink',  ...
                            'simulink',  ...
                            '+Simulink', ...
                            '+sdi',      ...
                            'Icons',     ...
                            IconName); %#ok<MCTBX,*MCMLR>
    end

    function IconPath = CreateMATLABIconPath(IconName)
        IconPath = fullfile(matlabroot, ...
                            'toolbox',  ...
                            'matlab',   ...
                            'icons',    ...
                            IconName); %#ok<MCTBX>
    end
    
    function iconPath = createMatlabJavaIconPath(iconName)
        iconPath = fullfile(matlabroot, ...
                            'java',     ...
                            'src',      ...
                            'com',      ...
                            'mathworks',...
                            'common',   ...
                            'icons',    ...
                            'resources',...
                            iconName); %#ok<MCTBX>
    end

    function IconData = ReadSDIIcon(IconName)
        % Get path to icon
        IconPath = Simulink.sdi.GUIUtil.CreateSDIIconPath(IconName);

        % Read icon data
        IconData = Simulink.sdi.GUIUtil.IconRead(IconPath);
    end

    function IconData = ReadMATLABIcon(IconName)
        % Get path to icon
        IconPath = Simulink.sdi.GUIUtil.CreateMATLABIconPath(IconName);

        % Read icon data
        IconData = Simulink.sdi.GUIUtil.IconRead(IconPath);
    end
    
    function iconData = readJavaCommonIcon(iconName)
        % Get path to icon
        iconPath = Simulink.sdi.GUIUtil.createMatlabJavaIconPath(iconName);

        % Read icon data
        iconData = Simulink.sdi.GUIUtil.IconRead(iconPath);
    end
    
    function out = readMATFile(fileName)
        filePath = Simulink.sdi.GUIUtil.CreateSDIIconPath(fileName);
        out = load(filePath);                
    end

    % Taken as-is from code by Bill York
    function cdata = IconRead(filename,guessalpha)
    % Helper function
    % ICONREAD read an image file and convert it to CData for a HG icon.
    %
    % CDATA=ICONREAD(FILENAME)
    %   Read an image file and convert it to CData with automatic transparency
    %   handling. If the image has transparency data, PNG files sometimes do,
    %   the transparency data is used. If the image has no CData, the top left
    %   pixel is treated as the transparent color.
    %
    % CDATA=ICONREAD(FILENAME, FALSE)
    %   Same as above but suppress the usage of the top left pixel for images
    %   with no transparency data. This may require the caller to handle the
    %   transparency explicitly. View the contents of this m-file for an
    %   example of how to handle transparency.
    %
    % Example:
    %
    % icon = fullfile(matlabroot,'toolbox','matlab','icons','matlabicon.gif');
    % uitoggletool('CData',iconread(icon));
    %
    % See also IMREAD.
    % 
    % Copyright 2009 The MathWorks, Inc.
    % TODO change this

    if nargin < 2
        guessalpha = true;
    end

    [p,f,ext] = fileparts(filename); %#ok<ASGLU>
    % if this is a mat-file, look for the variable cdata (or something like it)
    if isequal(lower(ext),'.mat')
        cdata = [];
        s = whos('-file', filename);
        for i=1:length(s)
            if ~isempty(strfind(lower(s(i).name), 'cdata'))
                data = load(filename,s(i).name);
                cdata = data.(s(i).name);
            end
        end
        return
    end

    [cdata, map, alpha] = imread(filename);
    if isempty(cdata)
        return;
    end

    if isempty(map)
        if isinteger(cdata)
            cname = class(cdata);
            cdata = double(cdata);
            cdata = cdata/double(intmax(cname));
        else
            cdata = double(cdata);
            cdata = cdata/255;
        end
    else
        cdata = ind2rgb(cdata,map);
    end

    if isempty(alpha)
        if ~guessalpha
            return;
        end
        % guess the alpha pixel by using the top left pixel in the icon
        ap1 = cdata(1,1,1);
        ap2 = cdata(1,1,2);
        ap3 = cdata(1,1,3);
        alpha = cdata(:,:,1) == ap1 & cdata(:,:,2) == ap2 & cdata(:,:,3) == ap3;
        alpha = ~alpha;
    end

    % process alpha data
    r = cdata(:,:,1);
    r(alpha == 0) = NaN;
    g = cdata(:,:,2);
    g(alpha == 0) = NaN;
    b = cdata(:,:,3);
    b(alpha == 0) = NaN;
    cdata = cat(3,r,g,b);
    end

  end % methods
  
end % classdef Util