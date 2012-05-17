function [sys,sysname,PlotStyle,sd,ap,om,mode,fill,sdmark,sdstep] = ...
    sysardec(bode,varargin)
%SYSARDEC  Parse the input arguments for BODE, NYQUIST and FFPLOT

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.18.4.4 $ $Date: 2008/10/02 18:52:05 $

ni = nargin-1;
%no = nargout;
% First remove 'sd', 'mode' and 'ap' if found.
sd = 0;
om =[];
ap ='b';
mode = 'sep';
fill = 0;
sdmark = [];
sdstep = [];

if bode==0
    command = 'ffplot';
    hlp = 'ffplot';
elseif bode==3
    command = 'nyquist';
    hlp = 'idmodel/nyquist';
elseif bode==1
    command = 'bode';
    hlp = 'idmodel/bode';
else
    command = 'frequency response';
    hlp = 'idmodel/freqresp';
end

ind = [];
for j = 1:ni
    symb = varargin{j};
    if ischar(symb)
        if length(symb)>1 && any(strcmpi(symb(1:2),...
                {'sd','mo','ap','fi'}))
            if strcmpi(symb(1:2),'fi')
                fill = 1;
                ind = [ind,j];
            else
                if j == ni
                    ctrlMsgUtils.error('Ident:utility:sysardec1',command,hlp)
                end
                Value = varargin{j+1};
                ind = [ind,j,j+1];
                if strcmpi(symb(1:2),'sd')
                    sd = Value;
                    if length(symb)>2
                        sdmark = symb(3);
                        if length(symb)>3
                            sdstep = str2double(symb(4:end));
                            if isnan(sdstep)
                                ctrlMsgUtils.error('Ident:utility:sysardec2')
                            end
                        end
                    end


                elseif strcmpi(varargin{j}(1:2),'mo')
                    mode = Value;
                else
                    ap = Value;
                end
            end
        end
    end
end

varargin(ind)=[];ni = length(varargin);
newarg=[];inpn=[];
% Parse input list
for j=1:ni
    if iscell(varargin{j}) && (isa(varargin{j}{1},'idfrd') || isa(varargin{j}{1},'idmodel'))
        newarg=[newarg,varargin{j}];
        inpn =[inpn,cell(1,length(varargin{j}))];
    elseif isa(varargin{j},'frd')
        newarg = [newarg,{idfrd(varargin{j})}];
        inpn = [inpn,{inputname(j)}];
    elseif isa(varargin{j},'lti')
        newarg = [newarg,{idss(varargin{j})}];
        inpn = [inpn,{inputname(j)}];

    else
        newarg=[newarg,varargin(j)];
        inpn = [inpn,{inputname(j)}];
    end
end
varargin = newarg;ni = length(varargin);
inputname1 = inpn;
nsys = 0;       % counts LTI systems
nstr = 0;      % counts plot style strings
%nw = 0;
sys = cell(1,ni);
sysname = cell(1,ni);
PlotStyle = cell(1,ni);
%m=inf;
lastsyst=0;lastplot=0;

for j=1:ni,
    argj = varargin{j};
    if isa(argj,'idmodel') || isa(argj,'idfrd')
        if ~isempty(argj)
            if isa(argj,'idmodel') && isnan(argj)
                ctrlMsgUtils.warning('Ident:utility:sysardec3',command)
                lastsyst =j;
            else
                nsys = nsys+1;
                sys{nsys} = argj;
                sysname{nsys} = inputname1{j};lastsyst=j;
            end
        end
    elseif ischar(argj) &&  j>1 && (isa(varargin{j-1},'idmodel') || isa(varargin{j-1},'idfrd'))
        if ~any(strcmpi(argj(1),{'a','p','s'}))% to cut off a/p and 'same'
            nstr = nstr+1;
            PlotStyle{nsys} = argj; lastplot=j;
        end
        if strcmpi(argj(1),'s') %to fix 'square'
            if length(argj)==1
                nstr = nstr+1;
                PlotStyle{nsys} = argj; lastplot=j;
            end
        end
    end
end
if lastplot==lastsyst+1,lastsyst=lastsyst+1;end
kk=1;
newarg=[];
if ni>lastsyst
    for j=lastsyst+1:ni
        newarg{kk}= varargin{j};kk=kk+1;
    end
else
    newarg={};
end
sys = sys(1:nsys);
sysname = sysname(1:nsys);
PlotStyle = PlotStyle(1:nsys);
% Now dissect newarg
if ~isempty(newarg)
    for kk = 1:length(newarg)
        arg = newarg{kk};
        if isa(arg,'double')
            if length(arg)==1 % is SD
                sd = arg;
            else  %is frequency vector
                om = arg(:);
            end
        elseif ischar(arg) % is ap
            ap1 = lower(arg(1));
            if any(strcmp(ap1,{'a','p','b'}))
                ap = ap1;
            elseif length(arg)>1 && strcmp(arg(1:2),'sa')
                mode = 'same';
            elseif length(arg)>1 && strcmp(arg(1:2),'se')
                mode = 'sep';
            else
                ctrlMsgUtils.warning('Ident:utility:sysardec4',arg,command,command)
            end
        elseif iscell(arg) % wmin wmax
            if length(arg)<2
                ctrlMsgUtils.error('Ident:analysis:freqrespInvalidFreq')
            elseif length(arg)>2
                nopo = arg{3};
            else
                nopo = 100;
            end

            if bode==1
                if arg{1}<=0
                    if arg{2}<=0
                        ctrlMsgUtils.error('Ident:analysis:freqrespInvalidFreq')
                    end
                    ctrlMsgUtils.warning('Ident:analysis:freqrespInvalidFreq2')
                    arg{1} = arg{2}/1000;
                end
                om = logspace(log10(arg{1}),log10(arg{2}),nopo);
            else
                om = linspace(arg{1},arg{2},nopo);
            end
        end
    end
end
if ~any(strcmp(ap,{'a','p','b'}))
    ctrlMsgUtils.error('Ident:utility:sysardec5',command)
end

