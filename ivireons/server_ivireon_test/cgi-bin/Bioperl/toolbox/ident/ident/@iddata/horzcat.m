function dat = horzcat(varargin)
% HORZCAT Horizontal concatenation of IDDATA sets.
%
%   DAT =HORZCAT(DAT1,DAT2,..,DATn) or DAT = [DAT1,DAT2,...,DATn]
%   creates a data set DAT with input and output channels composed 
%   of those in DATk. 
%
%   Default channel names (u1, u2, y1 ,y2 etc) will be changed so
%   that overlaps in names are avoided, and the new channels will
%   be added.
%
%   If DATk contains channels with user specified names, that are
%   already present in the channels of Datj, j<k, these new channels
%   will be ignored.
%

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.13.4.11 $ $Date: 2009/03/09 19:13:24 $

dat = varargin{1}; 
reald = realdata(dat);
N = size(dat,'N');
if ~isa(dat,'iddata')
    ctrlMsgUtils.error('Ident:transformation:concatClassType','IDDATA')
end

for i=2:nargin
    nu = get(dat,'nu');
    %ny=get(dat,'ny');
    datt = varargin{i};
    if ~isa(datt,'iddata')
        ctrlMsgUtils.error('Ident:transformation:concatClassType','IDDATA')
        %datt = iddata([],datt);
    end
    if ~strcmpi(dat.Domain,datt.Domain)
        ctrlMsgUtils.error('Ident:dataprocess:concatDataDomain')
    end
    if dat.Domain(1)=='F'
        realdd = realdata(datt);
        Nd = size(datt,'N');
        if realdd~=reald && ~all(Nd == N) % to trap a possible misuse
            ctrlMsgUtils.error('Ident:dataprocess:concatRealComplexMix');
        end
    end
    y = datt.OutputData; 
    u = datt.InputData; 
    yna = datt.OutputName;
    yun = datt.OutputUnit;
    una = datt.InputName;
    uun = datt.InputUnit;
    yy = dat.OutputData;
    uu = dat.InputData;
    yyna = dat.OutputName;
    yyun = dat.OutputUnit;
    uuna = dat.InputName;
    uuun = dat.InputUnit;
    samp =  pvget(dat,'SamplingInstants');
    sampp = pvget(datt,'SamplingInstants');
    [novy,yna,yov] = defnum2(yyna,'y',yna);
    [novu,una,uov] = defnum2(uuna,'u',una);
    if ~isempty(uov)
        ctrlMsgUtils.warning('Ident:dataprocess:horzcatCheck1')
    end
    if ~isempty(yov)
        ctrlMsgUtils.warning('Ident:dataprocess:horzcatCheck2')
    end
    l1 = length(y); l2 =length(yy);
    if l1~=l2
        ctrlMsgUtils.error('Ident:dataprocess:concatDataExp')
    end
    for kk = 1:l1
        if size(yy{kk},1)~= size(y{kk},1)
            ctrlMsgUtils.error('Ident:dataprocess:horzcatCheck3')
        end
        if norm(samp{kk}-sampp{kk})>sqrt(eps)%~all(samp{kk}==sampp{kk})
            if strcmpi(dat.Domain,'time')
                ctrlMsgUtils.error('Ident:dataprocess:horzcatCheck4')
            else
                ctrlMsgUtils.error('Ident:dataprocess:horzcatCheck5')
            end 
        end
        ynew{kk} = [yy{kk},y{kk}(:,novy)];
        peridnew{kk} = [dat.Period{kk};datt.Period{kk}(novu)];
        if nu == 0 && get(datt,'nu')>0
            internew(:,kk) = datt.InterSample(novu,kk);
        elseif get(datt,'nu')==0 && nu>0
            internew(:,kk) = dat.InterSample;
        elseif get(datt,'nu')==0 && nu==0
            internew(:,kk) = cell(1,0);
        else
            internew(:,kk) = [dat.InterSample(:,kk);datt.InterSample(novu,kk)];
        end
        unew{kk} = [uu{kk},u{kk}(:,novu)];
    end
    dat = pvset(dat,'OutputData',ynew,'InputData',unew,...
        'OutputName',yna,'InputName',una,'InputUnit',[uuun;uun(novu)],...
        'OutputUnit',[yyun;yun(novy)],'Period',peridnew,...
        'InterSample',internew);  
    clear internew
end
