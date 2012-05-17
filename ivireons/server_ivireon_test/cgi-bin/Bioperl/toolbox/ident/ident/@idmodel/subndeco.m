function [yind,uind,returnflag,flagmea,flagall,flagnoise,flagboth] = ...
    subndeco(idm,index,lam)
% SUBNDECO Decodes the calls for subsref

%   $Revision: 1.8.4.4 $  $Date: 2008/10/02 18:48:34 $
%   Copyright 1986-2008 The MathWorks, Inc.

yind = [];
uind = [];
flagall = 0;
flagmea = 0;
flagnoise = 0;
flagboth = 0;
returnflag = 0;
ny = length(idm.OutputName);
nu = length(idm.InputName);
if length(index)==1 % then make a nice interpretation
    if ischar(index{1}) && isempty(strmatch(index{1},idm.OutputName,'exact')) ...
            && any(strcmpi(index{1}(1),{'n','m','a','b'}))
        index{2}=index{1};
        index{1}=':';

    elseif ny ==1 && nu >0
        index{2} = index{1};
        index{1}=':';
    elseif nu==1
        index{2}=':';
    elseif nu==0
        index{2} = [];
    else
        ctrlMsgUtils.error('Ident:idmodel:subsrefMIMO')
    end
end

if length(index)>2 && all(strcmp(index{3},'s'))
    silent = 1;
else
    silent = 0;
end

if (strcmp(index(1),':') && all(strcmp(index{2},':')))
    returnflag = 1;
    return
end
try
    if (strcmp(index(1),':') && strcmpi(index{2}(1),'m') && norm(lam)==0)
        returnflag = 1;
        return
    end
end

[yind,errflagy] = indmatch(index{1},idm.OutputName,ny,'Output');
flagnoise = 0;
if ~silent
    if ~isempty(errflagy.message), error(errflagy), end
else
    if ~isempty(errflagy.message)
        returnflag = 3;
        return
    end
end
if nu == 0

    if ~isempty(index{2})
        ind = index{2};
        if ischar(ind)
            tm = idchnona(ind);
            if strcmp(tm,'measured')
                flagmea = 1;
                returnflag = 3;
                return

            elseif strcmp(ind,'allx9') || strcmp(ind,'all')%'all' temp allowed for compatibility
                flagall = 1;
                return
            elseif strcmp(ind,'bothx9')
                flagboth = 1;
                return
            elseif ~strcmp(tm,'noise') && ~strcmp(ind,':')
                ctrlMsgUtils.error('Ident:idmodel:subsrefUnknownUName')
            end
        end
        %       if strcmp(lower(index{2}(1)),'a')
        %          flagall = 1;
        %          return
        %       end
        %       if strcmp(lower(index{2}(1)),'b')  %% both
        %          flagboth = 1;
        %          return
        %       end
        %       if strcmp(lower(index{2}(1)),'m')
        %          flagmea = 1;
        %          returnflag = 3;
        %          return
        %       end
        if isa(index{2},'double') && index{2}>0
            ctrlMsgUtils.error('Ident:idmodel:subsrefUIndex1')
        end
    end
    %index{2}=[];
    try
        if all(yind==(1:ny)) && ~flagall
            returnflag = 1;

        end
    end
    return
end

[uind,errflagu,flagmea,flagall,flagnoise,flagboth] = indmatch(index{2},idm.InputName,...
    nu,'Input',lam);
if ~silent
    if ~isempty(errflagu.message), error(errflagu), end
else
    if ~isempty(errflagu.message)
        returnflag = 3;
        return
    end
end

try
    if ~flagall && ~flagmea
        if (isempty(uind))
            if all(yind ==(1:ny)) && nu==0
                returnflag = 1;
            end
        elseif all(uind==(1:nu))
            if all(yind ==(1:ny))
                returnflag = 1;
            end

        end
    end
end

if (flagnoise && (norm(lam)==0 || isempty(lam))) || (flagmea && nu==0)
    returnflag = 2;
    return
end

