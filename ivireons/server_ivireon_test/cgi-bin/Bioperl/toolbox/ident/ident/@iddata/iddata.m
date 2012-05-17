function dat = iddata(varargin)
% IDDATA Create a data object to encapsulate the input/output data and
% their properties.
%
%    Basic Use:
%    DAT = IDDATA(Y,U,Ts) to create a data object with output Y and
%       input U and sampling interval Ts. Default Ts = 1. 
%       Y: a N-by-Ny matrix where N is the number of observations and Ny
%          the number of output channels.
%       U: a N-by-Nu matrix, where Nu is the number of input channels.
%       Y and U must have the same number of rows. However:
%       If U = [], or not assigned, DAT defines a signal or a time series.
%       If Y =[], DAT describes just the input.
%
%       For Frequency Domain Data use: DAT = IDDATA(Y,U,Ts,'FREQ',Freqs),
%       where Freqs is a column vector containing the frequencies. It is
%       of the same length as Y and U. Note that Ts may be equal to 0 for
%       frequency domain data, to indicate continuous time data. 
%
%    Retrieving Signals and Selecting Samples from IDDATA:
%       Retrieve data by DAT.y, DAT.u and DAT.Ts
%       Select portions by DAT1 = DAT(1:300) etc.
%
%    Using property-value pairs to specify data characteristics:
%    DAT = IDDATA(Y,U,Ts,'OutputName',String,....) 
%    SET(DAT,'OutputName',String,....) to 
%       add/modify properties of the data object, for logistics and
%       plotting. Type SET(IDDATA) for a complete list of properties (also
%       see IDPROPS IDDATA). Some basic ones are: 
%       OutputData, InputData: refers to Y and U above.
%       OutputName: String. For multi-output, use cell arrays, e.g. {'Speed','Voltage'} 
%       OutputUnit: String. For multi-output, use cell arrays, e.g. {'mph','volt'}
%       InputName, InputUnit, analogously.
%       Tstart: Starting time for the samples.
%       TimeUnit: String.
%
%       Properties can be set and retrieved either by SET and GET or by
%       subfields: 
%       GET(DAT,'OutputName') or DAT.OutputName
%       SET(DAT,'OutputName','Current') or DAT.OutputName = {'Current'};
%
%       Referencing is case insensitive and 'y' is synonymous to 'Output'
%       and 'u' is synonymous to 'Input'. Autofill is used as 
%       soon as the property is unique, so DAT.yna is the same as
%       DAT.OutputName etc. 
%
%       For frequency domain data, the property Frequency contains the
%       frequency vector and the property Unit defines the frequency unit.
%
%       To assign names and units to specific channels use
%       DAT.un(3)={'Speed'} or DAT.uu([3 7])={'Volt','m^3/s'}
%       See IDPROPS IDDATA for a complete list of properties.
%
%    Manipulating channels:
%       An easy way to set and retrieve channel properties is to use
%       subscripting. The subscripts are defined as:
%       DAT(SAMPLES,OUTPUTS,INPUTS), so that DAT(:,3,:) is the data object
%       obtained from DAT by keeping all input channels, but only output
%       channel 3. (Trailing ':'s can be omitted so DAT(:,3,:)=DAT(:,3).)
%       The channels can also be retrieved by their names,so that
%       DAT(:,{'speed','flow'},[]) is the data object where the
%       indicated output channels have been selected and no input
%       channels are selected. Moreover DAT1(101:200,[3 4],[1 3]) =
%       DAT2(1001:1100,[1 2],[6 7]) will change samples 101 to 200 of
%       output channels 3 and 4 and input channels 1 and 3 in the iddata
%       object DAT1 to the indicated values from iddata object DAT2. The
%       names and units of these channels will the also be changed
%       accordingly. 
%
%       To add new channels, use horizontal concatenation of IDDATA objects: 
%       DAT = [DAT1, DAT2];
%       or add the data record directly:  
%       DAT.u(:,5) = U will add a fifth input to DAT. 
%
%    Non-equal sampling:
%       The property 'SamplingInstants' gives the sampling instants of the
%       data points. It can always be retrieved by 
%       GET(DAT,'SamplingInstants') and is then computed from
%       DAT.Ts and DAT.Tstart. 'SamplingInstants' can also be set to an
%       arbitrary vector of the same length as the data, so that non-equal
%       sampling can be handled. Ts is then automatically set to []. 
%
%    Handling multiple experiments:
%       The IDDATA object can also store data from separate experiments.
%       The property 'ExperimentName' is used to separate the experiments.
%       The number of data as well as the sampling properties can vary from
%       experiment to experiment, but the number of input and output
%       channels must be the same. Use NaN to fill unmeasured channels in
%       certain experiments. The data records will be cell arrays, where
%       the cells contain data from each experiment. 
%
%       Multiple experiments can be defined directly by letting the 'y'
%       and 'u' properties as well as 'Ts' and 'Tstart' be cell arrays.
%       However, it is easier to create them by merging single-experiment
%       data sets: DAT = MERGE(DAT1,DAT2). (See HELP IDDATA/MERGE) 
%
%       Particular experiments can be retrieved by the command GETEXP: 
%       For example, GETEXP(DAT,3) is experiment number 3 and
%       GETEXP(DAT,{'Day1','Day4'}) retrieves the two experiments with the  
%       indicated names.
%
%       Particular experiments can also be addressed by a fourth index to
%       DAT as in: DAT1 = DAT(Samples,Outputs,Inputs,Experiments)
%
%   IDDATA objects provide a standard way of managing data in System
%   Identification Toolbox. These objects can be used for processing data
%   (filtering, detrending etc), viewing and transforming (plotting,
%   computing FFT etc) and for identification purposes (estimation of
%   models, validation of results etc). 
%
%  See also MERGE, IDDATA/FFT, IDDATA/IFFT, IDDATA/DETREND, IDFRD.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.20.4.15 $  $Date: 2009/04/21 03:22:09 $

