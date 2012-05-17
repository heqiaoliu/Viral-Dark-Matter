function  [obj,  msg] = str2customreg(str, sys)
%STR2CUSTOMREG converts a custom regressor from string form to MCOS form
%
%[obj,  msg] = str2customreg(str, sys)
%sys: IDNLARX object
%str: custom regressor in string form
%obj: CUSTOMREG MCOS object
%msg: error message

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2009/03/09 19:14:52 $

% Author(s): Qinghua Zhang

error(nargchk(2, 2, nargin,'struct'))

msg = struct([]);
obj = [];

if isempty(str)
    return
end

[ny, nu] = size(sys);

[str, msg] = custregprecheck(str, ny);
if ~isempty(msg)
    return
end

if ny==1
    [obj,  msg] = SOstr2cust(sys, str);
else %ny>1
    % Multiple outputs case
    % Note: ny==length(str) is already checked in custregprecheck.
    obj = cell(ny,1);
    for ky = 1:ny
        [obj{ky},  msg] = SOstr2cust(sys, str{ky});
        if ~isempty(msg)
            return
        end
    end
end

end %function

%=========================================================
function [obj,  msg] = SOstr2cust(sys, str)
%Single output case of str2customreg

msg = struct([]);

if isa(str, 'customreg')
    % already customreg object, quick exit.
    obj = str;
    return
end
ns = length(str);
if ns==0
    obj = [];
    return
end

obj0 = customreg;
obj = obj0(ones(ns,1));
for ks=1:ns
    if ischar(str{ks})
        [obj0, msg] = SingleStringConvert(sys, str{ks});
    elseif isa(str{ks}, 'customreg')
        obj0 = str{ks};
    end
    if ~isempty(msg)
        obj = [];
        return
    end
    obj(ks) = obj0;
end

end %function

%-----------------------------------------------
function [obj,  msg] =  SingleStringConvert(sys, str)

% Get info from the IDNLARX object.
InName  = pvget(sys, 'InputName');
OutName = pvget(sys, 'OutputName');
TimeVar = pvget(sys, 'TimeVariable');
[ny, nu] = size(sys);

msg = struct([]);

InName = InName(:)';   % row cellarray
OutName = OutName(:)'; % row cellarray

obj = customreg;
%obj.Display = str;
str0 = str;

Arguments = {};
Delays = [];

args = [];

% Check the presence of '(t'
if isempty(strfind(str, ['(',TimeVar]))
    msg = ctrlMsgUtils.message('Ident:utility:str2CustomRegExpression',TimeVar);
    msg = struct('identifier','Ident:utility:str2CustomRegExpression','message',msg);
    return
end

% Handle output variables
for k = 1:ny
    [pos, del, msg] = FindVar([OutName{k} '(' TimeVar], str);
    if ~isempty(msg)
        return
    end
    unidel = unique(del);
    if ~isempty(pos)
        str = VarRep('y', pos, del, k, str);
        args = [args, ArgNameCompose('y', k, unidel)];
        Arguments = [Arguments, OutName(k(ones(1,length(unidel))))];
        Delays = [Delays, unidel];
    end
end

% Handle input variables.
for k = 1:nu
    [pos, del, msg] = FindVar([InName{k} '(' TimeVar], str);
    if ~isempty(msg)
        return
    end
    unidel = unique(del);
    if ~isempty(pos)
        str = VarRep('u', pos, del, k, str);
        args = [args, ArgNameCompose('u', k, unidel)];
        Arguments = [Arguments, InName(k(ones(1,length(unidel))))];
        Delays = [Delays, unidel];
    end
end

if isempty(Arguments)
    msg = ctrlMsgUtils.message('Ident:utility:str2CustomRegIONum');
    msg = struct('identifier','Ident:utility:str2CustomRegIONum','message',msg);
    return
end

obj.Arguments = Arguments;
obj.Delays = Delays;
try
    fstr = ['@(', sprintf('%s,',args{1:end-1}), args{end}, ')', str];
    obj.Function = str2func(fstr); 
catch E
    msg = E;
    return
end

obj.Display = str0;

end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function reg = VarRep(io, pos, del, num, reg)

for i = length(pos):-1:1
    lpos = findstr(reg, ')');
    lpos = lpos(lpos > pos(i));
    %k = length(pos)-i+1;
    reg = [reg(1:pos(i)-1), io, num2str(num), '_' num2str(del(i)), reg(lpos(1)+1:end)];
end

end %function


%==================================================
function args = ArgNameCompose(io, kch, delays)
%Compose argument names to be used in customreg
%io: 'y' or 'u'
%kch: channel number (scalar)
%delays: regressor delays (row vector)

%Note: this is a nested function

args = arrayfun(@ArgName, delays, 'UniformOutput', false);

    function a = ArgName(d)
        a = [io, num2str(kch), '_' num2str(d)];
    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pos, del, msg] = FindVar(name, reg)

% If reg has fewer characters than name, then return [].
pos = [];
del = [];
msg = struct([]);
if (length(reg) < length(name))
    return;
end

% Get all positions of name in reg.
apos = findstr(name, reg);

if isempty(apos)
    return;
end

% Remove false name hits by looking at the beginning of the expression.
spos = [];
for i = 1:length(apos)
    if (apos(i) == 1)
        spos = [spos apos(i)];
    elseif ~isalpha_num(reg(apos(i)-1)) && ~isalpha_num(reg(apos(i)+length(name)))
        spos = [spos apos(i)];
    end
end
if isempty(spos)
    return
end

% Compute the delay del.
lpos = findstr(reg, ')');
for i = 1:length(spos)
    apos = lpos(lpos >= spos(i)+length(name));
    delstr = reg(spos(i)+length(name):apos(1)-1);
    if isempty(delstr)
        del = [del 0];
    else
        deltmp = -str2double(reg(spos(i)+length(name):apos(1)-1));
        if isnan(deltmp)
            msg = ctrlMsgUtils.message('Ident:utility:str2CustomRegDelayVal');
            msg = struct('identifier','Ident:utility:str2CustomRegDelayVal','message',msg);
            return
        else
            del = [del deltmp];
        end
    end
end

% Return spos as pos.
pos = spos;

end %function
% FILE END