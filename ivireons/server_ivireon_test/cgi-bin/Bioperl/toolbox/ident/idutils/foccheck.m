function foc = foccheck(foc,Ts,a,dom,varargin)
%FOCCHECK Auxiliary function to PEM and ARX
%
%   MFOC = FOCCHECK(FOC,Ts)
%   FOC: a Focus property: either LTI or IDMODEL or {num,den} or {A,B,C,D}
%   MFOC: returned focus, checked for stability, in the form {num,den} or
%         {A,B,C,D}

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.11.4.4 $  $Date: 2009/11/09 16:23:45 $
%{
if nargin<5
    dataname = 'Data';
end
%}

if nargin < 4
    dom = 't';
end
if nargin <3
    %tf = 0;
    a = [];
end
if isempty(a)
    a = 0;
end
if a~=0
    tf = 1;
else
    tf = 0;
end
%objflag = 0;
if isnumeric(foc)
    if dom=='t'
        % error(sprintf(['FOCUS can be defined as intervals only for frequency',...
        %        ' domain data.\nFirst apply %sF = FFT(%s).'],dataname,dataname))
        %return
    end
end
if isa(foc,'lti') || isa(foc,'idmodel')
    if get(foc,'Ts')==0
        foc = c2d(foc,Ts);
    end
    if tf
        [num,den] = tfdata(foc,'v');
        foc = {num,den};
    else
        [a,b,c,d] = ssdata(foc);
        foc = {a,b,c,d};
    end
    %objflag = 1;
end
if iscell(foc)
    if length(foc)==5 % Then it is ABCD and Ts
        Tsfoc = foc{5};
        if Tsfoc==0 && Ts>0
            [am,bm] = idsample(foc{1:4},zeros(size(foc{1},1),0),Ts,'zoh');
            foc={am,bm,foc{3},foc{4}};
            eitest = max(abs(eig(am)));
        else
            foc = foc(1:4);
            if Ts>0
                eitest=max(abs(eig(foc{1})));
            else
                eitest = 0;
            end
        end
        if eitest>1
            ctrlMsgUtils.error('Ident:estimation:focFilterUnstable1')
        end
    elseif length(foc)==4
        r = max(abs(eig(foc{1})));
        if ~isempty(r) && r>1
            ctrlMsgUtils.error('Ident:estimation:focFilterUnstable2')
        end
    elseif length(foc)==2
        r = max(abs(roots(foc{2})));
        if ~isempty(r) && r>1
            ctrlMsgUtils.error('Ident:estimation:focFilterUnstable3')
        end
    end
end
if tf % Now make an allpass approximation of the ARX A-polynomial in case it is unstable:
    if length(foc)==4
        [num,den]=ss2tf(foc{:},1);
        foc{1}=num;foc{2}=den;
    end
    foc={foc{1},conv(foc{2},fstab(a))};
end
