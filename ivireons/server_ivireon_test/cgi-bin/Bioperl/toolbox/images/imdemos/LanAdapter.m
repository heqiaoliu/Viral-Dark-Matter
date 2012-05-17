% LANADAPTER Example ImageAdapter for Erdas LAN images.
%   LANADAPTER is an example class that demonstrates how one can use the
%   ImageAdapter object-oriented interface to read and write to custom
%   image file formats.
%
%   The ImageAdapter class defines an interface that the Image Processing
%   Toolbox function BLOCKPROC can use to read and write data to files on
%   disk.  This is useful when trying to process images that are too large
%   to conveniently load into memory.  Classes such as this one allow users
%   to do a wide range of image processing operations on arbitrarily large
%   files using BLOCKPROC.
%
%   In this example we have written an ImageAdapter class that can read
%   Erdas LAN format files.  This class is for educational purposes ONLY.
%
%   To keep the class as simple as possible, we have limited the scope of
%   this class to read only LAN files containing uint8 data.  Additionally,
%   this class cannot be used to write new LAN files.
%
%   Constructor
%   -----------
%   ADAPTER = LANADAPTER(FILENAME) creates a LanAdapter object, ADAPTER,
%   associated with the Erdas LAN file, FILENAME.  The resulting adapter
%   can be used as an input data source to BLOCKPROC.
%
%   Properties
%   ----------
%   Since Erdas LAN files can contain many different bands of imagery, we
%   have opted to define an additional property:
%
%       SelectedBands
%
%   The SelectedBands property holds a vector of band numbers.  When
%   invoking the readRegion method, this property determines which bands of
%   data are returned and in what order they are returned.
%
%   Methods
%   -------
%   In order to create a custom ImageAdapter class, we must inherit from
%   the super-class ImageAdapter.  In doing so, we are required to
%   implement the following class methods for our file format:
%
%       readRegion(region_start,region_size)
%       close()
%
%   Examples
%   --------
%   In this example, we read the data from a LAN file using a LanAdapter 
%   object.  The 7-band file, paris.lan, stores the RGB visible imagery in
%   bands 3, 2, and 1.  We will set the SelectedBands property to specify
%   that our adapter return these bands only.  Next we will use BLOCKPROC
%   to read the data and write it back out as a truecolor TIFF file via the
%   'Destination' parameter.
%
%       paris_adapter = LanAdapter('paris.lan');
%       paris_adapter.SelectedBands = [3 2 1];
%       % the block function is a no-op, simply returning the data
%       copyFun = @(block_struct) block_struct.data;
%       blockproc(paris_adapter,[100 100],copyFun,'Destination','paris_rgb.tif');
%       imshow('paris_rgb.tif');
%
%   The data in this specturm is concentrated within a small part of the
%   available dynamic range.  This is one reason why the truecolor
%   composite appears dull.  We will now change the function handle
%   supplied to BLOCKPROC to do a contrast stretch instead of simply
%   returning the raw data.
%
%       stretchFun = @(block_struct) imadjust(block_struct.data,...
%           stretchlim(block_struct.data));
%       blockproc(paris_adapter,[100 100],stretchFun,'Destination','paris_rgb2.tif');
%       figure;
%       imshow('paris_rgb2.tif');
%
%   See also BLOCKPROC, IMAGEADAPTER.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/11/09 16:24:42 $
classdef LanAdapter < ImageAdapter
    
    properties(GetAccess = public, SetAccess = private)
        
        Filename
        NumBands
        
    end

    properties(Access = public)
        
        SelectedBands
        
    end

    
    methods
        
        function obj = LanAdapter(fname)
            % LanAdapter Constructor for LanAdapter class.
            % When creating a new LanAdapter object we will read the file
            % header to validate the file as well as save some image
            % properties for later use.
            
            % Open the file
            obj.Filename = fname;
            fid = fopen(fname,'r');
            
            % Verify that the file begins with the string 'HEADER' or
            % 'HEAD74', as per the Erdas LAN file specification.
            header_str = fread(fid,6,'uint8=>char');
            if ~(strcmp(header_str','HEADER') || strcmp(header_str','HEAD74'))
                error('Invalid LAN file header.');
            end
            
            % Read the data type from the header
            pack_type = fread(fid,1,'uint16',0,'ieee-le');
            if ~isequal(pack_type,0)
                error('Unsupported pack type.  The LanAdapter example only supports reading uint8 data.');
            end
            
            % Band information
            obj.NumBands = fread(fid,1,'uint16',0,'ieee-le');
            % By default, we will return all bands of data
            obj.SelectedBands = 1:obj.NumBands;
            
            % Image width and height
            unused_field = fread(fid,6,'uint8',0,'ieee-le'); %#ok<NASGU>
            width = fread(fid,1,'uint32',0,'ieee-le');
            height = fread(fid,1,'uint32',0,'ieee-le');
            obj.ImageSize = [height width];
            
            % Close the file handle
            fclose(fid);
            
        end % LanAdapter
        
        
        function data = readRegion(obj, region_start, region_size)
            % readRegion reads a rectangular block of data from the file.
            
            % Prepare various arguments to MULTIBANDREAD
            header_size = 128;
            rows = region_start(1):(region_start(1) + region_size(1) - 1);
            cols = region_start(2):(region_start(2) + region_size(2) - 1);
            
            % Call MULTIBANDREAD read to get the data
            full_size = [obj.ImageSize obj.NumBands];
            data = multibandread(obj.Filename, full_size,...
                'uint8=>uint8', header_size, 'bil', 'ieee-le',...
                {'Row',   'Direct', rows},...
                {'Column','Direct', cols},...
                {'Band',  'Direct', obj.SelectedBands});
            
        end % readRegion
        
        
        function close(obj) %#ok<MANU>
            % close the LanAdapter object.  This method is a part of the
            % ImageAdapter interface and is required.  Since our readRegion
            % method is "atomic", we have no open file handles to close,
            % so this method is empty.
            
        end
        
    end % public methods
    
end % LanAdapter
