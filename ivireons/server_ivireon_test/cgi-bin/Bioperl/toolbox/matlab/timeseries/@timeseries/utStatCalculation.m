function out = utStatCalculation(this,method,varargin) 
%UTSTATCALCULATION (used by statistical calculations)

% UTSTATCALCULATION return the result of statistical calculation on data.
% Method is a string, e.g. 'mean'. Varargin involves all the PV pairs for
% optional input arguments: 
%       'MissingData': 'remove' (default) or 'interpolate'
%           indicating how to treat missing data during the calculation
%       'Quality': a vector of integers
%           indicating which quality codes represent missing samples
%           (vector case) or missing observations (>2 dimensional array
%           case) 
%       'Weighting': 'none' (default) or 'time'
%           indicating if times are used as weighting factors during the
%           calculation.  Large time values mean large weight.
%

% Copyright 2004-2010 The MathWorks, Inc.

if numel(this)~=1
    error('timeseries:utStatCalculation:noarray',...
        'The utStatCalculation method can only be used for a single timeseries object');
end
if this.Length==0
    out = [];
    return
end

% Get data
data = this.Data;
quality = this.Quality;
SampleSize = getdatasamplesize(this);

% Set default option values
HowToTreatMissingData = 'remove';
QualityCodeForMissingData = [];
WeightFactor = 'none';

% Check if extra input arguments exist in PV pair format
ni=nargin-2;
if nargin>2
    for i=1:2:ni
        % Set each Property Name/Value pair in turn. 
        Property = varargin{i};
        if i+1>ni
            error('timeseries:utStatCalculation:pvset',...
                'A specified property is missing a corresponding value.')
        else
            Value = varargin{i+1};
        end
        % Perform assignment
        switch lower(Property)
            case 'missingdata'
                if ischar(Value)
                    HowToTreatMissingData = Value;
                    if ~(strcmpi(HowToTreatMissingData,'interpolate') || strcmpi(HowToTreatMissingData,'remove'))
                        error('timeseries:utStatCalculation:missingdata',...
                            'The MissingData argument must be either ''interpolate'' or ''remove''.');
                    end                        
                else
                    error('timeseries:utStatCalculation:missingdata',...
                        'The MissingData argument must be either ''interpolate'' or ''remove''.');
                end
            case 'quality'
                if isnumeric(Value) && isequal(round(Value),Value)
                    QualityCodeForMissingData = Value;
                else
                    error('timeseries:utStatCalculation:quality',...
                        'The Quality argument must be integers.');
                end
            case 'weighting'
                if ischar(Value)
                    WeightFactor = Value;
                    if ~(strcmpi(WeightFactor,'none') || strcmpi(WeightFactor,'time'))
                        error('timeseries:utStatCalculation:weighting',...
                            'The Weighting argument must be either ''none'' or ''time''.');
                    end                            
                else
                    error('timeseries:utStatCalculation:weighting',...
                        'The Weighting argument must be either ''none'' or ''time''.');
                end
            otherwise
                error('timeseries:utStatCalculation:pvset',...
                    'At least one of the specified properties is invalid.')
       end % switch
    end % for
end

% Find missing data based on 'TreatNaNasMissing' and 'quality' values
MissingDataIndex_Observation = false(size(data));
MissingDataIndex_Sample = false(this.length,1);
is = repmat({':'},[1 length(SampleSize)]);
if this.TreatNaNasMissing
    MissingDataIndex_Observation = MissingDataIndex_Observation | isnan(data);
end
if ~isempty(quality)
    % quality is sample-based with size of nx1
    if isvector(quality) || (~this.IsTimeFirst && isequal(size(quality),[ones(1,ndims(data)-1) this.length]))
        quality = quality(:);
        ind = ismember(quality,QualityCodeForMissingData);
        if ~any(ind)
            warning('timeseries:utStatCalculation:noqualitycode',...
                'Since the input quality code is not found in this time series, the code is ignored.')
        end
        MissingDataIndex_Sample = MissingDataIndex_Sample | ind;
        if this.IsTimeFirst
            tmp = [{MissingDataIndex_Sample} is];
        else
            tmp = [is {MissingDataIndex_Sample}];
        end
        MissingDataIndex_Observation(tmp{:})=true;
    elseif isequal(size(quality),size(data))
        ind = ismember(quality,QualityCodeForMissingData);
        if ~any(ind)
            warning('timeseries:utStatCalculation:noqualitycode',...
                'Since the input quality code is not found in this time series, the code is ignored.')
        end
        MissingDataIndex_Observation = MissingDataIndex_Observation | ind;
    end
else
    if ~isempty(QualityCodeForMissingData)
        warning('timeseries:utStatCalculation:noquality',...
            'No quality value is assigned in this time series. The input quality code is ignored.')
    end        
end
        
% No weighting factor
if strcmpi(WeightFactor,'none')
    % interpolate missing data
    if strcmpi(HowToTreatMissingData,'interpolate')
        interpobj = this.DataInfo.Interpolation;
        tmp_data = interpobj.interpolate(this.Time, this.Data, this.Time,[],...
            this.hasduplicatetimes);
    % remove missing data
    else
        tmp_data = data;
        tmp_data(MissingDataIndex_Observation) = NaN;
    end
% Weighted by time
else
    % calculate time factor
    dt = diff(this.time)/2;
    dt1 = [dt(1);dt];
    dt2 = [dt;dt(end)];
    dt = dt1+dt2;
    % interpolate missing data
    if strcmpi(HowToTreatMissingData,'interpolate')
        interpobj = this.DataInfo.Interpolation;
        data = interpobj.interpolate(this.Time, this.Data, this.Time, [], ...
            this.hasduplicatetimes);
        datasize = size(this.Data);
        if this.IsTimeFirst
            data = data.*repmat(dt,[1 datasize(2:end)]);
        else
            data = data.*repmat(dt',[datasize(1:end-1) 1]);
        end
        tmp_data = data/mean(dt);
    % remove missing data
    else
        datasize = size(this.Data);
        if this.IsTimeFirst
            data = data.*repmat(dt,[1 datasize(2:end)]);
        else
            data = data.*repmat(shiftdim(dt',-1),[datasize(1:end-1) 1 1]);
        end
        tmp_data = data/mean(dt);
        tmp_data(MissingDataIndex_Observation) = NaN;
    end
end
        
% Calculation
if this.IsTimeFirst
    dim = 1;
else
    dim = length(size(tmp_data));    
    dim = dim(end);
end
switch method
    case 'mean'
        out = tsnanmean(tmp_data,dim);
    case 'median'
        out = tsnanmedian(tmp_data,dim);
    case 'std'
        out = tsnanstd(tmp_data,0,dim);
    case 'iqr'
        out = tsnaniqr(tmp_data,dim);
    case 'sum'
        out = tsnansum(tmp_data,dim);
    case 'max'
        out = tsnanmax(tmp_data,[],dim);
    case 'min'
        out = tsnanmin(tmp_data,[],dim);
    case 'var'
        out = tsnanvar(tmp_data,0,dim);
    case 'mode'
        out = tsnanmode(tmp_data,dim);
    otherwise
        error('timeseries:utStatCalculation:method','Invalid method argument')                
end

