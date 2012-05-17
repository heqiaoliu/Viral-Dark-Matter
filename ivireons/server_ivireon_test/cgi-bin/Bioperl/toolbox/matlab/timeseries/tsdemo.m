%% Demo: Using Time-Series Objects in MATLAB
% This example demonstrates new MATLAB features, which enable users to
% work with time series data.
%
% Time series data is any data that varies as a function of time, such as
% an audio signal from a microphone, the daily temperature of a city, the
% hourly price of a stock, or a moving video image. This data could come
% from and external instrument, data files such as Excel, ASCII, custom
% binary or multi-media, or from a database.  
%
% The new MATLAB time series features are provided by two new objects,
% associated functions and a graphics user interface (GUI). The following
% demonstration provides an overview of what you can do with time series
% data in MATLAB.
 
% Copyright 2005-2006 The MathWorks, Inc.  
% $Revision: 1.1.6.4 $  $Date: 2006/12/20 07:18:30 $   

%% Creating a time series object
% A time series object is a variable that stores data, time, events, and
% meta data (for example, units). Storing this information in a single
% object makes it more convenient for you to manipulate the data from the
% MATLAB Command Window, as well as to transfer the data between MATLAB
% functions.      
%
%
% To create a time series object containing five data values of a single
% quantity that varies randomly with time, enter  
ts1 = timeseries(rand(5,1)); 
%
% This creates a new object of class |timeseries|. The default time
% vector starts at 0 and is increased in increments of 1 sec.

%%
% You can display the contents of the time series object including the data
% and times, by typing its name: 
ts1

%%
% To assign a name to the time series object, enter the name string in the
% argument as follows:  
ts1 = timeseries(rand(10,1),'name','Sensor773') 

%%
% The time series object can store multivariate data. For example signals
% from an antenna array with five sensors would be an example of
% two-dimensional data varying with time. To specify a time series object
% with five hypothetical signals from a 5-sensor antenna array, enter:
ts2 = timeseries(rand(10,5),'name','ts2')

%%
% In this case, because a time vector is not specified, the first data
% dimension is assumed to be the one varying with time. A video signal
% would be an example of two dimensional data varying with time. A 5x4
% matrix varying with time could be created in the following way:
ts2 = timeseries(rand(10,5,4),'name','ts2')

%%
% Typically, you specify the times corresponding to the data when you
% create the time series object. The times can be specified either as a
% vector of  time values in seconds (called a relative time vector), or as
% a cell array of date time strings (called an absolute time vector). To
% specify a relative time vector, enter:     
time = 1:10; % Vector of relative times in seconds
ts3 = timeseries(rand(10,2,3),time,'name','ts3') %  10 samples of 2x3 array 

%%
% The time vector need not be monotonically increasing. When you create a
% time series object, the samples are sorted by increasing time values. for
% example: 
data = .1: .1: .5;
time =  5: -1:  1;
ts3 = timeseries(data,time,'name','ts3')

%%
% In some cases, you may want to associate other than the first dimension
% of the data array with the time vector. You can do that by specifying the
% time vector when creating the time series object. Then, the size of 
% the first and last data dimension is compared to the length of the time
% vector. In the following example:    
ts3 = timeseries(rand(2,3,10),1:10) % Data is varying by its 3rd dimension

%%
% the length of the time vector is 10, which matches the length of the last
% data dimension. This feature prevents you from having to transpose your
% data, which can be costly with a large data set.  
%
% You can specify an absolute time vector by providing a cell array of date
% strings, or specify a uniformly sampled absolute time vector by using the
% |tsdateinterval| function. For example:
%
% Create a cell array of 10 dates starting today
dates = tsdateinterval(datestr(now),10,'days');   
%
% Then create the object
ts4 = timeseries(rand(10,1),dates,'name','ts4')

%% Indexing, assignment and concatenation of time series objects
% You can index into and assign values to specific time series fields. For
% example, first create two time series objects, where each objects
% contains 10 absolute-time daily values of 5 random quantities:   
ts4 = timeseries(rand(10,5),tsdateinterval(datestr(now),10,'days'),'name','ts4');
ts5 = timeseries(rand(10,5),tsdateinterval(datestr(now+100),10,'days'),'name','ts5');
%
%
% To create a new time series object based on the first three samples of
% ts4, enter:
ts = ts4(1:3) 
%
% This creates a new time series comprised of the first three samples of
% |ts4| with the corresponding times. You do not have to carry out an
% indexing operation on a separate time vector as you would do if you were
% using just numerical arrays of the data and time. 
%
% Note: For time series objects, you can only index into the time
% dimension. Therefore, only 1-D indexing is supported. You cannot use the
% 1-D indexing to set new values on the time series object ?for example,
% ts4(1)=0 returns an error.

