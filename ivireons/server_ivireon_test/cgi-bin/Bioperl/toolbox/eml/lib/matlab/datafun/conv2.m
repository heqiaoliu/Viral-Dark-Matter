function c = conv2(arg1,arg2,arg3,arg4)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2, 'Not enough input arguments.');
if nargin == 2
    c = eml_conv2('full',arg2,arg1);
elseif nargin == 3
    eml_lib_assert(ischar(arg3) || (isvector(arg1) && isvector(arg2)), ...
        'MATLAB:conv2:firstTwoInputsNotVectors', ...
        'HCOL and HROW must be vectors.');
    if ischar(arg3)
        c = eml_conv2(arg3,arg2,arg1);
    else % isvector(arg1) && isvector(arg2)
        c = eml_conv2('full',arg3,arg2,arg1);
    end
else
    c = eml_conv2(arg4,arg3,arg2,arg1);
end

%--------------------------------------------------------------------------

function c = eml_conv2(shape,b,a,h1)
% CONV2 function with arguments reversed.
% With nargin == 3, EML_CONV2(SHAPE,B,A) = CONV2(A,B,SHAPE).
% With nargin == 4, EML_CONV2(SHAPE,B,H2,H1) = CONV2(H1,H2,B,SHAPE).
separable = nargin == 4;
assertnumeric(b);
assertnumeric(a);
if separable
    assertnumeric(h1);
    ma = eml_numel(h1);
    na = eml_numel(a);
else
    [ma,na] = size(a);
end
[mb,nb] = size(b);
switch shape
    case {'f','full'}
        if ma == 0 || mb == 0
            mc = ma + mb;
        else
            mc = ma + mb - 1;
        end
        if na == 0 || nb == 0
            nc = na + nb;
        else
            nc = na + nb - 1;
        end
        ioffset = 0;
        joffset = 0;
    case {'s','same'}
        if separable
            mc = mb;
            nc = nb;
            if ma < 1
                ioffset = 0;
            else
                ioffset = round(eml_rdivide(ma-1,2));
            end
            if na < 1
                joffset = 0;
            else
                joffset = round(eml_rdivide(na-1,2));
            end
        else
            mc = ma;
            nc = na;
            if mb < 1
                ioffset = 0;
            else
                ioffset = round(eml_rdivide(mb-1,2));
            end
            if nb < 1
                joffset = 0;
            else
                joffset = round(eml_rdivide(nb-1,2));
            end
        end
    case {'v','valid'}
        if separable
            ioffset = ma - 1;
            joffset = na - 1;
            if mb < ioffset
                mc = 0;
            else
                mc = mb - ioffset;
            end
            if nb < joffset
                nc = 0;
            else
                nc = nb - joffset;
            end
        else
            ioffset = mb - 1;
            joffset = nb - 1;
            if ma < ioffset
                mc = 0;
            else
                mc = ma - ioffset;
            end
            if na < joffset
                nc = 0;
            else
                nc = na - joffset;
            end
        end
    otherwise
        eml_assert(false, ... % 'MATLAB:conv2:unknownShapeParameter;'
            'SHAPE must be ''full'', ''same'', or ''valid''.'); 
end
if separable
    c = conv2sep(h1,a,b,mc,nc,ioffset,joffset);
else
    c = conv2nonsep(a,b,mc,nc,ioffset,joffset);
end

%--------------------------------------------------------------------------

function c = conv2nonsep(a,b,mc,nc,ioffset,joffset)
% Nonseparable conv2.
eml_must_inline;
[ma,na] = size(a);
[mb,nb] = size(b);
ZERO = eml_scalar_eg(a,b);
c = eml.nullcopy(eml_expand(ZERO,[mc,nc]));
if isempty(a) || isempty(b) || mc == 0 || nc == 0
    c(:) = ZERO;
    return
end
for jc = 1:nc
    j = jc + joffset;
    jp1 = j + 1;
    if nb < jp1 % ja1 = max(1,jp1-nb);
        ja1 = jp1 - nb;
    else
        ja1 = 1;
    end
    if na < j % ja2 = min(na,j);
        ja2 = na;
    else
        ja2 = j;
    end
    for ic = 1:mc
        i = ic + ioffset;
        ip1 = i + 1;
        if mb < ip1 % ia1 = max(1,ip1-mb);
            ia1 = ip1 - mb;
        else
            ia1 = 1;
        end
        if ma < i % ia2 = min(ma,i);
            ia2 = ma;
        else
            ia2 = i;
        end
        s = ZERO;
        for ja = ja1:ja2
            jb = jp1 - ja;
            for ia = ia1:ia2
                ib = ip1 - ia;
                s = s + a(ia,ja)*b(ib,jb);
            end
        end
        c(ic,jc) = s;
    end
end

%--------------------------------------------------------------------------

function c = conv2sep(hcol,hrow,b,mc,nc,ioffset,joffset)
% Separable conv2.
eml_must_inline;
ma = eml_numel(hcol);
na = eml_numel(hrow);
[mb,nb] = size(b);
work = eml_expand(eml_scalar_eg(hcol,b),[mc,nb]);
c = eml_expand(eml_scalar_eg(work,hrow),[mc,nc]);
if isempty(hcol) || isempty(hrow) || isempty(b) || isempty(c)
    return
end
% These limits were derived to avoid ilo > ihi.
for k = max(1,ioffset+2-mb):min(ma,mc+ioffset)
    ko = k - ioffset;
    kom1 = ko - 1;
    if ko > 0
        ilo = ko;
    else
        ilo = 1;
    end
    ihi = mb + kom1;
    if ihi > mc
        ihi = mc;
    end
    wc = hcol(k);
    if wc ~= 0
        for j = 1:nb
            for i = ilo:ihi
                work(i,j) = work(i,j) + b(i-kom1,j)*wc;
            end
        end
    end
end
% These limits were derived to avoid ilo > ihi.
for k = max(1,joffset+2-nb):min(na,nc+joffset)
    ko = k - joffset;
    kom1 = ko - 1;
    if ko > 0
        jlo = ko;
    else
        jlo = 1;
    end
    jhi = nb + kom1;
    if jhi > nc
        jhi = nc;
    end
    wr = hrow(k);
    if wr ~= 0
        for j = jlo:jhi
            jmkom1 = j - kom1;
            for i = 1:mc
                c(i,j) = c(i,j) + work(i,jmkom1)*wr;
            end
        end
    end
end

%--------------------------------------------------------------------------

function assertnumeric(x)
eml_assert(isa(x,'numeric'), ...
    ['Function ''conv2'' is not defined for values of class ''' class(x) '''.']);

%--------------------------------------------------------------------------
