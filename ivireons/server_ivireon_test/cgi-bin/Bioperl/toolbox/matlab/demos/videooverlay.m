%% Annotating Video by Overlaying a Plot
% This demo illustrates a technique for reading in a video file using 
% the |mmreader| object and overlaying an analysis plot over the video.
% 
% Currently the |mmreader| object works on supported Windows(R) and
% Macintosh(R) operating systems only.
%
% <matlab:playbackdemo('videooverlay_final','toolbox/matlab/demos/html')
% Watch the final video.>
%
% See also MMREADER, MOVIE

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2007/12/17 06:24:28 $

%% Step 1: Access the Video Using the MMREADER Object
% The |mmreader| object provides a mechanism for efficiently reading in
% video frames from a multimedia file.  First, create the object
% representing the video clip to work with.  This does not load the file,
% it simply opens it, and configures the decoder.
clip = mmreader('rhinos.mpg')

%% Step 2: Read the First Frame
% |mmreader| can read one or more frames at a time into the MATLAB 
% workspace.  To illustrate the overlay technique this demo will operate 
% on a single frame, and then go back and complete all the frames 
% at the end.
frame = read(clip,1);

%%
% The |read| method reads a frame as a H x W x B x F array where H is the 
% image frame height, W is the image frame width, B is the number of bands 
% in the image (e.g., 3 for RGB), and F is the number of frames read.
framesize = size(frame)

%%
% Show the frame that was read in and resize the figure to display |frame| 
% at its native resolution.
theFigure = gcf;
figpos = get(theFigure, 'Position');
set(theFigure,'Units', 'pixels');
set(theFigure, 'Position', [figpos(1) figpos(2) framesize(2) framesize(1)]);
image(frame)
axis off;
theAxis = get(theFigure, 'CurrentAxes');
set(theAxis, 'Position', [0 0 1 1]);

%% Step 3: Calculate a Histogram of the Three Color Distributions
% A simple way of analyzing the frame is to create a 256 bin histogram of 
% the 3 color planes of the image.  To do this, transform the frames into 3
% vectors of pixels (red, green, blue), appropriate for the HIST function.
% HIST requires the inputs to be doubles.
numbins = 256;
pixels = numel(frame)/3;
framehist = hist(double(reshape(frame,pixels,3)),numbins);

%% Step 4: Plot the Histogram
% Plot the histograms and resize the axis to match the histogram sizes.
% Also, set the background color to black to make it easier to overlay the
% graphic.
hlines = plot(framehist);
set(theFigure,'Color','black');
axis([0 numbins 0 max(framehist(:))]);
axis off;

%%
% Simplify and recolor the bar chart so the red bar represents the red
% color plane, the green bar the green color plane, and the blue bar the 
% blue color plane.
set(hlines(1),'Color','red');
set(hlines(2),'Color','green');
set(hlines(3),'Color','blue');

%%
% Resize the axis to use the lower half of the frame.
set(theAxis,'Units','Pixels');
set(theAxis,'Position',[ 0   0  framesize(2) framesize(1)/2 ]);

%% Step 5: Overlay the Graphic onto the Video 
% One technique for overlaying the plot onto the video frame is to create a
% new image containing both the histogram and the video data.  Start by 
% taking a snapshot of the histogram plot.
final = getframe(theFigure);

%%  
% Calculate the mask for the overlay. The mask will be zero any place that 
% the histogram plot is nonzero, and one any place the histogram plot is 
% zero.
% 
mask = uint8(sum(final.cdata,3) == 0);

%%
% Now the replicate the mask on all three color planes. This gives us a
% mask that is the same size as the original image with only one or zero
% values in each of the rgb planes.
maskRGB = repmat( mask ,[1 1 3]);

%%
% To apply the mask the video frame, do an elementwise multiplication.
% For each pixel in the video, if the corresponding mask pixel is (1, 1, 1)
% the resulting pixel color will be the same as the video frame.  If the
% mask pixel is (0, 0, 0), the resulting pixel color will be black.
% 
maskedFrame = maskRGB .* frame;

%%
% Here is what the frame looks like after being masked.
%
displayFigure = figure;
figpos = get(displayFigure, 'position');
set(displayFigure, 'position', [figpos(1) figpos(2) framesize(2) framesize(1)]);
image( maskedFrame )
axis off;
displayAxis = get(displayFigure, 'CurrentAxes');
set(displayAxis, 'Position', [0 0 1 1]);

%% 
% The resulting composite frame is the addition of the "masked out" frame
% and the overlayed histogram plot.
final.cdata = maskedFrame + final.cdata;
image(final.cdata)
axis off;

%%
% Close the figure showing our interim results.
close(displayFigure)

%% Step 6: Repeat Overlay Technique for all Video Frames
% Now we go back, and repeat the analysis on the first 10 seconds of the
% video. 

% Limit it to the first 10 seconds of video.
numberOfFrames = get(clip,'NumberOfFrames');
frameRate = get(clip,'FrameRate');
numberOfFrames = min(numberOfFrames,10.0 * frameRate);

for iFrame = 2:numberOfFrames

    % read a frame
    frame = read(clip,iFrame);
    
    % calculate the histogram
    pixels = numel(frame)/3;
    framehist = hist(double(reshape(frame,pixels,3)),numbins);

    % update the plots
    set(hlines(1),'Ydata',framehist(:,1)');
    set(hlines(2),'Ydata',framehist(:,2)');
    set(hlines(3),'Ydata',framehist(:,3)');
   
    % take the snapshot of the figure and overlay
    final(iFrame) = getframe(theFigure);
    mask = uint8(sum(final(iFrame).cdata,3) == 0);
    maskRGB = repmat( mask ,[1 1 3]);
    maskedFrame = maskRGB .* frame;
    final(iFrame).cdata = maskedFrame + final(iFrame).cdata;
end

%% Step 7: Play Back the Movie
movie(final,1,frameRate)

%% Step 8: Clean Up the MMREADER Object
clear clip;

displayEndOfDemoMessage(mfilename)