%%
% Vertical concatenation combines time series objects along the time
% dimension. This operation creates a new time series object containing
% samples from all the time series objects in the expression. The sample
% sizes (the dimension of the data) must be the same and the time intervals
% of the time series objects must be sorted in strictly ascending order
% with no overlapping. 
ts = [ts4; ts5]   

%% Viewing time series object properties
% The information in the time series object, including the data and the
% time, is stored as properties of the object. You use the |get| command to
% view the properties. 
get(ts4)

%%
% You can access object properties similar to the way you access structure
% fields.
ts4.Data  % Display data values

%%
ts4.Time   % Always displays the time values in relative format

%%
% When you access specific fields in a time series object, you can assign
% new time and data values. The following example illustrates how to set
% the value of the second data sample to 55, and shift the time of the
% fourth data sample by 100 seconds:    
ts4.data(2) = 55;                                  
ts4.time(4) = ts4.time(4)+0.5; 

%% Working with DataInfo properties
% Some time series object properties are metadata, or information about the
% data itself. To view the information stored in the DataInfo field, enter:
get(ts4.DataInfo)

%%
% DataInfo properties consist of unit information (in Units), the data
% dimension that is varying with time (in GridFirst), and the interpolation
% method used when data interpolation is performed (in Interpolation).  
%
% You can change the meta data information, for example, to change the
% units and interpolation method:  
ts1 = timeseries(rand(10,1),'name','ts1'); % Create a timeseries object
ts1.DataInfo.Units = 'mph';  % Set data units property                          
ts1 = setinterpmethod(ts1,'zoh');   % Change interpolation property                   
ts1.DataInfo.get % Display all the datainfo properties
ts1.DataInfo.Interpolation.get % Display interpolation information

%% Working with TimeInfo properties
% Time meta data is stored in the TimeInfo field. You can change some of
% the TimeInfo properties. First create a time series object with 10 random
% daily values, starting at '01-Jan-2000 00:00:00'. 
ts4 = timeseries(rand(10,1),tsdateinterval('01-Jan-2000 00:00:00',10,'days'),'name','ts4');
%
% To view the TimeInfo properties, use |get|. For example:
get(ts4.TimeInfo)                                  

%%
% You can also view a summary of the most important ones when you display
% the time series object.
ts4
%
% Note that the start date does not have to be the same as the first
% sample' time.

%%
% Properties include the time units in |Units|, the data dimension varying
% with time |GridFirst|, the time of the first sample, |Start|, relative to
% the |Startdate|, which is the absolute reference time of the data. |End|
% is the time of the last sample relative to |Startdate|. The sample period
% is stored in |Increment| (for non-uniformly sample data it shows NaN),
% the number of samples is in |Length|. 
%
% To save memory, when you create a time series object with absolute times,
% the times are stored as relative values to the start date.    
ts4.TimeInfo.StartDate

%%
% Assume that we want to shift the data in time so that it starts on
% '24-Feb-2005 12:15:00' with 1 minute interval and we want the reference
% date to be '24-Feb-2005 12:00:00', enter: 
ts4.TimeInfo.Startdate = '24-Feb-2005 12:00:00'; % Move the reference date
ts4.TimeInfo.Start = 15; % Move time relative to the reference date 
ts4.TimeInfo.Units = 'minutes'; % Change interval units from days to mins                       
ts4.TimeInfo.Increment = 10;  % Make interval from 1 mins to 10 mins                       
ts4.TimeInfo.Format = 'yyyy-mm-dd HH:MM:SS'; % Change the format of display            

%%
% Display the time series object again:
ts4
%
% Note: |End| and |Length| are always read-only.

%% Working with QualityInfo properties
% You can specify the quality of individual data points. This enables you
% to, for example, tag values as 'good' or 'bad. You can have up to 255 
% different quality codes. Codes are used instead of text strings to save
% memory.
ts1 = timeseries(rand(10,1),'name','ts1'); % Create time series object
ts1.QualityInfo.get  % Display all the qualityinfo properties                               

%%
% You specify quality codes and corresponding descriptions in the following
% way:
ts1.QualityInfo.Code = [1 2 3]; % Specify three codes                      
ts1.QualityInfo.Description = {'good','bad','ugly'}; % Describe each one
%
% To set the quality codes for a time series, enter:
ts1.Quality = [1 2 3 2 1 2 3 2 1 2];
%
% Here, the first sample has the quality of 'good', which corresponds to
% the code 1

