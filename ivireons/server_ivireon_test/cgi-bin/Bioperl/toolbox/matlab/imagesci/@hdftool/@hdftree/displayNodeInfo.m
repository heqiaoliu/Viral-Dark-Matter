function displayNodeInfo(this, selectedNode, parentNode)
%DISPLAYNODEINFORMATION Displays node information.
%   In particular, node information is displayed in the lower right panel
%   in response to selection of that node by the user.
%
%   Function arguments
%   ------------------
%   THIS: the fileTree object instance.
%   SELECTEDNODE: the selected fileTree node.
%   PARENTNODE: the parent of the selected fileTree node.
%   TREE: the UITree object.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/03/04 16:29:49 $

    % Get the STRUCTURE associated with the node
    infoStruct = selectedNode.nodeinfostruct;

    parentStruct = parentNode.nodeinfostruct;

    frame = this.fileFrame;
    lowerRightPanel = frame.lowerRightPanel;

    % Determine the type of node this is
    type = infoStruct.NodeType;

    switch (type)
        case 'File'
            displayFile
        case 'View'
            displayView
        case 'Vgroup'
            displayVgroup
        case 'Scientific Data Set'
            displaySDS
        case 'Vdata set'
            displayVdata
        case '8-Bit Raster Image'
            displayRaster8
        case '24-Bit Raster Image'
            displayRaster24
        case 'HDF-EOS Point'
            displayPoint
        case 'HDF-EOS Point Data Fields'
            displayPointDataFields
        case 'HDF-EOS Grid'
            displayGrid
        case 'HDF-EOS Grid Data Fields'
            displayGridDataField
        case 'HDF-EOS Swath'
            displaySwath
        case 'HDF-EOS Swath Data Fields'
            displaySwathDataField
        case 'HDF-EOS Swath Geolocation Fields'
            displayGeolocation
        otherwise
            displayDefault
    end

    %======================================================================
    function displayFile

        metadataText = getNameMetaData;
        metadataText = strrep(metadataText, sprintf('\n'), '<br>');
        metadataText = strrep(metadataText, sprintf('\t'), '&nbsp;');

        if isfield(selectedNode.nodeinfostruct, 'Attributes')
            moreText = getAttributesMetaData(selectedNode.nodeinfostruct);
            metadataText = [metadataText moreText];
        end
        
        frame.setMetadataText(metadataText);
        frame.setDatapanel('default', selectedNode);
    end

    %======================================================================
    function displayView
        metadataText = getNameMetaData;

        if isfield(infoStruct,'Attributes')
            attrLen = length(infoStruct.Attributes);
            for n = 1:attrLen
                metadataText = addMetadataField(metadataText,...
                    infoStruct.Attributes(n).Name,...
                    num2str(infoStruct.Attributes(n).Value));
            end
        end
        metadataText = strrep(metadataText, sprintf('\n'), '<br>');
        metadataText = strrep(metadataText, sprintf('\t'), '&nbsp;&nbsp;&nbsp;&nbsp;');

        frame.setMetadataText(metadataText);
        if strcmp(infoStruct.NodeViewType, 'EOS')
            frame.setDatapanel('View file as HDF-EOS', selectedNode);
        else
            frame.setDatapanel('View file as HDF', selectedNode);
        end
    end

    %======================================================================
    function displayVgroup
        metadataText = getNameMetaData;
        metadataText = addMetadataField(...
            metadataText, 'Class', infoStruct.Class);
        frame.setMetadataText(metadataText);
        frame.setDatapanel('HDF Vgroup', selectedNode);
    end

    %======================================================================
    function displayVdata
        metadataText = getNameMetaData;
        metadataText = addMetadataField(...
            metadataText, 'Class', infoStruct.Class);
        metadataText = addMetadataField(...
            metadataText, 'Number of Records', num2str(infoStruct.NumRecords));
        frame.setMetadataText(metadataText);

        if isempty(this.staticVdataPanel)
            this.staticVdataPanel = hdftool.vdatapanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticVdataPanel, selectedNode);
    end

    %======================================================================
    function displaySDS
        % set the metadata
        metadataText = getNameMetaData;
        metadataText = sprintf('%s%s<br>',...,
            metadataText, getDimensionMetaData(infoStruct));
        metadataText = addMetadataField(...
            metadataText, 'Precision', infoStruct.DataType);
        metadataText = sprintf('%s%s',...
            metadataText, getAttributesMetaData(infoStruct));
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticSdsPanel)
            this.staticSdsPanel = hdftool.sdspanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticSdsPanel, selectedNode);
    end

    %======================================================================
    function displayRaster8
        % set the metadata
        metadataText = getNameMetaData;
        metadataText = addMetadataField(...
            metadataText, 'Width', num2str(infoStruct.Width));
        metadataText = addMetadataField(...
            metadataText, 'Height', num2str(infoStruct.Height));
        trueFalse = {'false','true'};
        metadataText = addMetadataField(...
            metadataText, 'Colormap', trueFalse{infoStruct.HasPalette+1});
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticRasterPanel)
            this.staticRasterPanel = hdftool.rasterpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticRasterPanel, selectedNode);
    end

    %======================================================================
    function displayRaster24
        % set the metadata
        metadataText = getNameMetaData;
        metadataText = addMetadataField(...
            metadataText, 'BitDepth', '24');
        metadataText = addMetadataField(...
            metadataText, 'Width', num2str(infoStruct.Width));
        metadataText = addMetadataField(...
            metadataText, 'Height', num2str(infoStruct.Height));
        metadataText = addMetadataField(...
            metadataText, 'Interlace', infoStruct.Interlace);
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticRasterPanel)
            this.staticRasterPanel = hdftool.rasterpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticRasterPanel, selectedNode);
    end

    %======================================================================
    function displayPoint
        % Set the metadata
        metadataText = getNameMetaData;
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticPointPanel)
            this.staticPointPanel = hdftool.pointpanel(this, lowerRightPanel);
        end
        frame.setDatapanel('HDF-EOS Point', selectedNode);
    end

    %======================================================================
    function displayPointDataFields
        % Set the metadata
        metadataText = getNameMetaData;
        % get Point Meta Data
        metadataText = addMetadataField(...
            metadataText, 'Number of Records', num2str(infoStruct.NumRecords));
        % get Attributes Meta Data
        pointInfo = getParentStruct;
        metadataText = sprintf('%s%s',...
            metadataText, getAttributesMetaData(pointInfo));
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticPointPanel)
            this.staticPointPanel = hdftool.pointpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticPointPanel, selectedNode);
    end

    %======================================================================
    function displayGrid
    
    	if ( isempty(infoStruct.Projection.ProjCode) ...
                && isempty(infoStruct.Projection.ZoneCode) ...
                && isempty(infoStruct.Projection.SphereCode) ...
                && isempty(infoStruct.Projection.ProjParam) )
        	frame.setMetadataText('');
	    	errordlg('This grid does not have a valid projection defined.', 'Invalid Projection');
		else
        	% Set the metadata
	        metadataText = getNameMetaData;
			% get Attributes Meta Data
			metadataText = [metadataText, getAttributesMetaData(infoStruct)];
			% get Grid Meta Data
			metadataText = [metadataText, getGridMetaData(infoStruct)];
			frame.setMetadataText(metadataText);
	    end

        % set the panel
        if isempty(this.staticGridPanel)
            this.staticGridPanel = hdftool.gridpanel(this, lowerRightPanel);
        end
        frame.setDatapanel('HDF-EOS Grid', selectedNode);
    end

    %======================================================================
    function displayGridDataField
        % Set the metadata
        metadataText = getNameMetaData;
        % get Dimension Metadata
        metadataText = [metadataText, getDimensionMetaData(infoStruct) '<br>'];
        % get Tile Dimension Metadata
        metadataText = [metadataText, getTileDimMetaData(infoStruct)];
        % get Attributes Metadata
        gridInfo = getParentStruct;
        metadataText = [metadataText, getAttributesMetaData(gridInfo)];
        % get Grid Metadata
        metadataText = [metadataText, getGridMetaData(gridInfo)];
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticGridPanel)
            this.staticGridPanel = hdftool.gridpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticGridPanel, selectedNode);
    end

    %======================================================================
    function metadataText = getGridMetaData(tmpStruct)
        metadataText = addMetadataField('',...
            'Upper Left Grid Corner', num2str(tmpStruct.UpperLeft));
        metadataText = addMetadataField(metadataText,...
            'Lower Right Grid Corner', num2str(tmpStruct.LowerRight));
        metadataText = addMetadataField(metadataText,...
            'Rows', num2str(tmpStruct.Rows));
        metadataText = addMetadataField(metadataText,...
            'Columns', num2str(tmpStruct.Columns));
        metadataText = addMetadataField(metadataText,...
            'Projection', num2str(tmpStruct.Projection.ProjCode));
        metadataText = addMetadataField(metadataText,...
            'Zone Code', num2str(tmpStruct.Projection.ZoneCode));
        metadataText = addMetadataField(metadataText,...
            'Sphere', getSphereFromCode(tmpStruct.Projection.SphereCode));
        projStr = getProjectionParams(tmpStruct.Projection.ProjCode,...
            tmpStruct.Projection.ProjParam);
        metadataText = sprintf('%s%s', metadataText,projStr);
        metadataText = addMetadataField(metadataText,...
            'Origin Code', tmpStruct.OriginCode);
        metadataText = addMetadataField(metadataText,...
            'Pixel Registration Code', tmpStruct.PixRegCode);
    end

    %======================================================================
    function metadataText = getTileDimMetaData(tmpStruct)
        tileDims = tmpStruct.TileDims;
        if isempty(tileDims)
            metadataText = addMetadataField('',...
                'Tile Dimensions', 'No Tiles');
        else
            metadataText = addMetadataField('',...
                'Tile Dimensions', num2str(tileDims));
        end
    end

    %======================================================================
    function displaySwath
        % Set the metadata
        metadataText = getNameMetaData;
        % get the Map, Offset and Increment
        metadataText = [metadataText, getMapInfoMetaData(infoStruct)];
        % get the IdxMapInfo, Offset and Increment
        metadataText = [metadataText, getIdxMapInfoMetaData(infoStruct)];
        % get the attributes information
        metadataText = [metadataText, getAttributesMetaData(infoStruct)];
        frame.setMetadataText(metadataText);

        % set the panel
        frame.setDatapanel('HDF-EOS Swath', selectedNode);
    end

    %======================================================================
    function displaySwathDataField
        % Set the metadata
        metadataText = getNameMetaData;
        % get Dimension Meta Data
        metadataText = [metadataText getDimensionMetaData(infoStruct) '<br>'];
        % get MapInfo Meta Data
        swathInfo = getParentStruct;
        metadataText = [metadataText getMapInfoMetaData(swathInfo)];
        % get IdxMapInfo Meta Data
        metadataText = [metadataText getIdxMapInfoMetaData(swathInfo)];
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticSwathPanel)
            this.staticSwathPanel = hdftool.swathpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticSwathPanel, selectedNode);
    end

    %======================================================================
    function displayGeolocation
        % Set the metadata
        metadataText = getNameMetaData;
        % get Dimension Meta Data
        metadataText = [metadataText getDimensionMetaData(infoStruct) '<br>'];
        % get MapInfo Meta Data
        swathInfo = getParentStruct;
        metadataText = [metadataText getMapInfoMetaData(swathInfo)];
        % get IdxMapInfo Meta Data
        metadataText = [metadataText getIdxMapInfoMetaData(swathInfo)];
        frame.setMetadataText(metadataText);

        % Set the panel
        if isempty(this.staticSwathPanel)
            this.staticSwathPanel = hdftool.swathpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticSwathPanel, selectedNode);
    end

    %======================================================================
    function displayDefault
        metadataText = getNameMetaData;
        frame.setMetadataText(metadataText);
        frame.setDatapanel('Unrecognized node type.', selectedNode);
    end

    %======================================================================
    function pStruct = getParentStruct
        pStruct = parentStruct;
    end

    %======================================================================
    function metadataText = getNameMetaData
        metadataText = addMetadataField('', 'Name', selectedNode.displayname);
    end

    %======================================================================
    function metadataText = getDimensionMetaData(tmpStruct)
        metadataText = sprintf('<b>%s: </b> <br>', xlate('Dimensions'));
        dimLen = length(tmpStruct.Dims);
        for n = 1:dimLen
            metadataText = addMetadataField(metadataText,...
                'Name',tmpStruct.Dims(n).Name);
            metadataText = addMetadataField(metadataText,...
                'Size', num2str(tmpStruct.Dims(n).Size));
        end
    end

    %======================================================================
    function metadataText = getMapInfoMetaData(tmpStruct)
        metadataText = '';
        mapLen = length(tmpStruct.MapInfo);
        for n = 1:mapLen
            metadataText = addMetadataField(metadataText,...
                'Map', tmpStruct.MapInfo(n).Map);
            metadataText = addMetadataField(metadataText,...
                'Offset', num2str(tmpStruct.MapInfo(n).Offset));
            metadataText = addMetadataField(metadataText,...
                'Increment', num2str(tmpStruct.MapInfo(n).Increment));
        end
    end

    %======================================================================
    function metadataText = getIdxMapInfoMetaData(tmpStruct)
        metadataText = '';
        idxLen = length(tmpStruct.IdxMapInfo);
        for n = 1:idxLen
            metadataText = addMetadataField(metadataText,...
                'Index Map', tmpStruct.IdxMapInfo(n).Map);
            metadataText = addMetadataField(metadataText,...
                'Index Size', num2str(tmpStruct.IdxMapInfo(n).Size));
        end
    end

    %======================================================================
    function metadataText = getAttributesMetaData(tmp)
        metadataText = '';
        attrLen = length(tmp.Attributes);
        for n = 1:attrLen
            metadataText = addMetadataField(metadataText,...
                tmp.Attributes(n).Name, num2str(tmp.Attributes(n).Value));
        end

    end

