function calcEyeCrossingTime(this, horHistI, horHistQ, nSym, Fs, SamplesPerSymbol)
%CALCEYECROSSINGTIME Calculates the crossing times of the eye diagram
%   CALCEYECROSSING(H, HORHISTI, HORHISTQ, NSYM, FS)
%   calculates the crossing times on both the in-phase and quadrature components
%   of the signal.  HORHISTI and HORHISTQ are the horizontal histograms of level
%   crossing points for in-phase and quadrature signals, respectively.  NSYM is
%   the number of symbols in a single trace of the eye diagram.  FS is the
%   sampling frequency of the signal.
%
%   CALCEYECROSSING(H, HORHISTI, [], NSYM, FS)
%   calculates crossing times on only the in-phase component of the signal.

%   @commscope/@eyemeaurements
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/11/13 04:14:21 $

try
    % Clear previous measurements
    this.PrivCrossingTime = [];
    this.PrivCrossingAmp = [];

    % Determine each crossing time for the in-phase signal
    [this.PrivCrossingTime(1, :) this.PrivCrossingTimeStd(1, :)] = ...
        findCrossingTimes(horHistI, nSym);
    
    if ~isempty(horHistQ)
        % Determine each crossing time for the quadrature signal
        [this.PrivCrossingTime(2, :) this.PrivCrossingTimeStd(2, :)] = ...
            findCrossingTimes(horHistQ, nSym);                
    end

    if any(sum(this.PrivCrossingTime, 2) == 0)
        this.issueAnalyzeError([this.getErrorId ':CrossingTimeFailed'], ...
            'crossing times');
    end
    
    wrapFlag = [false false];    
    % Wrap crossing time if smaller than 1
    if this.PrivCrossingTime(1, 1) < 1
        this.PrivCrossingTime(1, 1) = ...
            nSym*SamplesPerSymbol-this.PrivCrossingTime(1, 1);
        this.PrivCrossingTime(1,:) = sort(this.PrivCrossingTime(1,:));
        wrapFlag(1) = true;
    end

    if ~isempty(horHistQ)         
        if this.PrivCrossingTime(2, 1) < 1
            this.PrivCrossingTime(2, 1) = ...
                nSym*SamplesPerSymbol-this.PrivCrossingTime(2, 1);
            this.PrivCrossingTime(2,:) = sort(this.PrivCrossingTime(2,:));
            wrapFlag(2) = true;
        end
        if xor(wrapFlag(1), wrapFlag(2))
            if wrapFlag(1)
                str1 = 'in-phase'; 
                str2 = 'quadrature';
            else
                str1 = 'quadrature';
                str2 = 'in-phase'; 
            end
            warning([this.getErrorId ':UnevenWrapping'], ...
                ['The eye crossing time measurement for the %s branch ',...
                'has been wrapped and that of the %s branch has not. ',...
                'Consider shifting the eye measurements by adding one ',... 
                'half symbol duration to the current value in the ',...
                'MeasurementDelay property.'],str1, str2);
        end
    end         
    % Convert to seconds
    this.EyeCrossingTime = (this.PrivCrossingTime-1) / Fs;
    this.PrivCrossingTimeStd = this.PrivCrossingTimeStd / Fs;
catch exception
    throw(exception);
end

%-------------------------------------------------------------------------------
function [crossingTime crossingTimeStd]  = findCrossingTimes(crossingPdf, ...
    numCrossingPoints)

% Initialize.  Assumes that length(crossingPdf) is an integer multiple of nSamps
crossingPdfLen = size(crossingPdf, 2);
slotLen = crossingPdfLen/numCrossingPoints;
slot = reshape(1:crossingPdfLen, slotLen, numCrossingPoints)';
crossingTime = zeros(1, numCrossingPoints);
crossingTimeStd = zeros(1, numCrossingPoints);

% First determine a course eye center to calculate boundaries for crossing point
% calculations.  Note that there are two crossing points.
eyeCenter = findEyeCenter(mean(crossingPdf, 1)');

if ~isnan(eyeCenter)
    offset = round(eyeCenter - slotLen);

    % Add offset to make the first slot full size and take the mean value of the
    % pdfs
    crossingPdf = mean(circshift(crossingPdf, [0 -offset]), 1);

    % Calculate fine crossingPoints
    for p=1:numCrossingPoints
        y = crossingPdf(slot(p,:));
        x = slot(p,:);
        crossingTime(1, p) = (x*y')/sum(y);
        crossingTimeStd(1, p) = sqrt(((x.^2)*y' / sum(y)) - crossingTime(p)^2);
    end;

    % Remove offset and sort
    [crossingTime idx] = sort(mod(crossingTime + offset, crossingPdfLen));
    crossingTimeStd = crossingTimeStd(idx);
else
    crossingTime = [0 0];
    crossingTimeStd = [0 0];
end
%-------------------------------------------------------------------------------
function eyeCenter = findEyeCenter(yPdf)
% FINDEYECENTER assumes that the PDF is for 2 symbols per trace, that is, there
% are two crossing points in the pdf separated by one symbol period, which is
% half of the length of the PDF.  If the input does not confirm to these
% requirements, the result will be wrong.

% Calculate single crossing PDF by summing two PDFs
len = length(yPdf);
len2 = len/2;
yPdfSingle = yPdf(1:len2) + yPdf(len2+1:len);


% The single symbol duration PDF may have been wrapped around at the symbol
% duration egde.  Calculate mean value for all possible shift values to avoid
% such a case.
x = (1:len2);
total = sum(yPdfSingle);
crossPoint = zeros(1, len2);
for p=1:len2
    pdfShifted = circshift(yPdfSingle, p);
    crossPoint(p) = x*pdfShifted / total - p;
end

% Eye center is the most common crossing point value calculated with shifted
% values plus the half symbol duration.
xPoint = mode(round(crossPoint));
if xPoint < 0
    eyeCenter = xPoint + 3*len2/2;
else
    eyeCenter = xPoint + len2/2;
end
%-------------------------------------------------------------------------------
% [EOF]
