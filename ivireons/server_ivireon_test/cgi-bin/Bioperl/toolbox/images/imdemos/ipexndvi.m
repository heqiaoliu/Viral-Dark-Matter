%% Finding Vegetation in a Multispectral Image
% Variations in the reflectivity of surface materials across different
% spectral bands provide a fundamental mechanism for understanding features
% in remotely-sensed multispectral imagery.
%
% This example shows how differences between the visible red and
% near-infrared (NIR) bands of a LANDSAT image can be used to identify
% areas containing significant vegetation.  It uses a LANDSAT Thematic
% Mapper image covering part of Paris, France, made available courtesy of
% Space Imaging, LLC.  Seven spectral bands are stored in one file in the
% Erdas LAN format.

% Copyright 2004-2008 The MathWorks, Inc. 


%% Step 1: Import CIR Bands from a BIL Image File
% The LAN file, |paris.lan|, contains a 7-band 512-by-512 Landsat image. A
% 128-byte header is followed by the pixel values, which are band
% interleaved by line (BIL) in order of increasing band number.  They are
% stored as unsigned 8-bit integers, in little-endian byte order.
%
% The first step is to read bands 4, 3, and 2 from the LAN file using the
% MATLAB(R) function |multibandread|.
%
% Thematic Mapper 4, 3, and 2 bands cover the near infrared (NIR), the
% visible red, and the visible green parts of the electromagnetic spectrum.
% When they are mapped to the red, green, and blue planes, respectively, of
% an RGB image the result is a standard color-infrared (CIR) composite.
% The final input argument to |multibandread| specifies which bands to
% read, and in which order, so that you can construct a composite in a
% single step.
CIR = multibandread('paris.lan', [512, 512, 7], 'uint8=>uint8',...
                    128, 'bil', 'ieee-le', {'Band','Direct',[4 3 2]});

%%
% Variable |CIR| is a 512-by-512-by-3 array of class |uint8|.  It is an RGB
% image, but with false colors.  When the image is displayed, red signifies
% the NIR band, green signifies the visible red band, and blue signifies
% the visible green band. In the CIR image, water features are very dark
% (the Seine River) and green vegetation appears red (parks and shade
% trees).  Overall, the contrast is low and the colors are subtle.
figure
imshow(CIR)
title('CIR Composite (Un-enhanced)')
text(size(CIR,2), size(CIR,1) + 15,...
  'Image courtesy of Space Imaging, LLC',...
  'FontSize', 7, 'HorizontalAlignment', 'right')

%% Step 2: Enhance the CIR Composite with a Decorrelation Stretch
% It's helpful, before analyzing the CIR composite, to enhance it for more
% effective visual display.  Because of the subtle color differences in the
% original composite, a decorrelation stretch is suitable.  You can use the
% function |decorrstretch|, which enhances color separation across
% correlated channels, and also specify an optional linear contrast stretch
% to saturate the brightest and darkest one percent of the pixels in each
% band.
decorrCIR = decorrstretch(CIR, 'Tol', 0.01);
figure
imshow(decorrCIR)
title('CIR Composite with Decorrelation Stretch')

%%
% The surface features have become much more obvious and the image is more
% colorful. This is because the spectral differences across the scene have
% been exaggerated and the contrast has been increased.
%
% Much of the image appearance is due to the fact that healthy,
% chlorophyll-rich vegetation has a high reflectance in the near infrared.
% Because the NIR band is mapped to the red channel in our composite, any
% area with  a high vegetation density appears red in the display. A
% noticeable example is the area of bright red on the left edge, a large
% park (the Bois de Boulogne) located west of central Paris within a bend
% of the Seine River.
%
% By analyzing differences between the NIR and red bands, you can quantify
% this contrast in spectral content between vegetated areas and other
% surfaces such as pavement, bare soil, buildings, or water.

%% Step 3: Construct an NIR-Red Spectral Scatter Plot
% A scatter plot is a natural place to start when comparing the NIR band
% (displayed as red) with the visible red band (displayed as green). It's
% convenient to extract these bands from the original CIR composite into
% individual variables.  (We return to the original bands, because the
% decorrelation-stretched image is appropriate for visual display but not
% for spectral analysis.)  It's also helpful to convert from class |uint8|
% to class |single| so that the same variables can be used in the NDVI
% computation below, as well as in the scatter plot.
NIR = im2single(CIR(:,:,1));
red = im2single(CIR(:,:,2));

%%
% Viewing the two bands together as grayscale images, you can see how
% different they look.

