%% Computing Statistics for Large Images
% The |blockproc| function is well suited for applying an operation to an
% image blockwise, assembling the results, and returning them as a new
% image.  Many image processing algorithms, however, require "global"
% information about the image, which is not available when you are only
% considering one block of image data at a time.  These constraints can
% prove to be problematic when working with images that are too large to
% load completely into memory. This demo explores how to use |blockproc| to
% compute statistics from large images and then apply that information to
% more accurately process the images blockwise.
%
% This demo performs a task similar to that found in the
% <matlab:showdemo('ipexlanstretch') Enhancing Multispectral Color
% Composite Images> demo, but adapted for large images using |blockproc|.
% You will be enhancing the visible bands of the Erdas LAN file |rio.lan|.
% These types of block processing techniques are typically more useful for
% large images, but a small image will work for the purpose of this demo.

% Copyright 2009 The MathWorks, Inc. 

%% Step 1: Construct a Truecolor Composite
% Using |blockproc|, read the data from |rio.lan|, a file containing
% Landsat thematic mapper imagery in the Erdas LAN file format.
% |blockproc| has built-in support for reading TIFF and JPEG2000 files
% only.  To read other types of files you must write an Image Adapter class
% to support I/O for your particular file format.  This example uses a
% pre-built Image Adapter class, the |LanAdapter|, which supports reading
% LAN files.  For more information on writing Image Adapter classes see
% <matlab:helpview(fullfile(docroot,'toolbox','images','images.map'),'building_image_adapters')
% the tutorial in the Users' Guide> describing how the |LanAdapter| class
% was built.
%
% The Erdas LAN format contains the visible red, green, and blue spectrum
% in bands 3, 2, and 1, respectively.  Use |blockproc| to extract the
% visible bands into an RGB image.

% Create the LanAdapter object associated with rio.lan.
input_adapter = LanAdapter('rio.lan');

% Select the visible R, G, and B bands.
input_adapter.SelectedBands = [3 2 1];

% Create a block function to simply return the block data unchanged.
identityFcn = @(block_struct) block_struct.data;

% Create the initial truecolor image.
truecolor = blockproc(input_adapter,[100 100],identityFcn);

% Display the un-enhanced results.
figure;
imshow(truecolor);
title('Truecolor Composite (Un-enhanced)');

%%
% The resulting truecolor image is similar to that of |paris.lan| in the
% <matlab:showdemo('ipexlanstretch') Enhancing Multispectral Color
% Composite Images> demo.  The RGB image appears dull, with little
% contrast. 


%% Step 2: Enhance the Image - First Attempt
% First, try to stretch the data across the dynamic range using
% |blockproc|.  This first attempt simply defines a new function handle
% that calls |stretchlim| and |imadjust| on each block of data
% individually.

adjustFcn = @(block_struct) imadjust(block_struct.data,...
    stretchlim(block_struct.data));
truecolor_enhanced = blockproc(input_adapter,[100 100],adjustFcn);
figure
imshow(truecolor_enhanced)
title('Truecolor Composite with Blockwise Contrast Stretch')


%%
% You can see immediately that the results are incorrect.  The problem is
% that the |stretchlim| function computes the histogram on the input image
% and uses this information to compute the stretch limits.  Since each
% block is adjusted in isolation from its neighbors, each block is
% computing different limits from its local histogram.


%% Step 3: Examine the Histogram Accumulator Class
% To examine the distribution of data across the dynamic range of the
% image, you can compute the histogram for each of the three visible bands.
%
% When working with sufficiently large images, you cannot simply call
% |imhist| to create an image histogram.  One way to incrementally build
% the histogram is to use |blockproc| with a class that will sum the
% histograms of each block as you move over the image.
%
% Examine the |HistogramAccumulator| class.

type HistogramAccumulator

%%
% The class is a simple wrapper around the |hist| function, allowing you to
% add data to a histogram incrementally.  It is not specific to
% |blockproc|.  Observe the following simple use of the
% |HistogramAccumulator| class.

% Create the HistogramAccumulator object.
hist_obj = HistogramAccumulator();

% Split a sample image into 2 halves.
full_image = imread('liftingbody.png');
top_half = full_image(1:256,:);
bottom_half = full_image(257:end,:);

% Compute the histogram incrementally.
hist_obj.addToHistogram(top_half);
hist_obj.addToHistogram(bottom_half);
computed_histogram = hist_obj.Histogram;

