% Image Processing Toolbox
% Version 7.1 (R2010b) 03-Aug-2010
%
% Image display and exploration.
%   colorbar       - Display colorbar (MATLAB Toolbox).
%   image          - Create and display image object (MATLAB Toolbox).
%   imagesc        - Scale data and display as image (MATLAB Toolbox).
%   immovie        - Make movie from multiframe image.
%   implay         - Play movies, videos, or image sequences.
%   imshow         - Display image in Handle Graphics figure.
%   imtool         - Display image in the Image Tool.
%   montage        - Display multiple image frames as rectangular montage.
%   movie          - Play recorded movie frames (MATLAB Toolbox).
%   subimage       - Display multiple images in single figure.
%   warp           - Display image as texture-mapped surface.
%
% Image file I/O.
%   analyze75info       - Read metadata from header file of Mayo Analyze 7.5 data set.
%   analyze75read       - Read image file of Mayo Analyze 7.5 data set.
%   dicomanon           - Anonymize DICOM file.
%   dicomdict           - Get or set active DICOM data dictionary.
%   dicominfo           - Read metadata from DICOM message.
%   dicomlookup         - Find attribute in DICOM data dictionary.
%   dicomread           - Read DICOM image.
%   dicomuid            - Generate DICOM Unique Identifier.
%   dicomwrite          - Write images as DICOM files.
%   dicom-dict.txt      - Text file containing DICOM data dictionary (2007).
%   dicom-dict-2005.txt - Text file containing DICOM data dictionary (2005).
%   hdrread             - Read Radiance HDR image.
%   hdrwrite            - Write Radiance HDR image.
%   makehdr             - Create high dynamic range image.
%   ImageAdapter        - Interface for image format I/O.
%   imfinfo             - Information about image file (MATLAB Toolbox).
%   imread              - Read image file (MATLAB Toolbox).
%   imwrite             - Write image file (MATLAB Toolbox).
%   interfileinfo       - Read metadata from Interfile files.
%   interfileread       - Read images from Interfile files.
%   isnitf              - Check if file is NITF.
%   isrset              - Check if file is reduced-resolution dataset (R-Set).
%   nitfinfo            - Read metadata from NITF file.
%   nitfread            - Read NITF image.
%   rsetwrite           - Create reduced-resolution dataset (R-Set) from image file.
%
% Image arithmetic.
%   imabsdiff      - Absolute difference of two images.
%   imadd          - Add two images or add constant to image.
%   imcomplement   - Complement image.
%   imdivide       - Divide two images or divide image by constant.
%   imlincomb      - Linear combination of images.
%   immultiply     - Multiply two images or multiply image by constant.
%   imsubtract     - Subtract two images or subtract constant from image.
%   ippl           - Check for presence of Intel Performance Primitives Library (IPPL).
%
% Spatial transformations.
%   checkerboard   - Create checkerboard image.
%   findbounds     - Find output bounds for spatial transformation.
%   fliptform      - Flip input and output roles of TFORM structure.
%   imcrop         - Crop image.
%   impyramid      - Image pyramid reduction and expansion.
%   imresize       - Resize image.
%   imrotate       - Rotate image.
%   imtransform    - Apply 2-D spatial transformation to image.
%   makeresampler  - Create resampling structure.
%   maketform      - Create spatial transformation structure (TFORM).
%   tformarray     - Apply spatial transformation to N-D array.
%   tformfwd       - Apply forward spatial transformation.
%   tforminv       - Apply inverse spatial transformation.
%
% Image registration.
%   cpstruct2pairs - Convert CPSTRUCT to control point pairs.
%   cp2tform       - Infer spatial transformation from control point pairs.
%   cpcorr         - Tune control point locations using cross-correlation. 
%   cpselect       - Control Point Selection Tool. 
%   normxcorr2     - Normalized two-dimensional cross-correlation.
%
% Pixel values and statistics.
%   corr2          - 2-D correlation coefficient.
%   imcontour      - Create contour plot of image data.
%   imhist         - Display histogram of image data.
%   impixel        - Pixel color values.
%   improfile      - Pixel-value cross-sections along line segments.
%   mean2          - Average or mean of matrix elements.
%   regionprops    - Measure properties of image regions.
%   std2           - Standard deviation of matrix elements.
%
% Image analysis.
%   bwboundaries    - Trace region boundaries in binary image.
%   bwtraceboundary - Trace object in binary image.
%   corner          - Find corners in intensity image.
%   cornermetric    - Create corner metric matrix from image.
%   edge            - Find edges in intensity image.
%   hough           - Hough transform.
%   houghlines      - Extract line segments based on Hough transform.
%   houghpeaks      - Identify peaks in Hough transform.
%   qtdecomp        - Quadtree decomposition.
%   qtgetblk        - Get block values in quadtree decomposition.
%   qtsetblk        - Set block values in quadtree decomposition.
%
% Image enhancement.
%   adapthisteq    - Contrast-limited Adaptive Histogram Equalization (CLAHE).
%   decorrstretch  - Apply decorrelation stretch to multichannel image.
%   histeq         - Enhance contrast using histogram equalization.
%   imadjust       - Adjust image intensity values or colormap.
%   imnoise        - Add noise to image.
%   medfilt2       - 2-D median filtering.
%   ordfilt2       - 2-D order-statistic filtering.
%   stretchlim     - Find limits to contrast stretch an image.
%   intlut         - Convert integer values using lookup table.
%   wiener2        - 2-D adaptive noise-removal filtering.
%
% Linear filtering.
%   convmtx2       - 2-D convolution matrix.
%   fspecial       - Create predefined 2-D filters.
%   imfilter       - N-D filtering of multidimensional images.
%
% Linear 2-D filter design.
%   freqspace      - Determine 2-D frequency response spacing (MATLAB Toolbox).
%   freqz2         - 2-D frequency response.
%   fsamp2         - 2-D FIR filter using frequency sampling.
%   ftrans2        - 2-D FIR filter using frequency transformation.
%   fwind1         - 2-D FIR filter using 1-D window method.
%   fwind2         - 2-D FIR filter using 2-D window method.
%
% Image deblurring.
%   deconvblind    - Deblur image using blind deconvolution.
%   deconvlucy     - Deblur image using Lucy-Richardson method.
%   deconvreg      - Deblur image using regularized filter.
%   deconvwnr      - Deblur image using Wiener filter.
%   edgetaper      - Taper edges using point-spread function.
%   otf2psf        - Convert optical transfer function to point-spread function.
%   psf2otf        - Convert point-spread function to optical transfer function.
%
% Image transforms.
%   dct2           - 2-D discrete cosine transform.
%   dctmtx         - Discrete cosine transform matrix.
%   fan2para       - Convert fan-beam projections to parallel-beam.
%   fanbeam        - Fan-beam transform.
%   fft2           - 2-D fast Fourier transform (MATLAB Toolbox).
%   fftn           - N-D fast Fourier transform (MATLAB Toolbox).
%   fftshift       - Reverse quadrants of output of FFT (MATLAB Toolbox).
%   idct2          - 2-D inverse discrete cosine transform.
%   ifft2          - 2-D inverse fast Fourier transform (MATLAB Toolbox).
%   ifftn          - N-D inverse fast Fourier transform (MATLAB Toolbox).
%   ifanbeam       - Inverse fan-beam transform.
%   iradon         - Inverse Radon transform.
%   para2fan       - Convert parallel-beam projections to fan-beam.
%   phantom        - Create head phantom image.
%   radon          - Radon transform.
%
% Neighborhood and block processing.
%   bestblk        - Optimal block size for block processing.
%   blockproc      - Distinct block processing for image.
%   col2im         - Rearrange matrix columns into blocks.
%   colfilt        - Columnwise neighborhood operations.
%   im2col         - Rearrange image blocks into columns.
%   nlfilter       - General sliding-neighborhood operations.
%
% Morphological operations (intensity and binary images).
%   conndef        - Default connectivity array.
%   imbothat       - Bottom-hat filtering.
%   imclearborder  - Suppress light structures connected to image border.
%   imclose        - Morphologically close image.
%   imdilate       - Dilate image.
%   imerode        - Erode image.
%   imextendedmax  - Extended-maxima transform.
%   imextendedmin  - Extended-minima transform.
%   imfill         - Fill image regions and holes.
%   imhmax         - H-maxima transform.
%   imhmin         - H-minima transform.
%   imimposemin    - Impose minima.
%   imopen         - Morphologically open image.
%   imreconstruct  - Morphological reconstruction.
%   imregionalmax  - Regional maxima.
%   imregionalmin  - Regional minima.
%   imtophat       - Top-hat filtering.
%   watershed      - Watershed transform.
%
% Morphological operations (binary images).
%   applylut       - Neighborhood operations using lookup tables.
%   bwarea         - Area of objects in binary image.
%   bwareaopen     - Morphologically open binary image (remove small objects).
%   bwconncomp     - Find connected components in binary image.
%   bwdist         - Distance transform of binary image.
%   bweuler        - Euler number of binary image.
%   bwhitmiss      - Binary hit-miss operation.
%   bwlabel        - Label connected components in 2-D binary image.
%   bwlabeln       - Label connected components in binary image.
%   bwmorph        - Morphological operations on binary image.
%   bwpack         - Pack binary image.
%   bwperim        - Find perimeter of objects in binary image.
%   bwselect       - Select objects in binary image.
%   bwulterode     - Ultimate erosion.
%   bwunpack       - Unpack binary image.
%   labelmatrix    - Create label matrix from BWCONNCOMP structure.
%   makelut        - Create lookup table for use with APPLYLUT.
%
% Structuring element (STREL) creation and manipulation.
%   getheight      - Get STREL height.
%   getneighbors   - Get offset location and height of STREL neighbors
%   getnhood       - Get STREL neighborhood.
%   getsequence    - Get sequence of decomposed STRELs.
%   isflat         - True for flat STRELs.
%   reflect        - Reflect STREL about its center.
%   strel          - Create morphological structuring element (STREL).
%   translate      - Translate STREL.
%
% Texture analysis.
%   entropy        - Entropy of intensity image.    
%   entropyfilt    - Local entropy of intensity image.
%   graycomatrix   - Create gray-level co-occurrence matrix.
%   graycoprops    - Properties of gray-level co-occurrence matrix.  
%   rangefilt      - Local range of image.  
%   stdfilt        - Local standard deviation of image.
%
% Region-based processing.
%   poly2mask      - Convert region-of-interest polygon to mask.
%   roicolor       - Select region of interest based on color.
%   roifill        - Fill in specified polygon in grayscale image.
%   roifilt2       - Filter region of interest.
%   roipoly        - Select polygonal region of interest.
%
% Colormap manipulation.
%   brighten       - Brighten or darken colormap (MATLAB Toolbox).
%   cmpermute      - Rearrange colors in colormap (MATLAB Toolbox).
%   cmunique       - Eliminate unneeded colors in colormap of indexed image (MATLAB toolbox).
%   colormap       - Set or get color lookup table (MATLAB Toolbox).
%   imapprox       - Approximate indexed image by one with fewer colors (MATLAB toolbox).
%   rgbplot        - Plot RGB colormap components (MATLAB Toolbox).
%
% Color space conversions.
%   applycform     - Apply device-independent color space transformation.
%   hsv2rgb        - Convert HSV color values to RGB color space (MATLAB Toolbox).
%   iccfind        - Search for ICC profiles by description.
%   iccread        - Read ICC color profile.
%   iccroot        - Find system ICC profile repository.
%   iccwrite       - Write ICC color profile.
%   isicc          - True for complete profile structure
%   lab2double     - Convert L*a*b* color values to double.
%   lab2uint16     - Convert L*a*b* color values to uint16.
%   lab2uint8      - Convert L*a*b* color values to uint8.
%   makecform      - Create device-independent color space transformation structure (CFORM).
%   ntsc2rgb       - Convert NTSC color values to RGB color space.
%   rgb2hsv        - Convert RGB color values to HSV color space (MATLAB Toolbox).
%   rgb2ntsc       - Convert RGB color values to NTSC color space.
%   rgb2ycbcr      - Convert RGB color values to YCbCr color space.
%   whitepoint     - XYZ color values of standard illuminants.
%   xyz2double     - Convert XYZ color values to double.
%   xyz2uint16     - Convert XYZ color values to uint16.
%   ycbcr2rgb      - Convert YCbCr color values to RGB color space.
%
% ICC color profiles.
%   lab8.icm       - 8-bit Lab profile.
%   monitor.icm    - Typical monitor profile.
%                    Sequel Imaging, Inc., used with permission.
%   sRGB.icm       - sRGB profile.
%                    Hewlett-Packard, used with permission.
%   swopcmyk.icm   - CMYK input profile.
%                    Eastman Kodak, used with permission.
%
% Array operations.
%   circshift      - Shift array circularly (MATLAB Toolbox).
%   padarray       - Pad array.
%
% Image types and type conversions.
%   demosaic       - Convert Bayer pattern encoded image to a truecolor image.
%   dither         - Convert image using dithering (MATLAB toolbox).
%   gray2ind       - Convert intensity image to indexed image.
%   grayslice      - Create indexed image from intensity image by thresholding.
%   graythresh     - Global image threshold using Otsu's method.
%   im2bw          - Convert image to binary image by thresholding.
%   im2double      - Convert image to double precision.  
%   im2int16       - Convert image to 16-bit signed integers.    
%   im2java        - Convert image to Java image (MATLAB Toolbox).
%   im2java2d      - Convert image to Java BufferedImage.
%   im2single      - Convert image to single precision.     
%   im2uint8       - Convert image to 8-bit unsigned integers.
%   im2uint16      - Convert image to 16-bit unsigned integers.  
%   ind2gray       - Convert indexed image to intensity image.
%   ind2rgb        - Convert indexed image to RGB image (MATLAB Toolbox).
%   label2rgb      - Convert label matrix to RGB image.
%   mat2gray       - Convert matrix to intensity image.
%   rgb2gray       - Convert RGB image or colormap to grayscale.
%   rgb2ind        - Convert RGB image to indexed image (MATLAB Toolbox).
%   tonemap        - Render high dynamic range image for viewing.
%
% Toolbox preferences.
%   iptgetpref     - Get value of Image Processing Toolbox preference.
%   iptprefs       - Display Image Processing Toolbox preferences dialog.
%   iptsetpref     - Set value of Image Processing Toolbox preference.
%
% Toolbox utility functions.
%   getrangefromclass - Get dynamic range of image based on its class.
%   iptcheckconn      - Check validity of connectivity argument.
%   iptcheckinput     - Check validity of array.
%   iptcheckmap       - Check validity of colormap.
%   iptchecknargin    - Check number of input arguments.
%   iptcheckstrs      - Check validity of text string.
%   iptnum2ordinal    - Convert positive integer to ordinal string.
%
% Modular interactive tools.
%   imageinfo           - Image Information tool.
%   imcolormaptool      - Choose Colormap tool.
%   imcontrast          - Adjust Contrast tool.
%   imdisplayrange      - Display Range tool.
%   imdistline          - Draggable Distance tool.
%   imgetfile           - Open Image dialog box.
%   impixelinfo         - Pixel Information tool.
%   impixelinfoval      - Pixel Information tool without text label.
%   impixelregion       - Pixel Region tool.
%   impixelregionpanel  - Pixel Region tool panel.
%   imputfile           - Save Image dialog box.
%   imsave              - Save Image tool.
%
% Navigational tools for image scroll panel.
%   imscrollpanel       - Scroll panel for interactive image navigation.
%   immagbox            - Magnification box for scroll panel.
%   imoverview          - Overview tool for image displayed in scroll panel.
%   imoverviewpanel     - Overview tool panel for image displayed in scroll panel.
%
% Utility functions for interactive tools.
%   axes2pix                  - Convert axes coordinate to pixel coordinate.  
%   getimage                  - Get image data from axes.
%   getimagemodel             - Get image model object from image object.
%   imagemodel                - Image model object.
%   imattributes              - Information about image attributes.
%   imhandles                 - Get all image handles.  
%   imgca                     - Get handle to current axes containing image.
%   imgcf                     - Get handle to current figure containing image.
%   imellipse                 - Create draggable, resizable ellipse.
%   imfreehand                - Create draggable freehand region.
%   imline                    - Create draggable, resizable line.
%   impoint                   - Create draggable point.
%   impoly                    - Create draggable, resizable polygon.
%   imrect                    - Create draggable, resizable rectangle.
%   iptaddcallback            - Add function handle to callback list.
%   iptcheckhandle            - Check validity of handle.
%   iptgetapi                 - Get Application Programmer Interface (API) for handle.
%   iptGetPointerBehavior     - Retrieve pointer behavior from HG object.
%   ipticondir                - Directories containing IPT and MATLAB icons.
%   iptPointerManager         - Install mouse pointer manager in figure.
%   iptremovecallback         - Delete function handle from callback list.
%   iptSetPointerBehavior     - Store pointer behavior in HG object.
%   iptwindowalign            - Align figure windows.
%   makeConstrainToRectFcn    - Create rectangularly bounded position constraint function.
%   truesize                  - Adjust display size of image.
%
% Interactive mouse utility functions.
%   getline        - Select polyline with mouse.
%   getpts         - Select points with mouse.
%   getrect        - Select rectangle with mouse.
%
% Demos.
%   iptdemos       - Index of Image Processing Toolbox demos.
%
% See also COLORSPACES, IMAGESLIB, IMDEMOS, IMUITOOLS, IPTFORMATS, IPTUTILS.

