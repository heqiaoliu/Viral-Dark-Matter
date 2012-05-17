function L = idmcheck(L,sizes)
%IDMCHECK   Validity check for IDMODEL properties.
%
%   IDMCHECK is used by SET

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.8.4.5 $  $Date: 2008/10/02 18:47:23 $

EmptyStr = {''};
Ny = sizes(1);
Nu = sizes(2);

% Check InputName length
Iname = L.InputName;
if any(strcmp(Iname,'')),Iname=[];end
if Nu==0
    L.InputName = EmptyStr([],1);
elseif length(Iname)>Nu,
    L.InputName = Iname(1:Nu);
elseif length(Iname)<Nu
    if isempty(Iname)
        str=[];
    else
        str = Iname;
    end
    L.InputName = defnum(str,'u',Nu);%EmptyStr(ones(Ny,1),1);
end

% Check OutputName length
Oname = L.OutputName;
if any(strcmp(Oname,'')),Oname=[];end

if length(Oname)>Ny,
    L.OutputName = Oname(1:Ny);
elseif length(Oname)<Ny
    if isempty(Oname)
        str=[];
    else
        str = Oname;
    end
    L.OutputName = defnum(str,'y',Ny);%EmptyStr(ones(Ny,1),1);
end

% Check InputUnit length
Iname = L.InputUnit;
if length(Iname)>Nu,
    L.InputUnit = Iname(1:Nu);
elseif length(Iname)<Nu
    L.InputUnit(length(Iname)+1:Nu,1) = EmptyStr(ones(Nu-length(Iname),1),1);
end

% Check OutputUnit length
Oname = L.OutputUnit;
if length(Oname)>Ny,
    L.OutputUnit = Oname(1:Ny);
elseif length(Oname)<Ny
    L.OutputUnit(length(Oname)+1:Ny,1) = EmptyStr(ones(Ny-length(Oname),1),1);
end

% Check InputDelay length
Id = L.InputDelay;
if isempty(Id)
    L.InputDelay=zeros(Nu,1);
    Id = zeros(Nu,1);
end
if length(Id)>Nu,
    ctrlMsgUtils.warning('Ident:idfrd:idmcheck1')
    L.InputDelay = Id(1:Nu);
elseif length(Id)<Nu
    if length(Id)>1
        ctrlMsgUtils.error('Ident:idfrd:idmcheck2')
    else
        ctrlMsgUtils.warning('Ident:idfrd:idmcheck3')
        L.InputDelay=ones(Nu,1)*Id;%(length(Id)+1:Nu,1) = zeros(Nu-length(Id),1);
    end
end