% Compare against the results of IMHIST.
normal_histogram = imhist(full_image);

% Examine the results.  The histograms are numerically identical.
figure
subplot(1,2,1);
stem(computed_histogram,'Marker','none');
title('Incrementally Computed Histogram');
subplot(1,2,2);
stem(normal_histogram','Marker','none');
title('IMHIST Histogram');


%% Step 4: Use the HistogramAccumulator Class with BLOCKPROC
% Now use the |HistogramAccumulator| class with |blockproc| to build the
% histogram of the red band of data in |rio.lan|.  You can define a
% function handle for |blockproc| that will invoke the |addToHistogram|
% method on each block of data.  By viewing this histogram, you can see
% that the data is concentrated within a small part of the available
% dynamic range.  The other visible bands have similar distributions.  This
% is one reason why the original truecolor composite appears dull.

% Create the HistogramAccumulator object.
hist_obj = HistogramAccumulator();

% Setup blockproc function handle
addToHistFcn = @(block_struct) hist_obj.addToHistogram(block_struct.data);

% Compute histogram of the red channel.  Notice that the addToHistFcn
% function handle does generate any output.  Since the function handle we
% are passing to blockproc does not return anything, blockproc will not
% return anything either.
input_adapter.SelectedBands = 3;
blockproc(input_adapter,[100 100],addToHistFcn);
red_hist = hist_obj.Histogram;

% Display results.
figure
stem(red_hist,'Marker','none');
title('Histogram of Red Band (Band 3)');


%% Step 5: Enhance the Truecolor Composite with a Contrast Stretch
% You can now perform a proper contrast stretch on the image.  For
% conventional, in-memory workflows, you can simply use the |stretchlim|
% function to compute the arguments to |imadjust| (like the
% |ipexlanstretch| demo does).  When working with large images, as we have
% seen, |stretchlim| is not easily adapted for use with |blockproc| since
% it relies on the full image histogram.
%
% Once you have computed the image histograms for each of the visible
% bands, compute the proper arguments to |imadjust| by hand (similar to how
% |stretchlim| does).

%%
% First compute the histograms for the green and blue bands.

% Compute histogram for green channel.
hist_obj = HistogramAccumulator();
addToHistFcn = @(block_struct) hist_obj.addToHistogram(block_struct.data);
input_adapter.SelectedBands = 2;
blockproc(input_adapter,[100 100],addToHistFcn);
green_hist = hist_obj.Histogram;

% Compute histogram for blue channel.
hist_obj = HistogramAccumulator();
addToHistFcn = @(block_struct) hist_obj.addToHistogram(block_struct.data);
input_adapter.SelectedBands = 1;
blockproc(input_adapter,[100 100],addToHistFcn);
blue_hist = hist_obj.Histogram;

%%
% Now compute the CDF of each histogram and prepare to call |imadjust|.

computeCDF = @(histogram) cumsum(histogram) / sum(histogram);
findLowerLimit = @(cdf) find(cdf > 0.01, 1, 'first');
findUpperLimit = @(cdf) find(cdf >= 0.99, 1, 'first');

red_cdf = computeCDF(red_hist);
red_limits(1) = findLowerLimit(red_cdf);
red_limits(2) = findUpperLimit(red_cdf);

green_cdf = computeCDF(green_hist);
green_limits(1) = findLowerLimit(green_cdf);
green_limits(2) = findUpperLimit(green_cdf);

blue_cdf = computeCDF(blue_hist);
blue_limits(1) = findLowerLimit(blue_cdf);
blue_limits(2) = findUpperLimit(blue_cdf);

% Prepare argument for IMADJUST.
rgb_limits = [red_limits' green_limits' blue_limits'];

% Scale to [0,1] range.
rgb_limits = (rgb_limits - 1) / (255);

%%
% Create a new |adjustFcn| that applies the global stretch limits and use
% |blockproc| to adjust the truecolor image.

adjustFcn = @(block_struct) imadjust(block_struct.data,rgb_limits);

% Select full RGB data.
input_adapter.SelectedBands = [3 2 1];
truecolor_enhanced = blockproc(input_adapter,[100 100],adjustFcn);
figure;
imshow(truecolor_enhanced)
title('Truecolor Composite with Corrected Contrast Stretch')

%% 
% The resulting image is much improved, with the data covering more of the
% dynamic range, and by using |blockproc| you avoid loading the whole image
% into memory.

displayEndOfDemoMessage(mfilename)
