function setstruc(m,a,b,c,d,k,x0)
%SETSTRUC Function to set Structure matrices in IDSS model objects.
%
%   SETSTRUC(M,An,Bn,Cn,Dn,Kn,X0n)
%
%   Same as SET(M,'As',An,'Bs',Bn,'Cs',Cn,'Ds',Dn,'Ks',Kn,'X0s',X0n)
%   Use empty matrices for those structure matrices that should not be changed.
%   Trailing arguments may be omitted.
%
%   An alternative syntax is:
%
%   SETSTRUC(M,ModStruc)
%
%   where ModStruc is a structure with fieldnames As, Bs, etc,
%   and values An, Bn etc. ModStruc need not have all the fieldnames above.
%
%   Type "idprops idss" for more information.
%
%   See also IDSS.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $ $Date: 2009/03/09 19:13:58 $


if nargin <2
    disp('Usage: SETSTRUC(M,A,B,C,D,K,X0)')
    disp('       SETSTRUC(M,struc)')
    return
end
kc = 1;
if isstruct(a)
    fn = fieldnames(a);
    
    for kn = 1:length(fieldnames(a))
        
        fi = fn{kn};
        val = a.(fi); %getfield(a,fi);
        fi(1) = upper(fi(1));
        if ~any(strcmp(fi,{'As','Bs','Cs','Ds','Ks','X0s'}))
            ctrlMsgUtils.error('Ident:idmodel:setstruc1')
        end
        var(kc) = {fi};
        kc = kc+1;
        var(kc) = {val};
        kc = kc+1;
    end
else
    if nargin < 7
        x0 = [];
    end
    if nargin < 6
        k = [];
    end
    if nargin < 5
        d = [];
    end
    if nargin < 4
        c = [];
    end
    if nargin < 3
        b = [];
    end
    if ~isempty(a)
        var(kc) = {'As'};
        var(kc+1) = {a};
        kc = kc+2;
    end
    if ~isempty(b)
        var(kc) = {'Bs'};
        var(kc+1) = {b};
        kc = kc+2;
    end
    if ~isempty(c)
        var(kc) = {'Cs'};
        var(kc+1) = {c};
        kc = kc+2;
    end
    if ~isempty(d)
        var(kc) = {'Ds'};
        var(kc+1) = {d};
        kc = kc+2;
    end
    if ~isempty(k)
        var(kc) = {'Ks'};
        var(kc+1) = {k};
        kc = kc+2;
    end
    if ~isempty(x0)
        var(kc) = {'X0s'};
        var(kc+1) = {x0};
        kc = kc+2;
    end
end
m = pvset(m,var{:});
assignin('caller',inputname(1),m)