ni = nargin;
if ni && isempty(varargin{1}) % To allow for u = iddata([],u), u iddata
    if ni==2 && isa(varargin{2},'iddata')
        if size(varargin{2},'ny')==0
            dat = varargin{2};
            return
        end
    end
end

if ni && isa(varargin{1},'iddata')
    % Quick exit
    if ni==2 % forgiving syntax  dat = iddata(y,u) with y and u
        %iddata objects will be allowed.
        if isa(varargin{2},'iddata')
            if size(varargin{1},'nu')==0 && size(varargin{2},'ny')==0
                dat = horzcat(varargin{1},varargin{2});
                return
            end
        end
    else
        dat = varargin{1};
        if ni>1,
            ctrlMsgUtils.error('Ident:general:useSetForProp','IDDATA');
        end
        return
    end
end

dat = ...
    struct('Domain','Time','Name','',...
    'OutputData',{{[]}},'OutputName',{{}},'OutputUnit',{{}},...
    'InputData',{{[]}},'InputName',{{}},'InputUnit',{{}},...
    'Period',[],'InterSample',{''},...
    'Ts',{{1}},'Tstart',{{[]}},'SamplingInstants',{{[]}},'TimeUnit',{''},...
    'ExperimentName',{{}},'Notes',{{}},'UserData',[],...
    'Version',idutils.ver,'Utility',[]);

% Note: version was string '1.0' before R2008a and '0.1' in first version (R13?)

% Dissect input list
DoubleInputs = 0;
PVstart = 0;
while DoubleInputs < ni && PVstart==0,
    nextarg = varargin{DoubleInputs+1};
    if ischar(nextarg) || (~isempty(nextarg) && iscellstr(nextarg))
        PVstart = DoubleInputs+1;
    else
        DoubleInputs = DoubleInputs+1;
    end
end

% Process numerical data
if DoubleInputs > 0
    % Output only
    [Value,error_struct] = datachk(varargin{1},'OutputData');
    error(error_struct)
    dat.OutputData=Value; y = Value;
    varargin = varargin(2:end);
    if DoubleInputs > 1
        [Value,error_struct] = datachk(varargin{1},'InputData');
        error(error_struct)
        dat.InputData = Value;
        varargin = varargin(2:end);
        if DoubleInputs > 2
            Value = varargin{1};
            if ~iscell(Value), Value = {Value}; end
            dat.Ts = Value;
            varargin = varargin(2:end);
        end
    end
else
    y = [];
end

dat = class(dat,'iddata');

% Finally, set any PV pairs
if isempty(varargin)
    was = warning('off','Ident:iddata:MoreOutputsThanSamples');
    try
        dat = pvset(dat,'OutputData',y); % This is to force the consistency checks
        warning(was)
    catch E
        warning(was)
        throw(E)
    end
end

if ni && ~isempty(varargin)
    try
        set(dat,'OutputData',y,varargin{:})
    catch E
        throw(E)
    end
end
if strcmp(dat.Domain,'Frequency') && isempty(dat.Tstart{1})
    dat.Tstart =repmat({'rad/s'},1,size(dat.SamplingInstants,2));
end

Ts = dat.Ts;
%if ~iscell(Ts),Ts={Ts};end
if strcmp(dat.Domain,'Time')
    % time domain
    idutils.utValidateTs(Ts,true,true);
else
    % frequency domain
    idutils.utValidateTs(Ts,true,false);
end

dat = timemark(dat,'c');