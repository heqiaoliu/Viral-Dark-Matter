function segmentedCells = batchDetectCells(I)
%batchDetectCells Algorithm to detect cells in image.
%   segmentedCells = batchDetectCells(I) detects cells in the cell
%   image I and returns the result in segmentedCells.
%
%   Supports batch processing demo, ipexbatch. 

%   Copyright 2005-2009 The MathWorks, Inc.

% Use |edge| and the Sobel operator to calculate the threshold
% value. Tune the threshold value and use |edge| again to obtain a
% binary mask that contains the segmented cell.
[~, threshold] = edge(I, 'sobel');
fudgeFactor = .5;
BW = edge(I,'sobel', threshold * fudgeFactor);

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWdilate = imdilate(BW, [se90 se0]);
BWnobord = imclearborder(BWdilate, 4);
BWopen = bwareaopen(BWnobord,200);
BWclose = bwmorph(BWopen,'close');
BWfill = imfill(BWclose, 'holes');
BWoutline = bwperim(BWfill);
segmentedCells = I;
segmentedCells(BWoutline) = 255;