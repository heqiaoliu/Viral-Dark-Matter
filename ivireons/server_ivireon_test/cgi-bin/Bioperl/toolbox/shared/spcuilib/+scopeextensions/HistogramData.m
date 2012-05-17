classdef HistogramData < uiscopes.CoreData
% HISTOGRAMDATA Define the HistogramData Class. This class computes the log2 histogram and statistics of input data. 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $     $Date: 2009/11/16 22:33:32 $

    properties (Access = private)
        BinMax = [];
        BinMin = [];
        Counter = 0;
        PrevBinRange = [];
        SumOfValues = 0;
        SumOfSquares = 0;
    end
    
    properties (Hidden)
        HistData = [];
        isFixedPoint = false;
        isScaledDouble = false;
        dataTypeObject; 
    end
    
    methods
        function this = HistogramData
            this.HistData = initData;
        end
        
        function resetData(this)
            this.HistData = initData;
            this.Counter = 0;
            this.isScaledDouble = false;
            this.isFixedPoint = false;
            this.BinMax = [];
            this.BinMin = [];
            this.SumOfValues = 0;
            this.SumOfSquares = 0;
            
        end
        
        function hist_data = histogramAnalysis(this)
            dataVal = double(this.FrameData(:));
            hist_data = [];
            if ~isempty(dataVal)
                
                % Initialize the hist_data structure.
                hist_data = initData;
                
                %Get the real and imaginary parts of the data and merge them
                %into one vector. For the purposes of a histogram, they are
                %treated the same way. The data is just twice as long
                data_re = real(dataVal);
                % imag(real valued quantity) returns 0 and this can throw off
                % our calculations. Assign the imaginary part to an empty array
                % if the data is real valued.
                data_im = [];
                if ~isreal(dataVal)
                    data_im = imag(dataVal);
                end
                Value = [data_re;data_im];
                this.Counter = this.Counter+numel(Value);
                
                
                % Get the mean and std. deviation of the data.
                [hist_data.Mean, hist_data.StdDev] = getStats(this,Value);
                
                % Find the number of zeros in the data.
                hist_data.numZeros = (((this.HistData.numZeros/100)*(this.Counter-1) + numel(find(Value == 0)))/this.Counter)*100;
                
                hist_data.absData = abs(Value);
                
                % get the max bin for data
                maxVal = max(abs(Value));
                if maxVal == 0 || isinf(maxVal)
                    maxVal = getMaxValue(Value,maxVal);
                    if maxVal ~= 0
                        bmax = ceil(log2(maxVal));
                    else
                        bmax = 0;
                    end
                else
                    bmax = ceil(log2(maxVal));
                end
                this.BinMax = max([this.BinMax bmax]);
                
                % get the min bin for data
                minVal = min(abs(Value));
                if minVal == 0
                    % If zero is the minimum value, find the next least value.
                    minVal =  getMinValue(abs(Value));
                    if minVal ~= 0
                        bmin = ceil(log2(minVal));
                    else
                        bmin = 0;
                    end
                else
                    bmin = ceil(log2(minVal));
                end
                this.BinMin = min([this.BinMin bmin]);
                
                
                % Find the number of negative values.
                hist_data.numNegValues = hist_data.numNegValues + numel(find(Value < 0));
                hist_data.numSamples = this.Counter;
                
                %Get the current data type.
                if isa(this.FrameData,'embedded.fi')
                    this.dataTypeObject = this.FrameData.NumericType;
                    this.isFixedPoint = this.FrameData.isfixed;
                    if isscaleddouble(this.FrameData)
                        this.isScaledDouble = true;
                        if this.FrameData.issigned
                            str = 's';
                        else
                            str = 'u';
                        end
                        str = [str 'flt'];
                        hist_data.DataType = sprintf('%s%s,%s',str,int2str(this.FrameData.WordLength),int2str(this.FrameData.FractionLength));
                    elseif isfloat(this.FrameData)
                        hist_data.DataType = this.FrameData.DataType;
                    elseif isfixed(this.FrameData)
                        hist_data.DataType = sprintf('%s(%s,%s,%s)',...
                            'numerictype',...
                            int2str(this.FrameData.issigned), ...
                            int2str(this.FrameData.WordLength), ...
                            int2str(this.FrameData.FractionLength));
                    end
                else
                    hist_data.DataType = this.DataType;
                end
                
                % Get the min/max values of the raw data.
                hist_data.min = min(Value);
                hist_data.min = min([this.HistData.min,hist_data.min]);
                hist_data.max = max(Value);
                hist_data.max = max([this.HistData.max,hist_data.max]);
                
                
                % Get the min/max values of abs(data)
                [hist_data.maxAbs, hist_data.minAbs] = calcMaxMin(hist_data);
                hist_data.maxAbs = max([this.HistData.maxAbs,hist_data.maxAbs]);

                % Get the non-zero min value.
                if ~isinf(this.HistData.minAbs)
                    hist_data.minAbs = getMinValue([this.HistData.minAbs,hist_data.minAbs]);
                end
                
                % Remove occurrences of 0 in the data before applying log2
                hist_data.ZeroIdx = (hist_data.absData==0);
                hist_data.absData(hist_data.ZeroIdx) = 2^(this.BinMin);
                
                % Compute the log2
                hist_data.log2 = log2(hist_data.absData);
                
                hist_data.BinMin = this.BinMin;
                hist_data.BinMax = this.BinMax;
                hist_data.bRange = hist_data.BinMin:hist_data.BinMax;
                
                
                % Calculate the histogram data
                hist = calcHist(this, hist_data);
                
                hist_data.hist = hist;
                % We don't need to store the log2 values.
                hist_data.log2 = [];
                this.HistData = hist_data;
            end
        end
        
        function resetCounter(this)
            this.Counter = 0;
        end
    end
    
    methods(Static)
        function [errID, errMsg] = checkInputData(data)
            % Validate input data.
            errMsg = '';errID = '';
            % If data is empty, we don't need to continue with the checks.
            if isempty(data); return;end
            if ~isnumeric(data)
                errID = 'FixedPoint:fiEmbedded:incorrectInputType';
                errMsg = DAStudio.message(errID);
            elseif all(isinf(data(:))) || all(isnan(data(:))) || issparse(data)
                errID = 'FixedPoint:fiEmbedded:invalidData';
                errMsg = DAStudio.message(errID);
            end
        end
    end
    
    
    methods (Access = protected)
        function yhist = calcHist(this, data)
            %Normalize histograms over all samples, including zeros.
            
            yhist = this.HistData.hist;
            x = data.log2;
            x(data.ZeroIdx) = [];
            np = data.numSamples;
            bins = this.BinMin:this.BinMax;
            if length(bins) == 1
                bins = this.BinMin-1:this.BinMax+1;
            end
            if ~isempty(this.PrevBinRange)
                temp = zeros(1, length(bins));
                % find the boundaries of the previous histogram on the
                % current one for alignment before adding the histograms.
                idx1 = find(bins == this.PrevBinRange(1));
                idx2 = find(bins == this.PrevBinRange(end));
                if isempty(idx1)
                    temp(idx2-length(yhist)+2:idx2) = yhist(2:end);
                elseif isempty(idx2)
                    temp(idx1:idx1+length(yhist)-2) = yhist(1:end-1);
                else
                    temp(idx1:idx2) = yhist;
                end
                yhist = temp;
            end
            % bins will be empty if the value is Inf.
            if ~isempty(bins)
                % In case we hit zero-valued data, the hist function will
                % return a coulumn vector. Make sure that we always operate on
                % a column vector so that we add vectors of matching
                % dimensions.
                yhist = ((yhist*(np-length(x))/100 + reshape(hist(ceil(x(:)), bins),1,[]))/np)*100;
            end
            this.PrevBinRange = bins;
        end
    end