figure
imshow(red)
title('Visible Red Band')
figure
imshow(NIR)
title('Near Infrared Band')

%%
% With one simple call to the |plot| command in MATLAB, you can create a
% scatter plot displaying one point per pixel (as a blue cross, in this
% case), with its X-coordinate determined by its value in the red band and
% its Y-coordinate by the value its value in the NIR band.
figure
plot(red, NIR, '+b')
set(gca, 'XLim', [0 1], 'XTick', 0:0.2:1,...
         'YLim', [0 1], 'YTick', 0:0.2:1);
axis square
xlabel('red level')
ylabel('NIR level')
title('NIR vs. Red Scatter Plot')

%%
% The appearance of the scatter plot of the Paris scene is characteristic
% of a temperate urban area with trees in summer foliage. There's a set of
% pixels near the diagonal for which the NIR and red values are nearly
% equal.  This "gray edge" includes features such as road surfaces and many
% rooftops.  Above and to the left is another set of pixels for which the
% NIR value is often well above the red value.  This zone encompasses
% essentially all of the green vegetation.

%% Step 4: Compute Vegetation Index via MATLAB(R) Array Arithmetic
% Observe from the scatter plot that taking the ratio of the NIR level to
% red level would be one way to locate pixels containing dense vegetation.
% However, the result would be noisy for dark pixels with small values in
% both bands. Also notice that the difference between the NIR and red
% should be larger for greater chlorophyll density. The Normalized
% Difference Vegetation Index (NDVI) is motivated by this second
% observation.  It takes the (NIR - red) difference and normalizes it to
% help balance out the effects of uneven illumination such as the shadows
% of clouds or hills.  In other words, on a pixel-by-pixel basis subtract
% the value of the red band from the value of the NIR band and divide by
% their sum.
ndvi = (NIR - red) ./ (NIR + red);

%%
% Notice how the array-arithmetic operators in MATLAB make it possible to
% compute an entire NDVI image in one simple command.  Recall that
% variables |red| and |NIR| have class |single|.  This choice uses less
% storage than class |double| but unlike an integer class also allows the
% resulting ratio to assume a smooth gradation of values.

%%
% Variable |ndvi| is a 2-D array of class |single| with a theoretical
% maximum range of [-1 1].  You can specify these theoretical limits when
% displaying |ndvi| as a grayscale image.
figure
imshow(ndvi,'DisplayRange',[-1 1])
title('Normalized Difference Vegetation Index')

%%
% The Seine River appears very dark in the NDVI image.  The large light
% area near the left edge of the image is the park (Bois de Boulogne) noted
% earlier.

%% Step 5: Locate Vegetation -- Threshold the NDVI Image
% In order to identify pixels most likely to contain significant
% vegetation, you can apply a simple threshold to the NDVI image.
threshold = 0.4;
q = (ndvi > threshold);

%%
% The percentage of pixels selected is thus
100 * numel(NIR(q(:))) / numel(NIR)

%%
% or about 5 percent.
%
% The park and other smaller areas of vegetation appear white by
% default when displaying the logical (binary) image |q|.
figure
imshow(q)
title('NDVI with Threshold Applied')

%% Step 6: Link Spectral and Spatial Content
% To link the spectral and spatial content, you can locate above-threshold
% pixels on the NIR-red scatter plot, re-drawing the scatter plot with the
% above-threshold pixels in a contrasting color (green) and then
% re-displaying the threshold NDVI image using the same blue-green color
% scheme.  As expected, the pixels having an NDVI value above the threshold
% appear to the upper left of the rest and correspond to the redder pixels
% in the CIR composite displays.

% Create a figure with a 1-by-2 aspect ratio
h = figure;
p = get(h,'Position');
set(h,'Position',[p(1,1:3),p(3)/2])
subplot(1,2,1)
% Create the scatter plot
plot(red, NIR, '+b')
hold on
plot(red(q(:)), NIR(q(:)), 'g+')
set(gca, 'XLim', [0 1], 'YLim', [0 1])
axis square
xlabel('red level')
ylabel('NIR level')
title('NIR vs. Red Scatter Plot')
% Display the thresholded NDVI
subplot(1,2,2)
imshow(q)
set(h,'Colormap',[0 0 1; 0 1 0])
title('NDVI with Threshold Applied')

%%
% See also |decorrstretch|, |im2single|, |ipexlanstretch|, |multibandread|.


displayEndOfDemoMessage(mfilename)
