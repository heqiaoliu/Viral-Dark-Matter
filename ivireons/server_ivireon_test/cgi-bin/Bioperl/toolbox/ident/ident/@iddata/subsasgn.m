function sys = subsasgn(sys,Struct,rhs)
%SUBSASGN  Subscripted assignment for IDDATA objects.
%
%   The following assignment operations can be applied to any
%   IDDATA set DAT:
%     DAT(Samples,Outputs,Inputs,Experiments)=RHS  reassigns a subset
%         of the data channels
%     Arguments can be omitted to mean ':', so DAT(:,3)=DAT(:,3,:)
%     DAT.Fieldname=RHS  is equivalent to SET(DAT,'Fieldname',RHS)
%   The left-hand-side expressions themselves can be followed by any
%   valid subscripted reference, as in DAT(:,:,3).inputname='u' or
%   DAT(11:20,2).y=[1:10]'.
%
%   A new experiment to be merged with old ones is obtained by
%   DAT{:,:,:,expno) = DAT2;
%
%   Samples, channels, and experiments will be overwritten if the
%   indicated indices correspond to existing data, otherwise new
%   samples/channels/experiments will be added.
%
%   The numbers in the arguments OUTPUT, INPUT, and EXPERIMENT
%   can be replaced by the curresponding names, like
%   DAT(1:59,'Speed',{'Current','Feed'},'Day5').
%
%   The syntax
%   DAT(Samp,Outp,Inp,Exp) = []
%   has a special interpretation: The indicated Experiments, Samples,
%   output and input channels will be deleted. That is, the complements
%   of the indicated items are selected. Omitted arguments are here
%   treated as empty matrices, i.e. no action on these channels. Moreover,
%   Samp = ':' is treated as the empty matrix in this case.
%   When you combine deleting some experiments with deleting all input or
%   output channels, write explicitly the channels to be deleted, like
%   dat([],[],[1:Nu],2).
%
%   See also IDDATA/SET, IDDATA/SUBSREF, IDDATA/MERGE.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.12.4.6 $ $Date: 2008/10/02 18:47:05 $

if nargin==1,
    return
end

if strcmp(Struct(1).type,'{}') % This is the experiment number
    expind = Struct(1).subs;
    substemp = {':',':',':'};
    if length(Struct)>1 && strcmp(Struct(2).type,'()')
        substemp(1:length(Struct(2).subs))=Struct(2).subs;
        Struct = Struct(2:end);
    else
        Struct(1).type='()';
    end
    substemp(4)=expind;
    Struct(1).subs = substemp;
end

StructL = length(Struct);
% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form sys.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructL==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(sys,FieldName),Struct(2:end),rhs);
            end
            set(sys,FieldName,FieldValue)
        catch E
            throw(E)
        end

    case '()'
        % Assignment of the form sys(indices)...=rhs;  rhs is iddata structure

        try
            if StructL==1,
                try
                    sys = indexasgn(sys,Struct(1).subs,rhs);
                catch E
                    throw(E)
                end

            else
                % First reassign tmp = sys(indices)
                try
                    tmp = subsasgn(subsref(sys,Struct(1)),Struct(2:end),rhs);
                catch E
                    throw(E)
                end

                % Then set sys(indices) to tmp
                try
                    sys = indexasgn(sys,Struct(1).subs,tmp);

                catch E
                    throw(E)
                end

            end
        catch E
            throw(E)
        end

    case '{}'
        sys = setexp(sys,Struct(1).subs{1},rhs);

    otherwise
        ctrlMsgUtils.error('Ident:general:unknownSubsasgn',Struct(1).type,'IDDATA')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function    sys = indexasgn(sys,indices,rhs)

if isempty(rhs)
    sys = emptyasg(sys,indices);
    return
end

ln=length(indices);
ind=indices{1};
if islogical(ind),ind=find(ind);end

%{
if strcmp(ind,':')
    newindex = 0;
else
    newindex = 1;
end
%}

if ln>1
    indy = indices{2};
else
    indy = ':';
end

[N,ny,nu,ne] = size(sys);
if ~isa(rhs,'iddata')
    ctrlMsgUtils.error('Ident:general:subsasgnRHSType','IDDATA')
end

if strcmp(indy,':'),indy=1:ny;end
if ischar(indy) && ~(strcmp(indy,':')) || iscell(indy)
    [indy,newnamey] = indname(indy,sys.OutputName,'Output','add',rhs.OutputName);
else
    newnamey = rhs.OutputName;
end

if ln>2
    indu=indices{3};
else
    indu=':';
end
if strcmp(indu,':'),indu=1:nu;end
if ischar(indu) && ~(strcmp(indu,':')) || iscell(indu)
    [indu,newnameu] = indname(indu,sys.InputName,'Input','add',rhs.InputName);
else
    newnameu = rhs.InputName;
