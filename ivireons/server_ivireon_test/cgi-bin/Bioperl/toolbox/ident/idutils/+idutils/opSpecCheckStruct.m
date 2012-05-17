function [X,msg] = opSpecCheckStruct(opSpec,X,Type)
% Check struct fields for Input and Output properties of idnlarxopspec and
% idnlhwopspec objects.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/02 18:52:18 $

msg = '';

if strcmp(Type,'Input')
    nx = opSpec.Sizes(2);
else
    nx = opSpec.Sizes(1);
end

% Value
x = X.Value;
if ~(isrealvec(x) && all(isfinite(x)))
    msg = ctrlMsgUtils.message('Ident:analysis:opSpecValueType',[Type,'.Value']);
    return
elseif length(x)~=nx
    msg = ctrlMsgUtils.message('Ident:analysis:opSpecSize',[Type,'.Value'],nx);
    return
else
    X.Value = x(:).';
end

% Min bound
x = X.Min;
if ~(isrealvec(x) && all(~isnan(x)) && ~any(x==Inf))
    msg = ctrlMsgUtils.message('Ident:analysis:opSpecMinType',[Type,'.Min']);
    return
elseif length(x)~=nx
    msg = ctrlMsgUtils.message('Ident:analysis:opSpecSize',[Type,'.Min'],nx);
    return
else
    X.Min = x(:).';
end

% Max bound
x = X.Max;
if ~(isrealvec(x) && all(~isnan(x)) && ~any(x==-Inf))
    msg = ctrlMsgUtils.message('Ident:analysis:opSpecMaxType',[Type,'.Max']);
    return
elseif length(x)~=nx
    msg = ctrlMsgUtils.message('Ident:analysis:opSpecSize',[Type,'.Max'],nx);
    return
else
    X.Max = x(:).';
end

% Known flag
if isa(opSpec,'idnlhwopspec') || strcmp(Type,'Input') % no Known flag for output for idnlarxspec
    x = X.Known;
    if (~islogical(x) && ~all(x==0 | x==1)) || (length(x)~=nx)
        msg = ctrlMsgUtils.message('Ident:analysis:opSpecLogicalSizeType',[Type,'.Known'],nx);
    else
        X.Known = logical(x(:)).';
    end
end
