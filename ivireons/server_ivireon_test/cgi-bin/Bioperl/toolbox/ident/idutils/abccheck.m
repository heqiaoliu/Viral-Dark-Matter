function statusstruc = abccheck(a,b,c,d,k,x0,cas)
%ABCCHECK  check consistency of state space matrices

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2009/10/16 04:56:30 $

statusstruc =  struct([]);

[nx,nd] = size(a);
[nd4,nu] = size(b);
[ny,nd5] = size(c);
[nd1,nd2] = size(d);
[nd6,nd7] = size(k);
[nd8,nd9] = size(x0);

status = '';
arg = {};
if nx ~= nd
    arg = {'A'};
    id = 'Ident:utility:SSASize2';
elseif nx ~= nd4 && nu~=0
    arg = {'A','B'};
    id = 'Ident:utility:SSSameRows';
elseif nx ~= nd5
    arg = {'A','C'};
    id = 'Ident:utility:SSSameColumns';
elseif nd1 ~= ny && nu~=0
    arg = {'C','D'};
    id = 'Ident:utility:SSSameRows';
elseif nd2 ~= nu
    arg = {'B','D'};
    id = 'Ident:utility:SSSameColumns';
elseif nd6 ~= nx
    arg = {'A','K'};
    id = 'Ident:utility:SSSameRows2';
elseif nd7 ~= ny
    arg = {'K','C'};
    id = 'Ident:utility:SSCKSizeCompatib2';
elseif nd8~=nx || nd9~=1
    arg = {'X0'};
    id = 'Ident:utility:SSX0Len2';
end

if ~isempty(status)
    if strcmp(cas,'nan')
        arg = cellfun(@(x)[x,'s'],arg,'UniformOutput',false);
        status = ['Misspecified structure matrices for the IDSS model: ',ctrlMsgUtils.message(id,arg{:})];
    else
        status = ['Misspecified model matrices for the IDSS model: ',ctrlMsgUtils.message(id,arg{:})];
    end
    statusstruc = struct('message',status,'identifier',id);
end
