function this = init(this,varargin)
% INIT  Initialize a time series object with new time and data values
%
%   INIT(TS,DATA) initializes the time series object TS with the data in
%   DATA. By default, the time vector ranges from 0 to N-1, where N is the
%   number of samples, and has an interval of 1 second. The default name of
%   the TS object is 'unnamed'.  
%
%   INIT(TS,DATA,TIME) initializes the time series object TS with the 
%   data in DATA and the time vector in TIME. Note: When the times are date
%   strings, the TIME must be specified as a cell array of date strings.
%
%   INIT(TS,DATA,TIME,QUALITY) initializes the time series object TS with
%   the data in DATA, the time vector in TIME, and data quality in QUALITY.
%   Note: When Quality is a vector, which must have the same length as
%   the time vector, then each Quality value applies to the corresponding
%   data sample. When Quality has the same size as TS.Data, then each
%   Quality value applies to the corresponding element of a data array.
%
%   You can enter property-value pairs after the DATA,TIME,QUALITY
%   arguments:
%       'PropertyName1', PropertyValue1, ...
%   that set the following additional properties of time series object: 
%       (1) 'Name': a string that specifies the name of this time series object.  
%       (2) 'IsTimeFirst': a logical value, when TRUE, indicates that the
%       first dimension of the data array is aligned with the time vector.
%       Otherwise the last dimension of the data array is aligned with the
%       time vector.
%       (3) 'isDatenum': a logical value, when TRUE, indicates that the time vector
%       consists of DATENUM values
%       (4)-(6) 'StartTime','EndTime',or 'Interval': numeric scalars which
%       specify the parameters of a uniform time vector. Note that these
%       will be ignored if a time vector is specified explicitly.
%
%   Note: The INIT function does not change the 'StartDate' and
%   'Format' fields in the 'TimeInfo' property.
% 
%   See also TIMESERIES
%

%   Copyright 2005-2010 The MathWorks, Inc.
%

this.BeingBuilt = true;
b_state = warning('query','backtrace');
w_state = warning;
warning off backtrace
if numel(this)~=1
    error('timeseries:init:noarray',...
        'The init method can only be used for a single timeseries object');
end