%% Performing arithmetic operations on time series objects
% You can perform standard arithmetic operations, such as addition,
% subtraction, array multiplication, matrix multiplication, right-array
% divide, and right-matrix divide. For example:
ts1 = timeseries(rand(10,1),'name','ts1');
ts1.TimeInfo.Units = 'days';
ts2 = timeseries(rand(10,1),(21:30),'name','ts2');
ts2.TimeInfo.Units = 'days';
ts3 = timeseries(rand(10,1),tsdateinterval(datestr(now),10,'days'),'name','ts3');
ts4 = timeseries(rand(10,4,5),'name','ts4');
ts4.TimeInfo.Units = 'days';
timestr=tsdateinterval(datestr(now),10,'days');
ts5 = timeseries(rand(10,5,4),timestr,'name','ts5');
ts6 = timeseries(rand(10,4,5),timestr,'name','ts6');

%% 
% You can add a scalar value to a time series:
ts = ts1+2                                           

%%
% You can add two time series that have the same dimensions:
ts = ts1+ts2                                          

%%
% You perform element-wise multiplication or division of time series. For
% example: 
ts = ts3.*ts1     

%%
% You can perform matrix multiplication on the data in two time series at
% each time instance. The inner dimension of the data at a time instant
% must be the same.
ts = ts5*ts6                                         

%%
% You can also perform right matrix division at each time instant.
ts = ts4/ts6                                        

%% Adding and deleting samples
% You can add a single sample to an existing time series object with the
% |addsample| command. For example:
ts1 = timeseries(rand(10,1),'name','ts1'); % Create time series
ts1 = addsample(ts1,'Data',.5,'Time',10)

%%
% You can delete samples based on time indices or based on time values: 
ts1 = delsample(ts1,'Index',[2 6 8]); % Delete samples 2, 6 and 8
ts1 = delsample(ts1,'Value',[2 3])  % Delete samples at time = 2 & 3

%% Synchronizing and resampling time series objects
% You can resample time series objects onto a common time vector with the
% synchronize function. For example, create two time series with random
% daily values sampled on five different days:  
ts1 = timeseries(randn(5,1),[2 3 4 5 10],'name','ts1');
ts1.timeInfo.units = 'days';
ts2 = timeseries(randn(5,1),[0 4 5 7 9],'name','ts2');
ts2.timeInfo.units = 'days';
% There are two options for creating a common time vector for synchronizing
% the time series: 
%   By taking the union of the individual time vectors 
%   By taking the intersection of the individual time vectors 

%%
% You can create a common time vector by taking the union of the overlapped
% time values in ts1 and ts2. Then, you create two new time series objects
% that are resampled on this common time vector. The new time series
% objects are not evaluated at the end points, since this requires
% extrapolating at least one of the times series outside its defined range.
% The default interpolation method is used to calculate values at each
% sampling time. For example:
[ts3,ts4] = synchronize(ts1,ts2,'union'); 
ts3 % Display ts3

%%
ts4 % Display ts4

%%
% You can create a common time vector by taking the intersection of the
% time values in ts1 and ts2. Then, you create two new time series objects
% that include only the data values on this common time vector. No
% interpolation is performed in this case. For example:    
[ts3,ts4] = synchronize(ts1,ts2,'intersection');
ts3 % Display ts3

%%
ts4 % Display ts4

%%
% You can create two new time series objects, which are synchronized on a
% common uniform time vector. The default interpolation method is used to
% calculate values at each sampling time. For example, to sample at a
% uniform period of 2.0 seconds: 
[ts3,ts4] = synchronize(ts1,ts2,'uniform','interval',2.0);    
ts3 % Display ts3

%%
ts4 % Display ts4

%%
% You can create a new time series object by resampling the original
% time series object on a new time vector. The default interpolation method
% is used to interpolate values at each sampling time. You can specify a
% scalar sample period, or a vector of non-uniformly spaced instants:    
ts1 = resample(ts1,3:.1:4)
%
% Note that time instances outside the input time series defined range are
% set to NaN as the data is not extrapolated.

