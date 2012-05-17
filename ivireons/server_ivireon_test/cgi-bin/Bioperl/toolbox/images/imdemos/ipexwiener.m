%% Deblurring Images Using a Wiener Filter
% Wiener deconvolution can be useful when the point-spread function and
% noise level are known or can be estimated.

% Copyright 1993-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2008/10/26 14:24:42 $

%% Read Image

I = im2double(imread('cameraman.tif'));
imshow(I);
title('Original Image (courtesy of MIT)');

%% Simulate a Motion Blur
% Simulate a blurred image that you might get from camera motion.  Create a
% point-spread function, |PSF|, corresponding to the linear motion across
% 31 pixels (|LEN=31|), at an angle of 11 degrees (|THETA=11|). To simulate
% the blur, convolve the filter with the image using |imfilter|. 

LEN = 21;
THETA = 11;
PSF = fspecial('motion', LEN, THETA);
blurred = imfilter(I, PSF, 'conv', 'circular');
imshow(blurred);
title('Blurred Image');

%% Restore the Blurred Image
% The simplest syntax for |deconvwnr| is |deconvwnr(A, PSF, NSR)|, where
% |A| is the blurred image, |PSF| is the point-spread function, and |NSR|
% is the noise-power-to-signal-power ratio.  The blurred image formed in
% Step 2 has no noise, so we'll use 0 for |NSR|.

wnr1 = deconvwnr(blurred, PSF, 0);
imshow(wnr1);
title('Restored Image');

%% Simulate Blur and Noise
% Now let's try adding noise.
noise_mean = 0;
noise_var = 0.0001;
blurred_noisy = imnoise(blurred, 'gaussian', ...
                        noise_mean, noise_var);
imshow(blurred_noisy)
title('Simulate Blur and Noise')

%% Restore the Blurred and Noisy Image: First Attempt
% In our first restoration attempt, we'll tell |deconvwnr| that there is no
% noise (NSR = 0).  When NSR = 0, the Wiener restoration filter is equivalent
% to an ideal inverse filter.  The ideal inverse filter can be extremely
% sensitive to noise in the input image, as the next image shows:

wnr2 = deconvwnr(blurred_noisy, PSF, 0);
imshow(wnr2)
title('Restoration of Blurred, Noisy Image Using NSR = 0')

%%
% The noise was amplified by the inverse filter to such a degree that only
% the barest hint of the man's shape is visible.

%% Restore the Blurred and Noisy Image: Second Attempt
% In our second attempt we supply an estimate of the
% noise-power-to-signal-power ratio.

signal_var = var(I(:));
wnr3 = deconvwnr(blurred_noisy, PSF, noise_var / signal_var);
imshow(wnr3)
title('Restoration of Blurred, Noisy Image Using Estimated NSR');

%% Simulate Blur and 8-Bit Quantization Noise
% Even a visually imperceptible amount of noise can affect the result.
% Let's try keeping the input image in |uint8| representation instead of
% converting it to |double|.

I = imread('cameraman.tif');
class(I)

%%
% If you pass a |uint8| image to |imfilter|, it will quantize the output 
% in order to return another |uint8| image.

blurred_quantized = imfilter(I, PSF, 'conv', 'circular');
class(blurred_quantized)

%% Restore the Blurred, Quantized Image: First Attempt
% Again, we'll try first telling |deconvwnr| that there is no noise.

wnr4 = deconvwnr(blurred_quantized, PSF, 0);
imshow(wnr4)
title('Restoration of blurred, quantized image using NSR = 0');

%% Restore the Blurred, Quantized Image: Second Attempt
% Next, we supply an NSR estimate to |deconvwnr|.

uniform_quantization_var = (1/256)^2 / 12;
signal_var = var(im2double(I(:)));
wnr5 = deconvwnr(blurred_quantized, PSF, ...
    uniform_quantization_var / signal_var);
imshow(wnr5)
title('Restoration of Blurred, Quantized Image Using Computed NSR');

displayEndOfDemoMessage(mfilename)