end

%*******************************************************************
%
%      LOCAL FUNCTIONS
%
%*******************************************************************

function data = initData
data.maxAbs = 0;
data.max = [];
data.minAbs = Inf;
data.min = Inf;
data.hist = 0;
data.DataType = '';
data.numNegValues = 0;
data.numSamples = 0;
data.Mean = [];
data.StdDev = [];
data.numZeros = 0;
data.ovfl = 0;
data.uflw = 0;
end
%-----------------------------------------
function [m, stddev] = getStats(this,dataVal)
% Compute the mean and standard deviation of the raw data.

this.SumOfValues = this.SumOfValues + sum(dataVal);
this.SumOfSquares = this.SumOfSquares + sum((dataVal).^2);
m = this.SumOfValues/this.Counter;
stddev = sqrt((this.SumOfSquares/this.Counter) - m^2);

end
%----------------------------------------
function [ymax, ymin] = calcMaxMin(data)
ymax = data.maxAbs;
ymin = data.minAbs;
absData = data.absData;
if ~isempty(absData)
    ymax = max(data.maxAbs,max(max(absData)));
    ymin = min(data.minAbs,min(min(absData)));
    if ymin == 0
        x = sort([data.minAbs;absData] ,'ascend');
        idx = find(x == 0);
        % If x is a vector of zeros, then length(x) == idx(end)
        if length(x) > idx(end)
            if ~isinf(x(idx(end)+1))
                ymin = x(idx(end)+1);
            end
        end
    end
end
end

%---------------------------------------
function val = getMinValue(data)
% Get the least non-zero value. data can be positive or negative.

x = sort(data,'ascend');
idx = find(x == 0);
% handle all-zero data
if ~isempty(idx)
    % If x is a vector of zeros, then length(x) == idx(end)
    if length(x) > idx(end)
        val = x(idx(end)+1);
    else
        val = 0;
    end
else
    val = x(1);
end
end
%----------------------------------------
function val = getMaxValue(data,maxval)
% Get the least non-zero value.

x = sort(data,'descend');
idx = find(x == maxval);
% If x is a vector of zeros, then length(x) == idx(end)
if length(x) > idx(end)
    val = x(idx(end)+1);
else
    val = 0;
end
end
%----------------------------------------

