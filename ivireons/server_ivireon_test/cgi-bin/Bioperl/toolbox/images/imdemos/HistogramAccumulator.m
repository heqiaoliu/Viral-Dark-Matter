% HistogramAccumulator Accumulate incremental histogram.
%   HistogramAccumulator is a class that incrementally builds up a
%   histogram for an image.  This class is appropriate for use with 8-bit
%   or 16-bit integer images and is for educational purposes ONLY.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/11/09 16:24:41 $

classdef HistogramAccumulator < handle
   
    properties
        Histogram
        Range
    end
    
    methods
        
        function obj = HistogramAccumulator()
            obj.Range = [];
            obj.Histogram = [];
        end
        
        function addToHistogram(obj,new_data)
            if isempty(obj.Histogram)
                obj.Range = double(0:intmax(class(new_data)));
                obj.Histogram = hist(double(new_data(:)),obj.Range);
            else
                new_hist = hist(double(new_data(:)),obj.Range);
                obj.Histogram = obj.Histogram + new_hist;
            end
        end
    end
end