% Undocumented functions.
%   cmgamdef       - Default gamma correction table.
%   cmgamma        - Gamma correct colormap.
%   iptgate        - Gateway routine to call private functions.
%   imuitoolsgate  - Gateway routine to call private functions.
%   isdicom        - Check if a file uses DICOM.

% Undocumented classes.
%   iptui.cpselectPoint   - Subclass of impoint used by cpselect.
%   iptui.imcropRect      - Subclass of imrect used by imcrop.
%   iptui.impolyVertex    - Subclass of impoint used by impoly.
%   iptui.pixelRegionRect - Subclass of imrect used by impixelregion. 

% Grandfathered/obsolete functions.
%   blkproc        - Distinct block processing for image.
%   bwfill         - Fill background regions in binary image.
%   dctmtx2        - Discrete cosine transform matrix.
%   dilate         - Perform dilation on binary image.
%   erode          - Perform erosion on binary image.
%   imfeature      - Compute feature measurements for image regions.
%   imslice        - Get/put image slices into an image deck.
%   imzoom         - Zoom in and out of image or 2-D plot.
%   im2mis         - Convert image to Java MemoryImageSource.
%   mfilter2       - 2-D region-of-interest filtering.
%   isbw           - Return true for binary image.
%   isgray         - Return true for intensity image.
%   isind          - Return true for indexed image.
%   isrgb          - Return true for RGB image.
%   impositionrect - Create draggable position rectangle.
%   pixval         - Display information about image pixels.
%   watershed_old  - Watershed transform (old version).

%   Copyright 1993-2010 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.1.10.26  $Date: 2010/04/15 15:18:03 $