%% Detrending and filtering time series
% You can remove a linear trend or an offset from data by using the
% |detrend| function. To illustrate this, create a time series containing
% data that has a known trend (ramp) and an offset.
ts1 = timeseries(randn(1000,1)*10+((1:1000)')/20+500,'name','ts1');
plot(ts1.data) % Plot original data
grid

%%
ts = detrend(ts1,'constant');
plot(ts.data)  % New data without offset
%
% Now the data has a zero mean.

%%
ts = detrend(ts1,'linear');
plot(ts.data)  % New data without linear trend (and offset)
%
% Now the data has no trend.

%%
% You can filter time series data using the |idealfilter| function. You
% specify the frequency range to pass a vector of normalized start and end
% frequencies (normalized to the sample rate). This performs an FFT,
% filters in the frequency domain, and then performs the IFFT. 
ts = idealfilter(ts1,[0 0.1],'pass'); 
plot(ts.data)

%% Getting and setting absolute time
% You can set the absolute times with the setabstime function.
ts1 = timeseries(rand(10,1),'name','ts1');
ts1.TimeInfo.get

%%
% To replace the time vector with an absolute one, use the |setabstime|
% function.
ts1 = setabstime(ts1,datestr(now+1:now+10));
ts1.TimeInfo.get

%%
% You can also extract the absolute times as strings.
time = getabstime(ts1)

%% Working with events
% You can use events to mark significant times in a time series. Event
% information is stored in tsdata.event object. To create an event at 2
% seconds: 
ts1 = timeseries(rand(2,10),(1:10),'name','ts1'); % Create time series
e1 = tsdata.event('Launch',2);   % Create event object    

%%
% You can provide the details of event in the EventData field of the
% tsdata.event object:
e1.EventData = struct('object','shuttle','status','ok');
get(e1)

%%
% Then, you can assign the tsdata.event object to a specific time in the
% time series by using the addevent command: 
ts1 = addevent(ts1,e1);                                   
ts1.events(1).eventdata % Display event information

%% Creating a time series collection object
% Times series collection objects, |tscollection|, contain multiple
% time series, This enables you to simultaneously manipulate and pass to
% functions several time series. All time series in the collection must
% have the same time vector and, hence, the same length.
%
% Create the following time series:
ts1=timeseries(rand(10,2),0:9,'name','ts1');
ts1.timeInfo.units = 'days';
ts2=timeseries(rand(10,2),0:9,'name','ts2');
ts2.timeInfo.units = 'days';
ts3=timeseries(rand(10,2),10:19,'name','ts3');
ts3.timeInfo.units = 'days';
dates=tsdateinterval(datestr(now),10,'days');
ts4=timeseries(rand(10,2),dates,'name','ts4');

%%
% You can create a tscollection object based either on an existing
% time series object 
tscoll1 = tscollection(ts4,'name','tscoll1') 

%%
% or based on a relative or absolute time vector.
tscoll2 = tscollection(0:9,'name','tscoll2');
tscoll2.timeInfo.units = 'days';
tscoll3 = tscollection(tsdateinterval(datestr(now+20),10,'days'),'name','tscoll3')

%%
% Then you use the |addts| and |removets| functions to populate it with
% time series objects.
tscoll2 = addts(tscoll2,ts1,'ts1'); % Add time series one
tscoll2 = addts(tscoll2,ts2,'ts2'); % Add time series two
tscoll2 = addts(tscoll2,rand(10,2),'ts3',ts2.TimeInfo);
tscoll2 = removets(tscoll2,'ts1'); % Remove time series one
tscoll3 = addts(tscoll3,rand(10,2),'ts4');

%%
% Display the contents of a collection by typing its name.
tscoll2

%% Indexing, assignment and concatenation of time series collection objects
% You can select specific time series from a time series collection by
% using a numerical index. For example, you can extract the first
% time series by using:    
tscoll = tscoll2(:,1)

%%
% You can also access a time series object by its name:
tscoll = tscoll2(6:8,'ts3') 

%%
% You can access the time series object by the property name also.
ts = tscoll.ts3 

%%
% You can get the same samples from all time series objects. For example,
% to get samples 1-5 in all the time series objects you would use:
tscoll = tscoll2(1:5,:)    

%%
% To get samples 6-8 in the first 2 time series use:
tscoll = tscoll2(6:8,1:2)     

%%
% You can also replace individual time series in this way:
tscoll.ts2 = ts1(6:8);       

%%
% Horizontal concatenation of multiple the times collections combines them
% into one time series collection. 
tsc = [tscoll1 tscoll2]

%%
% Vertical concatenation of multiple time series collections combines them
% along the time dimension, similar to thee time series object
% concatenation.
tsc = [tscoll1; tscoll3]

%% Other time series collection operations
% You can change the common time vector of all time series objects in the
% collection. For example: 
tscoll.time = 2:4;

%%
% You can change the |TimeInfo| properties of the common time vector.
tscoll.TimeInfo.units = 'minutes';

%%
% You can change the data inside a time series object.
tscoll.ts3.data(1,:) = rand(1,2);

%%
% You can get properties in the individual time series objects.
tscoll.ts3.time         

%% Get and set the names of the time series objects in the collection
% To list all the names of the time series in a collection use:
gettimeseriesnames(tscoll2)

%%
% To change the name of 'ts2' to 'newname' use:
tscoll2 = settimeseriesnames(tscoll2,'ts2','newname')

%%
% Refer to the time series documentation for information on the tasks
% you can perform with the time series gui: tstool. 

