%TIMESERIES  Create a time series object.
%
%   TS = TIMESERIES creates an empty time series object.
% 
%   TS = TIMESERIES(DATA) creates a time series object TS using
%   data DATA. By default, the time vector ranges from 0 to N-1,
%   where N is the number of samples, and has an interval of 1 second. The
%   default name of the TS object is 'unnamed'.  
%
%   TS = TIMESERIES(NAME), where NAME is a string, creates an
%   empty time series object TS called NAME.
%
%   TS = TIMESERIES(DATA,TIME) creates a time series object TS
%   using data DATA and time in TIME. Note: When the times
%   are date strings, the TIME must be specified as a cell array of date
%   strings. 
%
%   TS = TIMESERIES(DATA,TIME,QUALITY) creates a time series object
%   TS using data DATA, the time vector in TIME, and data quality in
%   QUALITY. Note: When QUALITY is a vector, which must have the same
%   length as the time vector, then each QUALITY value applies to the
%   corresponding data sample. When QUALITY has the same size as TS.Data,
%   then each QUALITY value applies to the corresponding element of a data
%   array. 
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
%       consists of DATENUM values. Note that 'isDatenum' is not a property
%       of the time series object.
%
%   EXAMPLES:
%   Create a time series object called 'LaunchData' that contains 4 data 
%   sets (stored as columns with length of 5) and uses a default time vector:
%
%   b = timeseries(rand(5,4),'Name','LaunchData')
%
%   Create a time series object containing a single data set of length 5
%   and a time vector starting at 1 and ending at 5:
%
%   b = timeseries(rand(5,1),[1 2 3 4 5])
%
%   Create a time series object called 'FinancialData' containing 5 data 
%   points at a single time point:
%   b = timeseries(rand(1,5),1,'Name','FinancialData')
%
%   See also TIMESERIES/ADDSAMPLE, TIMESERIES/TSPROPS

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.23 $  $Date: 2010/04/05 22:23:11 $

