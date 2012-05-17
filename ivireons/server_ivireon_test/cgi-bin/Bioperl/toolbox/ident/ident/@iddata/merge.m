function dat = merge(dat1,varargin)
%MERGE Merging two IDDATA data sets
%
%   DAT = MERGE(DAT1,DAT2,DAT3,...)
%   creates a multiple experiments data set the sets can be
%   used to fit models to separate and non-continuous data records.
%
%   Separate experiments are retrieved by the command GETEXP or by
%   subreferencing with a fourth index:
%   DAT2 = DAT(:,:,:,2) or DAT2 = DAT(:,:,:,'Day4'), where 'Day4' is the name of the
%   second experiment.
%
%   See also GETEXP, IDDATA/SUBSREF.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.13.4.8 $  $Date: 2010/03/22 03:48:44 $

dat = dat1;
for ka = 1:length(varargin)
    dat2 = varargin{ka};
    if ~isa(dat1,'iddata') || ~isa(dat2,'iddata')
        ctrlMsgUtils.error('Ident:dataprocess:mergeDataType')
    end
    if ~strcmpi(dat1.Domain,dat2.Domain)
        ctrlMsgUtils.error('Ident:dataprocess:mergeDataDomain')
    end
    y = [dat1.OutputData,dat2.OutputData];
    u = [dat1.InputData,dat2.InputData];
    yna1 = dat1.OutputName;
    yna2 = dat2.OutputName;
    una1 = dat1.InputName;
    una2 = dat2.InputName;
    yu1 = dat1.OutputUnit;
    yu2 = dat2.OutputUnit;
    uu1 = dat1.InputUnit;
    uu2 = dat2.InputUnit;
    tu1 = dat1.TimeUnit;
    tu2 = dat2.TimeUnit;
    if isempty(tu2),dat2.TimeUnit = tu1; tu2=tu1;end
    if isempty(tu1),dat1.TimeUnit = tu2; tu1=tu2;end
    if length(yna1)~=length(yna2)
        ctrlMsgUtils.error('Ident:dataprocess:mergeNy','IDDATA')
    end
    if length(una1)~=length(una2)
        ctrlMsgUtils.error('Ident:dataprocess:mergeNu','IDDATA')
    end
    if ~strcmp(tu1,tu2)
        ctrlMsgUtils.error('Ident:dataprocess:mergePropConflict','IDDATA','TimeUnit')
    end
    for ku = 1:length(yna1)
        if ~strcmp(yna1{ku},yna2{ku})
            ctrlMsgUtils.error('Ident:dataprocess:mergePropConflict','IDDATA','OutputName')
        end
        if ~strcmp(yu1{ku},yu2{ku})
            ctrlMsgUtils.error('Ident:dataprocess:mergePropConflict','IDDATA','OutputUnit')
        end
    end
    for ku = 1:length(una1)
        if ~strcmp(una1{ku},una2{ku})
            ctrlMsgUtils.error('Ident:dataprocess:mergePropConflict','IDDATA','InputName')
        end
        if ~strcmp(uu1{ku},uu2{ku})
            ctrlMsgUtils.error('Ident:dataprocess:mergePropConflict','IDDATA','InputUnit')
        end
    end

    ts = [dat1.Ts,dat2.Ts];
    if lower(dat1.Domain(1))=='f'
        if ~strcmp(dat1.Tstart,dat2.Tstart)
            ctrlMsgUtils.error('Ident:dataprocess:mergePropConflict','IDDATA','Unit')
        end
    end
    tstart = [dat1.Tstart,dat2.Tstart];
    sa = [dat1.SamplingInstants, dat2.SamplingInstants];
    %dat = dat1;
    try
        dat=pvset(dat1,'OutputData',y,'InputData',u,'Ts',ts,...
            'SamplingInstants',sa,'Period',[dat1.Period, dat2.Period]);
        dat.Tstart = tstart;
        if ~isempty(una1)
            dat=pvset(dat,'InterSample',[dat1.InterSample,dat2.InterSample]);
        end
    catch E
        throw(E)
    end

    if ~strcmp(dat2.ExperimentName{1},'Exp1')
        dat=pvset(dat,'ExperimentName',[dat1.ExperimentName;dat2.ExperimentName]);
    end
    dat1 = dat;
end