end


if ln>3
    indexp=indices{4};
else
    indexp{1}=':';
end
if ~iscell(indexp),indexp={indexp};end
if strcmp(indexp,':'),indexp{1}=1:ne;end
if ischar(indexp) && ~(strcmp(indexp,':'))|| (iscell(indexp) && ischar(indexp{1}))
    [indexp,newnamee] = indname(indexp,sys.ExperimentName,'Experiment',...
        'add',rhs.ExperimentName);
else
    indexp = indexp{1};
    newnamee = rhs.ExperimentName;
end
if isempty(indexp)
    ctrlMsgUtils.error('Ident:iddata:subsasgnCheck1')
end

mindy = min(indy(indy>ny));
if mindy>ny+1
    ctrlMsgUtils.error('Ident:iddata:subsasgnCheck2')
end
mindu = min(indu(indu>nu));
if mindu>nu+1
    ctrlMsgUtils.error('Ident:iddata:subsasgnCheck3')
end
minde = min(indexp(indexp>ne));
if minde>ne+1
    ctrlMsgUtils.error('Ident:iddata:subsasgnCheck4')
end

if ~isa(rhs,'iddata')
    ctrlMsgUtils.error('Ident:general:subsasgnRHSType','IDDATA')
end
if get(rhs,'nu')~=length(indu)
    ctrlMsgUtils.error('Ident:iddata:subsasgnCheck6')
end
if get(rhs,'ny')~=length(indy)
    ctrlMsgUtils.error('Ident:iddata:subsasgnCheck7')
end

if get(rhs,'Ne')~=length(indexp)
    ctrlMsgUtils.error('Ident:iddata:subsasgnCheck8')
end

yname=sys.OutputName;
uname=sys.InputName;
yunit=sys.OutputUnit;
uunit=sys.InputUnit;
y=sys.OutputData;
yn=rhs.OutputData;
u=sys.InputData;
un=rhs.InputData;
ts=sys.Ts;
tstart=sys.Tstart;
samp=sys.SamplingInstants;
period=sys.Period;
intsa=sys.InterSample;
kc=1;  %
for ke=indexp
    replaceflag = 0;
    if ke<=size(sys,4);
        if strcmp(ind,':'),
            ind = 1:size(yn{kc},1);
            ln=length(ind);%size(y{ke},1);
            replaceflag = 1;
        else
            ln=length(ind);
        end
        if size(yn{kc},1)~=ln
            ctrlMsgUtils.error('Ident:iddata:subsasgnCheck9')
        end
        if ~isempty(samp{ke})
            if strcmpi(rhs.Domain,'Frequency') % Reason is that SamplingInstants may be empty in TD
                news = pvget(rhs,'SamplingInstants');
            else
                news = get(rhs,'SamplingInstants');
            end
            if ~iscell(news)
                news = {news};
            end
            samp{ke}(ind) = news{kc};
        end
    end

    y{ke}(ind,indy) = yn{kc};

    u{ke}(ind,indu) = un{kc};
    if replaceflag
        y{ke} = y{ke}(1:length(ind),:);
        u{ke} = u{ke}(1:length(ind),:);
    end

    ts(ke) = rhs.Ts(kc);
    tstart(ke) = rhs.Tstart(kc);
    period{ke}(indu,1) = rhs.Period{kc};
    ku1=1;
    for ku = indu
        intsa{ku,ke} = rhs.InterSample{ku1,kc};
        ku1 = ku1+1;
    end
    kc = kc+1;
end
[dum,newnameu,ov] = defnum3(sys.InputName,'u',newnameu,indu);
if ~isempty(ov)
    ctrlMsgUtils.error('Ident:iddata:subsasgnCheck10')
end
[dum,newnamey,ov] = defnum3(sys.OutputName,'y',newnamey,indy);
if ~isempty(ov)
    ctrlMsgUtils.error('Ident:iddata:subsasgnCheck11')
end
[dum,newnamee,ov] = defnum3(sys.ExperimentName,'Exp',newnamee,indexp);
if ~isempty(ov)
    ctrlMsgUtils.error('Ident:iddata:subsasgnCheck12')
end
if ~isempty(indy)
    yname(indy)=newnamey;
end
if ~isempty(indu)
    uname(indu)=newnameu;
end

ename = sys.ExperimentName;
ename(indexp) = newnamee;
yunit(indy) = rhs.OutputUnit;

uunit(indu) = rhs.InputUnit;
try
    sys = pvset(sys,'InputData',u,'OutputData',y,'InputName',uname,...
        'OutputName',yname,'OutputUnit',yunit,'InputUnit',uunit,...
        'SamplingInstants',samp,'Ts',ts,'Tstart',tstart,...
        'Period',period,'InterSample',intsa,'ExperimentName',ename);
catch E
    throw(E)
end
