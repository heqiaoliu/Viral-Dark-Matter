function dat = vertcat(varargin)
% VERTCAT Vertical concatenation of IDDATA sets.
%
%   DAT = VERTCAT(DAT1,DAT2,..,DATn) or DAT = [DAT1;DAT2;...;DATn]
%   creates a data set DAT with input and output samples composed
%   of those in DATk. Each experiment will thus consist of longer
%   data records, with the same number of channels.
%
%   To select portions of the data use subreferencing: DAT = DAT(1:300);
%
%   The channel names must be the same in each of DATk, and so
%   must the experiment names
%
%   See also IDDATA/SUBSREF, IDDATA/HORZCAT, IDDATA/SUBSASGN

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.11.4.8 $  $Date: 2010/03/08 21:39:53 $

dat = varargin{1};
ny = get(dat,'ny');
nu = get(dat,'nu');
exno1 = dat.ExperimentName;
una = dat.InputName;
yna = dat.OutputName;
uu = dat.InputUnit;
yu = dat.OutputUnit;
int = dat.InterSample;
%Ts = dat.Ts;
per = dat.Period;
for i=2:nargin
    datt = varargin{i};
    if ~isa(datt,'iddata')
        ctrlMsgUtils.error('Ident:transformation:concatClassType','IDDATA')
    end
    if ~strcmpi(dat.Domain,datt.Domain)
        ctrlMsgUtils.error('Ident:dataprocess:concatDataDomain')
    end
    ny1 = get(datt,'ny');
    nu1 = get(datt,'nu');
    %nexp = get(datt,'ne');
    exno = datt.ExperimentName;
    if ny1~=ny
        ctrlMsgUtils.error('Ident:dataprocess:vertcatNy','IDDATA')
    end
    
    if nu1~=nu
        ctrlMsgUtils.error('Ident:dataprocess:vertcatNu','IDDATA')
    end
    
    if length(exno)~=length(exno1)
        ctrlMsgUtils.error('Ident:dataprocess:concatNe')
    end
    if (nu~=0) && (~all(strcmp(yna,datt.OutputName)) || ~all(strcmp(una,datt.InputName)))
        ctrlMsgUtils.warning('Ident:dataprocess:vertcatcheck6')
    end
    if (nu~=0) && (~all(strcmp(yu,datt.OutputUnit)) || ~all(strcmp(uu,datt.InputUnit)))
        ctrlMsgUtils.warning('Ident:dataprocess:vertcatcheck7')
    end
    
    %% check for channel names & units, override
    %% Check sampling interval, use SamplingInstants if necessary
    %% check period, inf dominant
    %% check intersample, error
    pert = datt.Period;
    Tst = datt.Ts;
    intt = datt.InterSample;
    Ts = dat.Ts;
    if strcmpi(dat.Domain,'frequency')
        dat = freqvert(dat,datt);
        continue;
    end
    samp = dat.SamplingInstants;
    sampt = datt.SamplingInstants;
    samptr = pvget(datt,'SamplingInstants');
    sampr = pvget(dat,'SamplingInstants');
    Ne = get(dat,'Ne');
    yn = cell(1,Ne); un = yn;
    for kk=1:Ne
        if isempty(Ts{kk})
            if isempty(Tst{kk}) % Then we concatenate the sampling instants
                if max(samp{kk})>min(sampt{kk})
                    ctrlMsgUtils.error('Ident:dataprocess:vertcatcheck8')
                end
                samp{kk} = [samp{kk};sampt{kk}];
            else  % new data equal sampling: Add with new sampling interval
                if datt.Tstart{kk}<0
                    ctrlMsgUtils.error('Ident:dataprocess:vertcatcheck9a')
                end
                samp{kk} = [samp{kk};samptr{kk}+max(samp{kk})];
            end
        else % Old data equal sampling
            if isempty(Tst{kk}) % new data not equally sampled
                if max(sampr{kk})>min(samptr{kk})
                    ctrlMsgUtils.error('Ident:dataprocess:vertcatcheck8')
                end
                samp{kk} =[sampr{kk};sampt{kk}];
            else % new data equally sampled
                if Ts{kk}~=Tst{kk} % Different sampling times
                    if datt.Tstart{kk}<0
                        ctrlMsgUtils.error('Ident:dataprocess:vertcatcheck9b')
                    end
                    samp{kk} = [sampr{kk};samptr{kk}+max(sampr{kk})];
                end
            end
        end
        
        
        per1 = per{kk}; pert1 = pert{kk};
        noeq = find(per1~=pert1);
        per{kk}(noeq) = inf*ones(length(noeq),1);
        yn{kk} = [dat.OutputData{kk};datt.OutputData{kk}];
        un{kk} = [dat.InputData{kk};datt.InputData{kk}];
        if nu>0&&(~all(strcmpi(int(:,kk),intt(:,kk))))
            ctrlMsgUtils.error('Ident:dataprocess:vertcatcheck10')
        end
        
    end
    dat.OutputData = yn;
    dat.InputData = un;
    dat.Period = per;
    dat = pvset(dat,'SamplingInstants',samp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dat = freqvert(dat,datt)
fr = dat.SamplingInstants;
frt = datt.SamplingInstants;

Lfr = length(fr);
yns = cell(1,Lfr); uns = yns; frs = yns;
for kexp = 1:Lfr
    frn = [fr{kexp}; frt{kexp}];
    yn = [dat.OutputData{kexp}; datt.OutputData{kexp}];
    un = [dat.InputData{kexp};  datt.InputData{kexp}];
    [~,ind] = sort(frn);
    yns{kexp} = yn(ind,:);
    uns{kexp} = un(ind,:);
    frs{kexp} = frn(ind);
end
dat.OutputData = yns;
dat.InputData = uns;
dat.SamplingInstants = frs;