classdef (CaseInsensitiveProperties = true) timeseries
    properties
        Events = [];
        Name = '';
        UserData = [];
    end
    properties (Dependent = true)
        Data;
    end
    properties
        DataInfo = [];
    end 
    properties (Dependent = true)
        Time;
    end
    properties
        TimeInfo = [];
    end     
    properties (Dependent = true)
        Quality;
    end
    properties
        QualityInfo = [];
    end 
    properties (Dependent = true)
        IsTimeFirst;
    end
    properties
        TreatNaNasMissing = true;
    end
    properties (Dependent = true, SetAccess = protected)
        Length;
    end
    properties (SetAccess = protected, Hidden = true)
        Data_ = [];
        Time_ = [];
        Quality_ = [];
    end
    % Simulink needs access so these props cannot be read-only
    properties (Hidden = true)
        IsTimeFirst_ = true;
        Storage_ = [];
    end    
    properties (Hidden = true, GetAccess = protected, SetAccess = protected)
        Version = 10.1;
    end      
    properties (Hidden = true)
        BeingBuilt = false;
    end
    
    methods
        function this = setprop(this,propName,propVal)
            this.(propName) = propVal;
        end
        function propval = getprop(this,propName)
            propval = this.(propName);
        end
        function outtime = get.Time(this)
            timeMetadata = this.TimeInfo;
            if ~isempty(timeMetadata) 
                outtime = timeMetadata.getData;
            else
                outtime = [];
            end
        end              
        function this = set.Time(this,input)
            % Verify the size of the time vector if BeingBuilt is false and
            % if we are not adding a non-empty time vector to an empty
            % timeseries.
            if ~this.BeingBuilt 
                 this.chkTimeProp(input);                    
            end
            this.TimeInfo = reset(this.TimeInfo,input);
        end  
        
        function outdata = get.Data(this)
            dataInfo = this.DataInfo;
            % Storage order of precedence:
            % 1. DataInfo storage object gets the first opportunity to
            % provide data
            % 2. Storage_ object
            % 3. Cached Data_
            if ~isempty(dataInfo) && dataInfo.isstorage
                % Pass the Time and TimeInfo to getData so that data
                % storage can use information about the time vector
                % to reconstruct the data if needed.
                outdata = dataInfo.getData(this.Time,this.TimeInfo);
            elseif ~isempty(this.Storage_)      
                % Pass the Time and TimeInfo to getData so that data
                % storage can use information about the time vector
                % to reconstruct the data if needed.
                outdata = this.Storage_.getData(this.Time,this.TimeInfo);
            else
                outdata = this.Data_;
            end
        end
        
        function this = set.Data(this,input)
          if iscell(input)
              error('timeseries:subsasgn:nocell',...
                  'Timeseries data cannot be assigned to a cell array')
          end   
          len = this.Length;

          % Verify the size of the data array if BeingBuilt is false and
          % if we are not adding a non-empty data array to an empty
          % timeseries. If necessary reshape data to conform to grid.
          if ~this.BeingBuilt && len>0             
              % Data should not be reshaped if the timeseries is being
              % built from an empty state since the reshape would only
              % occur if time were set before data and not vice-versa.
              if ~isempty(this.Data_) || ~isempty(this.Storage_) || ...
                      this.DataInfo.isstorage
                  input = this.formatData(input);
              end
              this.chkDataProp(input);
          end
          
          % Storage order of precedence:
          % 1. DataInfo storage object gets the first opportunity to
          % store data
          % 2. Storage_ object
          % 3. Cached Data_          
          dataInfo = this.DataInfo;
          if ~isempty(dataInfo) && dataInfo.isstorage
              % setData returns data for internal storage (which may be
              % empty) and a new DataInfo object. The ability to return 
              % both enables the data storage object to either store
              % data itself or give up and just revert to standard
              % memory resident storage in the Data_ property with a 
              % base tsdata.datametadata object.
              [this.Data_,this.DataInfo] = dataInfo.setData(input);
          elseif ~isempty(this.Storage_)
              % setData returns data for internal storage (which may be
              % empty) and a new Storage object (which may be empty).  
              % The ability to return both enables the data storage object 
              % to either store data itself or give up and just revert to 
              % standard memory resident storage in the Data_ property with  
              % an empty Storage_ object.
               [this.Data_,this.Storage_] = this.Storage_.setData(input);
          else
               this.Data_ = input;
          end 

          % isTimeFirst deprecation warning to test if the calculated isTimeFirst
          % value will disagree with the current isTimeFirst value.
          tsdata.datametadata.warnAboutIsTimeFirst(this.isTimeFirst_,size(input),...
              len,dataInfo.InterpretSingleRowDataAs3D);
          
        end   
        
        function outdata = get.Quality(this)
           outdata = this.QualityInfo.getData(this.Quality_);
        end   
        
        function this = set.IsTimeFirst(this,input)
           if ~this.BeingBuilt 
               this.chkIsTimeFirstProp(input);
           end
           this.IsTimeFirst_ = input;
          
        end
        
        function outdata = get.IsTimeFirst(this) 
           outdata = this.IsTimeFirst_;
        end 
        
        function this = set.Quality(this,input)
             if ~this.BeingBuilt
                 input = this.formatQuality(input);
             end
             this.Quality_ = setData(this.QualityInfo,input);
        end    
        function outdata = get.Length(this)
            timeInfo = this.TimeInfo;
            if ~isempty(timeInfo)
                outdata = this.TimeInfo.Length;
            else
                outdata = [];
            end
        end
        function this = set.Length(this,len) %#ok<INUSD>
            error('timeseries:lenro',xlate('The timeseries length depends on the data and time and cannot be assigned.'));
        end
        
        function hasDupTimes = hasduplicatetimes(this)
            hasDupTimes = false;
            if ~isempty(this.TimeInfo)
                % Deal with legacy TimeInfo with no hasDuplicateTimes
                % method
                try
                    hasDupTimes = this.TimeInfo.hasDuplicateTimes;
                catch me
                    if strcmp('MATLAB:noSuchMethodOrField',me.identifier)
                        return;
                    end
                end
            end
        end
        
        function this = timeseries(varargin)
              % Initialize metadata
              
              % Create a tsdata.timemetadata with deprecation warnings for object
              % setting using the create static constructor.       
              this.TimeInfo = tsdata.timemetadata.create;
              
              this.DataInfo = tsdata.datametadata;
              this.QualityInfo = tsdata.qualmetadata;
              this.DataInfo.Interpolation = tsdata.interpolation.createLinear;
              % Empty names timeseries
              if nargin ==1 && isa(varargin{1},'char')
                  this.Name = varargin{1};
                  return
              end
              % Upcast
              if nargin ==1 && isa(varargin{1},'timeseries')
                  if numel(varargin{1})>1
                      error('timeseries:timeseries:noarray',...
                        'The timeseries constructor cannot be called on arrays of timeseries objects');
                  end
                  inObj = varargin{1};
                  this.Name = inObj.Name;
                  this = init(this,inObj.Data,inObj.Time,inObj.Quality);
              elseif nargin ==1 && isa(varargin{1},'tsdata.timeseries')
                  this = varargin{1}.TsValue;
              elseif nargin>0
                  this.Name = 'unnamed';
                  this = init(this,varargin{:});
              end
        end
        
        function iseq = isequal(ts1,ts2)
            if isempty(ts1) || isempty(ts2) || ~isa(ts2,'timeseries') || ...
                    ~isequal(size(ts1),size(ts2))
                iseq = false;
                return
            end
            iseqarray = eq(ts1,ts2);
            iseq = all(iseqarray(:));
        end
    end
    
    
    
    methods (Access = protected)
        
        % Check that Time property is not changing the length of the
        % timeseries.
        function chkTimeProp(this,input)
            isTimeFirst = this.IsTimeFirst;
            % If the data is stored in the timeseries, we only need check
            % that the new time vector does not change the length if it is
            % >0. If the length is zero, the length of the time dimension
            % of the data must match the new time vector.
            if ~isempty(this.Data_)
                len = this.Length;               
                if len>0 && len~=length(input)
                    error('timeseries:subsasgn:arraymismatch',...
                        'Length of time and data do not match');
                elseif len==0 
                    sData = size(this.Data_);
                else % Non empty time which has not changed length
                    return;
                end
            % If the Data is stored in a Storage_ or a DataInfo object, 
            % the size of the data must be compared with the time vector 
            % since the data size may change with time (e.g. for Signal
            % Builder)
            elseif ~isempty(this.Storage_) || this.DataInfo.isstorage
                if ~isempty(this.Storage_) 
                    sData = this.Storage_.getSize(input,this.TimeInfo);
                else
                    sData = this.DataInfo.getSize(input,this.TimeInfo);
                end
            else % No data, build from empty state
                return 
            end
            
            % For cases where data is stored in the timeseries but time
            % had zero length or where data was stored in a storage object
            % test that the length of the time vector matches the data.
            if (isTimeFirst && sData(1)~=length(input)) || ...
               (~isTimeFirst && length(input)>1 && sData(end)~=length(input))    
               error('timeseries:subsasgn:arraymismatch',...
                 'Length of time and data do not match');
            end            
        end
        
        % Check that the dimensions of the Data property are consistent
        % with the Time and IsTimeFirst properties.
        function chkDataProp(this,input)
            len = this.Length;
            s = size(input);
            isTimeFirst = this.IsTimeFirst;
            if (len>=1 && ((isTimeFirst && len~=s(1)) || ...
                         ~isTimeFirst && len>1 && len~=s(end)))
                error('timeseries:arraymismatch',...'
                      'Length of time and data do not match')
            end
        end 
        
        % Check that the IsTimeFirst property is consistent with the Time and
        % Data properties.
        function chkIsTimeFirstProp(this,input)
            s = size(this.Data);
            len = this.Length;
            if ~all(s==0) % Do not warn or error if modifying an empty timeseries
                if ((input && s(1)~=len) || (~input && len>1 && s(end)~=len))
                    error('timeseries:subsasgn:istimefirst',...
                        'Changing the IsTimeFirst property to %d would misalign the Data array with the Time vector',...
                        input);
                end
                % isTimeFirst deprecation warning
                tsdata.datametadata.warnAboutIsTimeFirst(input,size(this.Data),...
                  len,this.DataInfo.InterpretSingleRowDataAs3D);
            end
        end
        
        % Check that the dimensions of the Quality property are consistent
        % with the Time and IsTimeFirst properties.
        function chkQualityProp(this,input)
            timeseries.utCheckQuality(input,this.Data,this.Length,this.isTimeFirst_);  
        end 
        
        % Attempt to reshape the Data to match the Time vector and
        % IsTimeFirst property.
        function data = formatData(this,input)
            data = timeseries.utreshape(this.Length,input,[],this.isTimeFirst_);
        end

        % Attempt to reshape the Quality to match the Time vector and
        % IsTimeFirst property.
        function quality = formatQuality(this,input)
            [~,quality] = timeseries.utreshape(this.Length,this.Data,input,...
                this.isTimeFirst_);  
        end
        
        
    end
    
    methods (Static = true)
        
        function h = loadobj(s)
            
         if isstruct(s)
             if isfield(s,'objH')
                 % <=2006a @timeseries objects always include a wrapped tsata.timeseries in objH
                 % This will have been converted to a valid 2006b tsdata.timeseries obj by 
                 % its loadobj
                 h = s.objH.TsValue;
             else   
                 h = timeseries;
                 classTs = metaclass(h);
                 h.BeingBuilt = true;
                 pNames = fieldnames(s);
                 for k=1:length(pNames)
                     if strcmp(pNames{k},'Time_') 
                        if ~isequal(size(s.Time_),[0 0]);
                            h.TimeInfo.Time_ = s.Time_;
                        end
                     elseif any(cellfun(@(p) strcmpi(p.Name,pNames{k}),classTs.Properties))
                        h.(pNames{k}) = s.(pNames{k});
                     end
                 end
                 
                 % Instance props from 2006a 2006b
                 % Any fieldnames which do not correspond to timeseries
                 % properties (except Grid_,InstancePropValues_,
                 % InstancePropNames are instance properties). Add them as
                 % a struct in the UserData property.
                 cTimeSeries = ?timeseries;
                 instanceProps = setdiff(fields(s),cellfun(@(x) {x.Name},cTimeSeries.Properties));
                 instanceProps = setdiff(instanceProps,{'Grid_','InstancePropValues_',...
                     'InstancePropNames_'});
                 if ~isempty(instanceProps)
                      for k=1:length(instanceProps)
                         h.UserData.(instanceProps{k}) = s.(instanceProps{k});
                      end
                 end 
                 % The fieldnames InstancePropNames_ and
                 % InstancePropValues_ represent 2006a,b instance props.
                 % Add them to the instance props stored in the UserData
                 if isfield(s,'InstancePropNames_') && ~isempty(s.InstancePropNames_)
                     for k=1:min(length(s.InstancePropNames_),length(s.InstancePropValues_))
                         h.UserData.(s.InstancePropNames_{k}) = s.InstancePropValues_{k};
                     end
                 end
                 h.BeingBuilt = false;
             end
         elseif isa(s,'timeseries')
             h = s;
             % The following logic is added to allow timeseries data/time
             % to be modified directly in HDF5 without MATLAB. The idea is
             % to modify the arrays directly and fix the length when the 
             % object is loaded. This was requested by Michael Kositsky.
             if ~isempty(h.TimeInfo) && h.Length == 0 && ...
                     (isempty(h.TimeInfo.Increment_) || ...
                     isnan(h.TimeInfo.Increment_))
                 if ~isequal(size(h.Time_),[0 0]) && isempty(h.TimeInfo.Time_)
                     h.TimeInfo = h.TimeInfo.reset(h.Time_);
                 else
                     h.TimeInfo = h.TimeInfo.reset(h.TimeInfo.Time_);
                 end
             end
             
             % Move time storage to TimeInfo if it was previously stored in
             % the Time_ property
             if ~isempty(h.Time_) 
                 h.TimeInfo = h.TimeInfo.reset(h.Time_);
                 h.Time_ = [];
             end
             
             % isTimeFirst deprecation warning to test if the calculated isTimeFirst
             % value will disagree with the current isTimeFirst value.
             data = h.Data_;
             if ~isempty(data)
                tsdata.datametadata.warnAboutIsTimeFirst(h.isTimeFirst_,size(data),...
                   h.Length,h.DataInfo.InterpretSingleRowDataAs3D);
             end
          
          else 
             h = [];
          end
        end
       
        function time = tsChkTime(time)
            stime = size(time);
            if length(stime)>2 
                error('tsChkTime:manytimedim',...
                    'Time vector cannot have more than 2 dimensions.')
            end
            if max(stime)<1
                error('tsChkTime:shorttime',...
                    'Time vector cannot be empty.')
            end
            if stime(2)>1
                stime = stime(2:-1:1);
                time = reshape(time,stime);
            end
            if stime(2)~=1
                error('tsChkTime:matrixtime',...
                    'Time vector must be a 1xn or nx1 vector.')
            end
            if any(isinf(time)) || any(isnan(time))
                error('tsChkTime:inftime',...
                    'Time vector must contain only finite values.')
            end
            if ~all(isreal(time))
                error('tsChkTime:inftime',...
                    'Time vector must contain only real values.')
            end
        end
        
        function t = tsgetrelativetime(date,dateRef,unit)
            % This method calculates relative time value between date and
            % dateref.
            vecRef = datevec(dateRef);
            vecDate = datevec(date);
            t = (datenum([vecDate(:,1:3) zeros(size(vecDate,1),3)])-datenum([vecRef(1:3) 0 0 0]))*...
                tsunitconv(unit,'days')+ ...
                (vecDate(:,4:6)*[3600 60 1]'-vecRef(:,4:6)*[3600 60 1]')*...
                tsunitconv(unit,'seconds');
        end
    end
    
    methods (Hidden = true)
        % Set method for external assignment of the Data_ property. This
        % method ensures that a non-empty Data_ cannot coexist with a
        % non-empty Storage_ property.
        function this = setData_(this,data)
            if ~isempty(this.Storage_) || (~isempty(this.DataInfo) && ...
                    this.DataInfo.isstorage)
                error('timeseries:storage_data',...
                    'Cannot set internal Data_ storage since a storage object is being used for data storage.');
            end
            this.Data_ = data;
        end
        % Set method for external assignment of the Storage_ property. This
        % method ensures that a non-empty Data_ cannot coexist with a
        % non-empty Storage_ property.
        function this = setStorage_(this,data)
            if ~isempty(this.Data_) || (~isempty(this.DataInfo) && ...
                    this.DataInfo.isstorage)
                error('timeseries:storage_storage',...
                    'Cannot set internal Storage_ since non-empty data is stored in the Data_ property.');
            end
            this.Data_ = data;
        end
        
    end
    
    methods (Static = true, Hidden = true)
        % TO DO Add duplicate time flag to signature and make it a
        % protected prop
        function this = utcreatewithoutcheck(data,time,interpretSingleRowDataAs3D,...
                duplicatedTimes)
            
            % Utility method which may change in a future release.
            % Optional 3rd input argument specifies the dimensions of a
            % single sample.
            
            % Assign the data to data storage props.
            % TO DO: This must change when data storage migrates to
            % metadata.
            this = timeseries;
            this.Data_ = data;
                       
            this.DataInfo.InterpretSingleRowDataAs3D = interpretSingleRowDataAs3D;
            this.IsTimeFirst_ = tsdata.datametadata.isTimeFirst(size(data),...
                length(time),interpretSingleRowDataAs3D);
 
            % Assign the metadata - could we just set props on the existing
            % object                       
            this.TimeInfo = this.TimeInfo.setnonuniformtime(time);
            this.TimeInfo.DuplicateTimes = duplicatedTimes;           
        end

        function this = utcreateuniformwithoutcheck(data,len,starttime,increment,...
                interpretSingleRowDataAs3D,duplicatedTimes)
            % Utility method which may change in a future release.
            
            this = timeseries;
            this.Data_ = data;
            
            % Use the post-2010a logic for assigning IsTimeFirst
            this.DataInfo.InterpretSingleRowDataAs3D = interpretSingleRowDataAs3D;
            this.IsTimeFirst_ = tsdata.datametadata.isTimeFirst(size(data),...
                len,interpretSingleRowDataAs3D);
            
            
            % Assign the metadata 
            timeInfo = tsdata.timemetadata(starttime,len,increment);
            timeInfo.DuplicateTimes = duplicatedTimes;
            this.TimeInfo = timeInfo;
        end 
        
        
        function tsout = utarithcommonoutput(ts1,ts2,tsout,warningFlag) 
            %UTARITHCOMMONOUTPUT
            %

            % Merge qualmetadata properties
            if ~isempty(ts1.qualityInfo) && ~isempty(ts2.qualityInfo)
                tsout.qualityInfo = qualitymerge(ts1.qualityInfo,ts2.qualityInfo);
            end
            % Merge quality values: pick up minimums
            if ~isempty(get(get(tsout,'qualityInfo'),'Code')) && ~isempty(ts1.quality) && ...
                    ~isempty(ts2.quality)
                tsout.Quality = min(ts1.quality,ts2.quality);
            end

            % Merge events
            tsout = addevent(tsout,horzcat(ts1.Events,ts2.Events));

            % issue a warning if offset is used.
            if warningFlag
                warning('timeseries:arith:newtime','The time vector in the new time-series object has been re-generated.')    
            end
        end
         
        function [time,data,quality,I] = utsorttime(time,data,quality,isTimeFirst)

            % timeseries utility function

            % UTSORTTIME Utility to sort time vector 
            %
            % Sort time numeric or cell array datestr data.

            % Return [] if empty
            if isempty(time)
                return
            end
            
            len = length(time);
            if nargin>=2
                sdata = size(data);
                if sdata(1)~=len && sdata(end)~=len && len>1
                    error('tssorttime:datamismatch','Time and data are mismatched.')
                end
            end
            if nargin>=3 && ~isempty(quality)
                squality = size(quality);
                if squality(1)~=len && squality(end)~=len && len>1
                    error('tssorttime:qualmismatch','Time and quality are mismatched.')
                end
            end
            

            % Convert datestr times to numeric vector
            if iscell(time)
                time = datenum(time);
            end

            % Return the same if single 
            if isscalar(time)
                return
            end

            % Sort generate sorting index, sort both time and data
            timeissorted = issorted(time);
            if ~timeissorted
                [time I] = sort(time);
                s = size(data);
                % Rearrange data
                if nargin>=2
                    % If necessary, infer isTimeFirst from the data
                    if nargin<=3
                        if s(1)==len && s(end)~=len
                            isTimeFirst = true;
                        elseif s(1)~=len && s(end)==len
                            isTimeFirst = false;
                        else
                            error('timeseries:initialize:istimefirst',...
                            'Both the first and last dimensions of the data are the same.  Use the ''IsTimeFirst'' property to align the data with the time vector.')
                        end
                    end
                    
                    % Sort data samples
                    if isTimeFirst
                        ind = [{I} repmat({':'}, [1 length(s)-1])];
                    else
                        ind = [repmat({':'}, [1 length(s)-1]) {I}];         
                    end     
                    data = data(ind{:});
                    
                    % Sort quality
                    if nargin>=3 && ~isempty(quality)
                        if isvector(quality)
                            quality = quality(I);
                        else
                            quality = quality(ind{:});
                        end  
                    end
                end
            else
                I = (1:length(time))';
            end

        end


            
      function [data,quality,isTimeFirst] = utreshape(len,data,quality,isTimeFirst)

            % timeseries utility function

            % UTRESHAPE Reshape data and quality to match the timeseries
            % data-time-quality compatibility rules.
             %
            % Sort time numeric or cell array datestr data.

            % NOTE: Successful use of UTRESHAPE to assign the data and
            % quality and istimefirst properties of the timeseries,
            % guarantees a valid timeseries object meeting the following
            % compatibility conditions:
            %  If IsTimeFirst
            %    - First dim of Data must be the same as the length of the
            %      time vector
            %    - If Quality is not empty, size(quality,1) must be the same
            %      as the length of the time vector
            % If ~IsTimeFirst
            %    - Last dim of Data must be the same as the length of the
            %      time vector if the time vector length > 1
            %    - If Quality is not empty, size(quality,end) must be the
            %      same as the length of the time vector if the time vector
            %      length >1
            %  
            % If length(time)==1
            %    - If Quality is not empty, is must be a scalar or match
            %      the data size           
                    
            % Expand scalar data,quality
            s = size(data);
            if prod(s)==1 && len>1 % Cannot use numel because its overloaded by embedded.fi
                data = repmat(data,[len,1]);
                s = size(data);
            end
            if numel(quality)==1 && len>1 
                quality = repmat(quality,[len,1]);
            end
            
            
            % If necessary, infer isTimeFirst from the data            
            if nargin<=3 || isempty(isTimeFirst)
                if length(s)>=3 && s(1)==len && s(end)==len
                    isTimeFirst = false;
                elseif s(1)==len && s(end)~=len
                    isTimeFirst = true;
                elseif s(1)~=len && s(end)==len
                    isTimeFirst = false;
                elseif len==1 
                    isTimeFirst = isequal(s,[1 1]) || isequal(s,[0 0]);
                else
                    warning('timeseries:init:istimefirst',...
                      'Both the first and last dimensions of the data are the same.')
                    isTimeFirst = true;
                end
            end


             
            % If isTimeFirst and quality is a column vector and there is only one sample,
            % transpose it
            if ~isempty(quality) && len==1 && isTimeFirst && ~isscalar(quality) && ...
                    isvector(quality) && size(quality,2)==1
                quality = quality';
            end
            
            % If ~isTimeFirst and there is one sample and data is a row
            % vector then transpose it
            if len==1 && ~isTimeFirst && ~isempty(data) && ~isscalar(quality) && ...
                    isvector(quality) && size(quality,1)==1            
               data = data';
            end
            
            % Append 1s to the size vectors for data and quality in the single sample
            % case to account for timeseries with a single array-valued sample
            size_data = size(data);
            if len==1 && isTimeFirst  && size_data(1)~=1
                % Array-valued data located on a single sample
                data = reshape(data,[1 size_data]); 
                size_data = size(data);
            end

            % If ~isTimeFirst and data is 2-d, move the time dimension from the second
            % to the third position. This ensures that the data dimensions are:
            % sample size -by- time length where sample_size has length at least 2 (as
            % required by MATLAB)
            if ~isTimeFirst && length(size_data)<3 
                if size_data(end)==len
                    data = reshape(data,[size_data(1:end-1) 1 len]);
                elseif size_data(end)==1
                    data = reshape(data,[1 1 len]);
                end
            end
            

            % Check the data and time compatibility
            if (isTimeFirst && len~=size(data,1)) || (~isTimeFirst && len>1 && ...
                    len~=size(data,ndims(data)))
                  error('timeseries:arraymismatch',...
                       'Size of the data array is incompatible with the time vector.');
            end

            % Attempt to align vector quality with data
            if ~isempty(quality) && isvector(quality) && len>1
                  if isTimeFirst
                      quality = quality(:);
                  else
                      quality = reshape(quality,[ones(1,ndims(data)-1) numel(quality)]);
                  end
            end
            
            % Check quality size
            timeseries.utCheckQuality(quality,data,len,isTimeFirst);
            
      end

      function utCheckQuality(quality,data,len,isTimeFirst)
          
            % Check quality size
            if ~isempty(quality)
                squality = size(quality);
                sdata = size(data);
                dataqualmatch = false;
                if len>1
                    if isTimeFirst
                        if (isvector(quality) && len==squality(1))
                            dataqualmatch = true;
                        elseif isequal(sdata,squality)
                            dataqualmatch = true;
                        end
                    else
                        if (all(squality(1:end-1)==1) && len==squality(end))
                            dataqualmatch = true;
                        elseif isequal(sdata,squality)
                            dataqualmatch = true;
                        end
                    end
                elseif len==1 && (isscalar(quality) || isequal(squality,sdata))
                      dataqualmatch = true;
                end
                if ~dataqualmatch
                       error('timeseries:subsasgn:qualitymismatch',...'
                             'Length of time and quality do not match')
                end
            end   
      end

      function this = transposetimedim(this)
            % TRANSPOSETIMEDIM  Return a new time series object in which the isTimeFirst value
            % is changed from TS and the data is permuted accordingly.
            %
            %   Copyright 2005-2010 The MathWorks, Inc.

            if this.Length==0
                return;
            end
            n = ndims(this.Data);
            if this.IsTimeFirst
                perm_data = permute(this.Data,[2:n 1]);
                % If the data is a single row and isTimeFirst is false, set
                % the InterpretSingleRowDataAs3D flag so as not to get a
                % discrepancy with the future calculated isTimeFirst value.
                if this.Length==1 && isvector(perm_data)
                    this = init(this,perm_data, this.Time, ...
                        permute(this.Quality,[2:n 1]), 'IsTimeFirst',~this.IsTimeFirst,...
                        'InterpretSingleRowDataAs3D',true);
                else
                    this = init(this, permute(this.Data,[2:n 1]), this.Time, ...
                        permute(this.Quality,[2:n 1]), 'IsTimeFirst',~this.IsTimeFirst);
                end
            else
                this = init(this, permute(this.data,[n 1:n-1]), this.Time,...
                    permute(this.Quality,[n 1:n-1]), 'IsTimeFirst',~this.IsTimeFirst);
            end
      end
      
      function t = createSeed(arg1)
            % Utility method which may change in a future release.
            
            % This static method is used by incremental Simulink logging to
            % create a seed timeseries for file logging.
            
            % Dummy data and time are chosen to have recognizable values
            % for debugging.
            DUMMY_TIME = [0.32, 1.32, 4.32, 6.32, 13.32, 17.32, 22.32]';

            fiVals = [];
            enumVals = [];
            if nargin >= 1 && ~isempty(arg1)
                if strcmp(arg1, 'fi()')
                    fiVals = fi(DUMMY_TIME, 1, 29, 0.005, -3.17);
                else
                    enumVals = enumeration(arg1);
                end
            end
            
            if ~isempty(enumVals)
                enumVals = unique(enumVals);
                % If there are less enumVals than the length of the
                % DUMMY_TIME array, pad the data with the first enumerated 
                % value
                
                if length(enumVals)<=length(DUMMY_TIME)
                   data = [enumVals;repmat(enumVals(1),[length(DUMMY_TIME)-length(enumVals) 1])];
                   time = DUMMY_TIME;
                % If there are more enumVals than the length of the
                % DUMMY_TIME array, pad with the time with uniform values.
                else
                   data = enumVals;
                   time = [DUMMY_TIME;DUMMY_TIME(end)+(1:(length(enumVals)-length(DUMMY_TIME)))'];
                end
                data = reshape(data,[1 length(time)]);
            elseif ~isempty(fiVals)
                time = DUMMY_TIME;
                data = reshape(repmat(fiVals, [1 2]), [2 1 length(time)]);  
            else
                time = DUMMY_TIME;
                data = reshape(ones(length(DUMMY_TIME),2)*219.61,[2 1 length(time)]);  
            end
            
            % Create timeseries which uses a StreamingStorage object for
            % data storage 
            t = timeseries;
            t.Name = 'xxx';
            t.IsTimeFirst_ = false;
            t.DataInfo.InterpretSingleRowDataAs3D = true;
            t.Storage_ = tsdata.StreamingStorage(data);
            t.Time = time;
            % TO DO: Revisit with M.K whether this can be removed
            t.TimeInfo = t.TimeInfo.setlength(0);
        end

end
    
end