end

%======================================================================
function s = getSphereFromCode(sphereCode)

    codes = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19];
    names = {
        xlate('Clarke 1866')
        xlate('Clarke 1880')
        xlate('Bessel')
        xlate('International 1967')
        xlate('International 1909')
        xlate('WGS 72')
        xlate('Everest')
        xlate('WGS 66')
        xlate('GRS 1980')
        xlate('Airy')
        xlate('Modified Airy')
        xlate('Modified Everest')
        xlate('WGS 84')
        xlate('Southeast Asia')
        xlate('Australian National')
        xlate('Krassovsky')
        xlate('Hough')
        xlate('Mercury 1960')
        xlate('Modified Mercury 1968')
        xlate('Sphere of Radius 6370997m')};

    i = find(codes==sphereCode);
    if ~isempty(i)
        s = names{i};
    else
        s = xlate('unknown sphere');
    end

end

%======================================================================
function mdText = getProjectionParams(proj,param)

    mdText = addMetadataField('', 'Projection Parameters','');

    switch(proj)
      case 'geo'
        
      case 'utm'
        mdText = addMetadataField(mdText, 'Lon/Z', num2str(param(1)));
        mdText = addMetadataField(mdText, 'Lat/Z', num2str(param(2)));
      
      case 'lamcc'
        mdText = addMetadataField(mdText, 'Semi-Major Axis', num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, 'Semi-Minor Axis', num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, 'Eccentricity squared', num2str(-param(2)));        
        end
        mdText = addMetadataField(mdText, 'First Standard Parallel Lat', num2str(param(3)));
        mdText = addMetadataField(mdText, 'Second Standard Parallel Lat', num2str(param(4)));
        mdText = addMetadataField(mdText, 'Central Meridian', num2str(param(5)));
        mdText = addMetadataField(mdText, 'Projection Origin Lat', num2str(param(6)));
        mdText = addMetadataField(mdText, 'False Easting', num2str(param(7)));
        mdText = addMetadataField(mdText, 'False Northing', num2str(param(8)));

      case 'ps'
        mdText = addMetadataField(mdText, 'Semi-Major Axis', num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, 'Semi-Minor Axis', num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, 'Eccentricity squared', num2str(-param(2)));        
        end
        mdText = addMetadataField(mdText, 'Lon below pole of map', num2str(param(5)));
        mdText = addMetadataField(mdText, 'True Scale Lat', num2str(param(6)));
        mdText = addMetadataField(mdText, 'False Easting', num2str(param(7)));
        mdText = addMetadataField(mdText, 'False Northing', num2str(param(8)));

      case 'polyc'
        mdText = addMetadataField(mdText, 'Semi-Major Axis', num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, 'Semi-Minor Axis', num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, 'Eccentricity', num2str(-param(2)));        
        end
        mdText = addMetadataField(mdText, 'Central Meridian', num2str(param(5)));
        mdText = addMetadataField(mdText, 'Projection Origin Lat', num2str(param(6)));
        mdText = addMetadataField(mdText, 'False Easting', num2str(param(7)));
        mdText = addMetadataField(mdText, 'False Northing', num2str(param(8)));

      case 'tm'
        mdText = addMetadataField(mdText, 'Semi-Major Axis', num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, 'Semi-Minor Axis', num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, 'Eccentricity squared', num2str(-param(2)));        
        end
        mdText = addMetadataField(mdText, 'Scale Factor', num2str(param(3)));
        mdText = addMetadataField(mdText, 'Central Meridian', num2str(param(4)));
        mdText = addMetadataField(mdText, 'Projection Origin Lat', num2str(param(5)));
        mdText = addMetadataField(mdText, 'False Easting', num2str(param(6)));
        mdText = addMetadataField(mdText, 'False Northing', num2str(param(7)));

    case 'lamaz'
        mdText = addMetadataField(mdText, 'Sphere Radius', num2str(param(1)));
        mdText = addMetadataField(mdText, 'Proj. Center Lon', num2str(param(5)));
        mdText = addMetadataField(mdText, 'Proj. Center Lat', num2str(param(6)));
        mdText = addMetadataField(mdText, 'False Easting', num2str(param(7)));
        mdText = addMetadataField(mdText, 'False Northing', num2str(param(8)));
   
    case 'hom'
        mdText = addMetadataField(mdText, 'Semi-Major Axis', num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, 'Semi-Minor Axis', num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, 'Eccentricity', num2str(-param(2)));        
        end
        mdText = addMetadataField(mdText, 'Scale Factor', num2str(param(3)));
        
        if param(13) == 1 % hom B        
            mdText = addMetadataField(...
                mdText, 'Azimuth angle east of north of center line', num2str(param(4)));
            mdText = addMetadataField(...
                mdText, 'Long of point on Central Meridian where azimuth occurs', num2str(param(5)));
        end
        mdText = addMetadataField(mdText, 'Projection Origin Lat', num2str(param(6)));
        mdText = addMetadataField(mdText, 'False Easting', num2str(param(7)));
        mdText = addMetadataField(mdText, 'False Northing', num2str(param(8)));

        if param(13) == 0 % hom A
            mdText = addMetadataField(...
                mdText, 'Long of 1st pt. on center line', num2str(param(9)));
            mdText = addMetadataField(...
                mdText, 'Lat of 1st pt. on center line', num2str(param(10)));
            mdText = addMetadataField(...
                mdText, 'Long of 2cd pt. on center line', num2str(param(11)));
            mdText = addMetadataField(...
                mdText, 'Lat of 2cd pt. on center line', num2str(param(12)));
        end
        
    case 'som'
        mdText = addMetadataField(mdText, 'Semi-Major Axis', num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, 'Semi-Minor Axis', num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, 'Eccentricity squared', num2str(-param(2)));        
        end
        
        if param(13) == 1 % som B
            mdText = addMetadataField(mdText, 'Satellite number', num2str(param(3)));        
            mdText = addMetadataField(mdText, 'Landsat path number', num2str(param(4)));        
        end
        if param(13) == 0 % som A
            mdText = addMetadataField(...
                mdText, 'Inclination of orbit at ascending node, counter-clockwise from equator', num2str(param(4)));
            mdText = addMetadataField(...
                mdText, 'Lon of ascending orbit at equator', num2str(param(5)));        
        end
        
        mdText = addMetadataField(mdText, 'False Easting', num2str(param(7)));
        mdText = addMetadataField(mdText, 'False Northing', num2str(param(8)));        
        
        if param(13) == 0 % som A
            mdText = addMetadataField(...
                mdText,...
                'Period of satellite in minutes',...
                num2str(param(9)));        
            mdText = addMetadataField(...
                mdText,...
                'Satellite radio to specify start & end pt. of x,y vals on earth surface',...
                num2str(param(10)));        
            
            if param(11) == 0
                mdText = addMetadataField(mdText, 'Path Start/End', 'Start');
            else
                mdText = addMetadataField(mdText, 'Path Start/End', 'End');
            end
        end
    
      case 'good'
        mdText = addMetadataField(mdText, 'Sphere Radius', num2str(param(1)));
        
      case 'isinus'
        mdText = addMetadataField(mdText, 'Sphere Radius', num2str(param(1)));
        mdText = addMetadataField(mdText, 'Central Meridian', num2str(param(5)));
        mdText = addMetadataField(mdText, 'False Easting', num2str(param(7)));
        mdText = addMetadataField(mdText, 'False Northing', num2str(param(8)));
        mdText = addMetadataField(mdText, 'Number of latitudinal zones', num2str(param(9)));
        mdText = addMetadataField(mdText, 'Right justify columns', num2str(param(11)));

     case {'bcea','cea'}
        mdText = addMetadataField(mdText, 'Semi-Major Axis', num2str(param(1)));  
        mdText = addMetadataField(mdText, 'Semi-Minor Axis', num2str(param(2)));        
        mdText = addMetadataField(mdText, 'Central Meridian', num2str(param(5)));
        mdText = addMetadataField(mdText, 'Latitude of true scale', num2str(param(6)));
        mdText = addMetadataField(mdText, 'False Easting', num2str(param(7)));
        mdText = addMetadataField(mdText, 'False Northing', num2str(param(8)));
        
    end
end

%======================================================================
function metadataText = addMetadataField(metadataText, name, value)
    metadataText = sprintf('%s<b>%s: </b>%s<br>',...
        metadataText, xlate(name), value);
end