try    
    % Prepare input argument
    ni = nargin-1; % ni >= 1

    % initialize local variables
    quality = [];
    istimefirst = [];
    isdatenumprovided = [];
    interpretSingleRowDataAs3D = [];

    % uniform time parameters
    startTime = NaN;
    endTime = NaN;
    interval = NaN; 
    
    % PV starts
    dataInputStartPos = 0;
    PNVStart = 0;
    while dataInputStartPos<ni && PNVStart==0
      nextarg = varargin{dataInputStartPos+1};
      if ischar(nextarg) && isvector(nextarg)
         PNVStart = dataInputStartPos+1;  
      else
         dataInputStartPos = dataInputStartPos+1;
      end
    end

    % Deal with PV set
    if isempty(this.Name)
        this.Name = 'unnamed';
    end
    if PNVStart>0
        for i=PNVStart:2:ni
            % Set each Property Name/Value pair in turn. 
            Property = varargin{i};
            if i+1>ni
                error('timeseries:init:pvset',...
                    'A specified property has no corresponding value.')
            else
                Value = varargin{i+1};
            end
            % Perform assignment
            switch lower(Property)
                case 'name'
                    % Assign the name
                    if ischar(Value) 
                        % Name has been specified 
                        this.Name = Value;
                    end
                case 'istimefirst'
                    if ~isempty(Value) && isscalar(Value) && islogical(Value) 
                        % IsTimeFirst has been specified
                        istimefirst = Value;
                    else
                        error('timeseries:init:pvset',...
                            'IsTimeFirst property must be a logical scalar value.')
                    end
                case 'isdatenum'
                    if ~isempty(Value) && isscalar(Value) && islogical(Value) 
                        % IsTimeFirst has been specified
                        isdatenumprovided = Value;
                    else
                        error('timeseries:init:pvset',...
                            'IsDatenum property must be a logical scalar value.')
                    end
                case 'interpretsinglerowdataas3d'
                    if ~isempty(Value) && islogical(Value)
                        % interpretSingleRowDataAs3D has been specified
                        interpretSingleRowDataAs3D = Value;
                    else
                        error('timeseries:init:pvset',...
                            'InterpretSingleRowDataAs3D property must be a logical scalar.')
                    end 
                case 'starttime'
                    if ~isempty(Value) && isnumeric(Value) && isscalar(Value)
                        % startTime has been specified
                        startTime = Value;
                    else
                        error('timeseries:init:pvset',...
                            'StartTime property must be a numeric scalar.')
                    end  
                case 'endtime'
                    if ~isempty(Value) && isnumeric(Value) && isscalar(Value)
                        % endTime has been specified
                        endTime = Value;
                    else
                        error('timeseries:init:pvset',...
                            'EndTime property must be a numeric scalar.')
                    end 
                case 'interval'
                    if ~isempty(Value) && isnumeric(Value) && isscalar(Value)
                        % interval has been specified
                        interval = Value;
                    else
                        error('timeseries:init:pvset',...
                            'Interval property must be a numeric scalar.')
                    end 
                otherwise
                    error('timeseries:init:pvset','Invalid property name')
           end % switch
        end % for
    end

    % Parse inputs
    switch dataInputStartPos
        % PV starts from the 1st input argument
        case 0
            % Data array must be the first input
            error('timeseries:init:data','First argument must be data.')
        % PV starts from the 2nd input argument
        case 1         
            % Accept: timeseries(data),timeseries([])
            if ~isnumeric(varargin{1}) && ~islogical(varargin{1}) && ...
                    ~isobject(varargin{1})
                error('timeseries:init:nodata',...
                          'The first argument must contain the data.')
            else
                data = varargin{1};
            end
            sizeData = size(data); 
            if isempty(istimefirst)
                time = struct('Length',sizeData(1)*(sizeData(1)~=1) + sizeData(end)*(sizeData(1)==1),...
                    'StartTime',startTime, 'EndTime',endTime,'Interval',interval);
            else
                time = struct('Length',sizeData(1)*istimefirst+sizeData(end)*(~istimefirst),...
                    'StartTime',startTime,'EndTime',endTime,'Interval',interval);
            end
        case {2, 3}
            % Process data vector first
            if ~isnumeric(varargin{1}) && ~islogical(varargin{1})
                    error('timeseries:init:nodata',...
                          'The first argument must contain the data.')
            else
                data = varargin{1};
            end
                
            % Deal with second arg.  Note: don't change the order of the
            % following if-else if branch structure
            if isempty(varargin{2}) 
                % 2nd arg is empty
                
                if ~isempty(data)
                    sizeData = size(data);
                    % Create a uniform time struct from any uniform time params
                    if isempty(istimefirst)
                        time = struct('Length',sizeData(1)*(sizeData(1)~=1) + sizeData(end)*(sizeData(1)==1),...
                            'StartTime',startTime,'EndTime',endTime,'Interval',interval);
                    else
                        time = struct('Length',sizeData(1)*istimefirst+sizeData(end)*(~istimefirst),...
                           'StartTime',startTime,'EndTime',endTime,'Interval',interval);
                    end
                else
                    time = varargin{2};
                end
            elseif isa(varargin{2},'tsdata.timemetadata') 
                % 2nd arg is a timemetadata object (required by Simulink Timeseries)
                % still build a local time vector
                time = varargin{2};
            elseif isa(varargin{2},'char')
                % Treat as absolute time vector in a char array
                time = mat2cell(varargin{2},ones(size(varargin{2},1),1),size(varargin{2},2));
            elseif isnumeric(varargin{2})
                % Second argument is a time vector
                time = varargin{2};
            elseif iscell(varargin{2})
                % Second argument is a cell array. If it contains no dates
                % (chars), try to convert it to a numeric array.
                time = varargin{2};
                if ~any(cellfun('isclass',time,'char'))
                    % numeric time values stored in cell array
                    time = cell2mat(time);
                end
            else
                error('timeseries:init:notime',...
                    'The second argument must be either the time vector or the time series name.')
            end
            if dataInputStartPos == 3
                if iscell(varargin{3})
                    error('timeseries:init:qualitycell',...
                        'Quality values must be specified as an integer array.')
                else
                    quality = varargin{3};
                end        
            end
        otherwise
            error('timeseries:init:input',...
                'Too many input arguments.  Use INIT(TS, DATA, TIME, ''PropertyName1'', PropertyValue1, ...) instead.')
    end


    size_data = size(data);
    % For empty time assign the empty data (0x... or ...x0).
    if isempty(time)
        % Since the time vector has length 0, isTimeFirst must be false
        % if the first dimension of the data is not zero.
        if isempty(istimefirst)
            this.IsTimeFirst_ = (size_data(1)==0);
        else
            this.IsTimeFirst_ = istimefirst;
        end
        if size(time,1)~=0
            this.Time = time(:);
        else
            this.Time = time;
        end
        this.Data = data;
        this.Quality = [];
        this.BeingBuilt = false;
        warning(b_state);
        warning(w_state);
        return;    
    elseif isnumeric(time) || isstruct(time) || iscell(time) || ...
            isa(time,'tsdata.timemetadata')
       % Check the time format only if it is a numeric vector
       if isnumeric(time)          
           time = timeseries.tsChkTime(time);
       end

       if isnumeric(time) || iscell(time)
           lenTime = length(time);
       elseif isstruct(time) || isa(time,'tsdata.timemetadata')
           lenTime = time.Length;
       else
           error('timeseries:init:invtime',...
                'Invalid time value.') 
       end
       
       % Attempt to reshape incompatible data, time and quality
       if isempty(istimefirst)
          [data,quality,istimefirst] = timeseries.utreshape(...
              lenTime,data,quality);
       else
           % Toggle the isTimeFirst flag if that is enough to make data 
           % and time compatible.
           if ~istimefirst && lenTime>1 && lenTime~=size(data,ndims(data)) && ...
                   lenTime==size(data,1)
               istimefirst = true;
           elseif istimefirst && lenTime>1 && lenTime~=size(data,1) && ...
                   lenTime==size(data,ndims(data))
               istimefirst = false;
           end     
           [data,quality] = timeseries.utreshape(...
              lenTime,data,quality,istimefirst);
       end
       
       % Sort time and data vectors
       if isnumeric(data) || islogical(data)
           % Check the order of time only if it is specified as a numeric
           % array or cell array
           if isnumeric(time)
               [time, data, quality] = ...
                   timeseries.utsorttime(time,data,quality,istimefirst);
           elseif iscell(time)
               [~, data, quality, I] = timeseries.utsorttime(datenum(time),...
                  data,quality,istimefirst);                
           end
       end
    end
    
    % Assign the time vector
    % If datenum values are provided
    if ~isempty(isdatenumprovided) && isdatenumprovided && isnumeric(time)
        time = datestr(time);
        this.TimeInfo.Units = 'days';
        this = setabstime(this,time);
    elseif isnumeric(time)
        this.Time = time;
    % If date strings are provided        
    elseif iscell(time)
        % Absolute date never sorted before  
        this.TimeInfo.Units = 'days';
        this = setabstime(this,time(I));
    elseif isstruct(time) && isfield(time,'StartTime') && isfield(time,'EndTime') && ...
            isfield(time,'Interval')
        % Create a tsdata.timemetadata with deprecation warnings for object
        % setting using the create static constructor.
        timeInfo = tsdata.timemetadata.create;
        
        timeInfo = timeInfo.setlength(time.Length);
        if time.Length>=2
           this.TimeInfo = timeInfo.setuniformtime(time.StartTime,...
               time.Interval,time.EndTime);
        elseif time.Length==1
           this.TimeInfo = timeInfo.reset(0);
        else
           this.TimeInfo = timeInfo;
        end
    elseif isa(time,'tsdata.timemetadata')
        this.TimeInfo = varargin{2};
    else
           error('timeseries:init:invtime',...
                'Invalid time value.') 
    end
   
    
    
    if ~isempty(istimefirst)
        this.IsTimeFirst_ = istimefirst;
    end
    if ~isempty(quality)
        this.Quality = quality;
    end
    
    % Write custom interpretSingleRowDataAs3D to DataInfo. 
    if ~isempty(interpretSingleRowDataAs3D)
        this.DataInfo.InterpretSingleRowDataAs3D = interpretSingleRowDataAs3D;
    end
    this.Data = data;
catch me % Restore warning state before rethrowing error
    warning(b_state);
    warning(w_state);
    rethrow(me);
end
this.BeingBuilt = false;
warning(b_state);
warning(w_state);
