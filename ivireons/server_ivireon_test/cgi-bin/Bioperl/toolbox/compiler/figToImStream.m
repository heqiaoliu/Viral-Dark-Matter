function bytes = figToImStream(varargin)   
%     figToImStream Streams out a snapshot of a figure represented by 
%       a byte array encoded in the format specified. 
%
%     figToImStream
%       figToImStream alone creates a signed byte array with the png data 
%       for the current figure.  The size and position of the printed 
%       output depends on the figure's PaperPosition[mode] properties.
%
%     figToImStream('figHandle', <Figure Handle>, ...)
%       You can optionally specific the figure output to be used.
%       The Default is the current image
%
%     figToImStream('imageFormat', <imageFormat>, ...)
%       You can optionally specify an image format to convert to.
%       The valid types are:
%           png
%           jpg
%           bmp
%           gif
%       The Default is png
%
%     figToImStream('outputType', <outputType>)
%       You can optionally specify an output data type for the bytes.
%       The valid types are:
%           int8    (signed byte)   Used for the java primitive Byte
%           uint8   (unsigned byte) Used for the .NET primitive Byte
%       The default is int8
%
%      figToImStream( ... )
%        Same as above only this is a comma separated parenthesized 
%        argument list. It allows the passing of variables for any or all 
%        of the input arguments.
%
%   Examples:
%   
%   Convert the current figure to a signed png byte array:
%       surf(peaks)
%       bytes = figToImStream
%   
%   Convert a specific figure to an unsigned bmp byte array:
%       f = figure;
%       surf(peaks);
%       bytes = figToImStream(  'figHandle', f, ...
%                               'imageFormat', 'bmp', ...
%                               'outputType', 'uint8');
%

% Copyright 2007 The MathWorks, Inc.

    p = inputParser;
       
    %If no figure is passed in use the current figure 
    %validator (check for HGhandle and figure)
    p.addOptional('figHandle', get(0,'CurrentFigure'), @(x)ishghandle(x) && strcmp(get(x,'type'),'figure'));
    
    %If no image format is passed in use PNG 
    %Validator (check for string and one of the valid inputs)
    p.addOptional('imageFormat', 'png',   @(x)ischar(x)&&any(strcmpi(x,{'png','gif','bmp','jpg'})));

    %If no outputType is specified use int8 
    %Validator (check for string and one of the valid inputs)
    p.addOptional('outputType', 'int8', @(x)ischar(x)&&any(strcmpi(x,{'int8', 'uint8'})));
    p.parse(varargin{:});
    
    %Check that a figure exists 
    %(if you clear all variables there is no GCF)
    if(isempty(p.Results.figHandle))
        error('MATLAB:Toolbox:Compiler:figToImStream:InvalidFigureHandle','Invalid figure');
    end
    
    %Get the MATLAB pixel representation of the figure
    pixels = hardcopyOutput(p.Results.figHandle);

    %Required java classes to convert image.
	import java.awt.image.BufferedImage;
	import java.awt.image.DataBufferInt;
	import java.awt.image.DataBuffer;
	import java.awt.image.ComponentSampleModel;
	import java.awt.image.Raster;
	import java.io.ByteArrayOutputStream;
	import javax.imageio.ImageIO;

    %This creates a model that depicts how
    %  our pixel information is stored
	[rows,cols,planes] = size(pixels);
	dataBuffer = DataBufferInt(pixels(:), rows*cols*planes);
	sampleModel = ComponentSampleModel( DataBuffer.TYPE_INT, ...
                                        cols, ...
                                        rows, ...
                                        rows, ...
                                        1,...
                        				[0,rows*cols,2*rows*cols]);
                                    
    %We then use a Raster to map the array data into 
    %  a java raster using the infromation in the model
	raster = Raster.createRaster(sampleModel,dataBuffer,[]);

    %Create a buffered image that is the size of our image
	buffImage = BufferedImage(cols,rows,BufferedImage.TYPE_INT_RGB);
    %Fill it with the data from the raster
    buffImage.setData(raster);

	stream = ByteArrayOutputStream;
    %Convert the buffered Image to a stream
	ImageIO.write(buffImage, p.Results.imageFormat, stream);

    %Return the stream as a byte array
    bytes = typecast(stream.toByteArray, p.Results.outputType);
end
