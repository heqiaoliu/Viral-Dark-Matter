function Value = pvget(sys,Property)
%PVGET  Get values of public IDMODEL properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%       Copyright 1986-2009 The MathWorks, Inc.
%       $Revision: 1.12.4.5 $  $Date: 2009/07/09 20:52:10 $

error(nargchk(1, 2, nargin, 'struct'));

if nargin==2
    % Value of single property: VALUE = PVGET(SYS,PROPERTY)
    % Public IDPOLY properties
    switch Property
        case pnames(sys,'specific')
            Ind = strmatch(Property,{'A','B','C','D','K','X0','dA','dB','dC','dD','dK','dX0'},'exact');
            if ~isempty(Ind)
                [V{1:Ind}] = ssdata(sys);
                Value = V{end};
            elseif strcmp(Property,'nk')
                if isempty(sys.Ds)
                    Value = zeros(1,0);
                elseif strcmp(sys.SSParameterization,'Structured')
                    nks = (sys.Ds~=0);
                    if size(nks,1)>1
                        nks = max(nks);
                    end
                    Value = 1-nks;
                else
                    Value = findnk(sys.As,sys.Bs,sys.Ds);
                end
            elseif strcmp(Property,'DisturbanceModel')
                if any(any(isnan(sys.Ks))')
                    Value = 'Estimate';
                elseif norm(sys.Ks)==0
                    Value = 'None';
                else
                    Value = 'Fixed';
                end
            else
                Value = sys.(Property);
            end
        case 'idmodel'
            Value = sys.idmodel;
        otherwise
            % parent property, including algorithm and estimation info
            % values
            Value = pvget(sys.idmodel,Property);
    end
else
    % Return all public property values
    % RE: Private properties always come last in IDMPropValues
    %IDMPropNames = pnames(sys,'specific');
    IDMPropValues = struct2cell(sys);
    [Validm]=pvget(sys.idmodel);
    [a,b,c,d,k,x0,da,db,dc,dd,dk,dx0]=ssdata(sys);
    if isempty(sys.Ds)
        nk = zeros(1,0);
    elseif strcmp(sys.SSParameterization,'Structured')
        nks = (sys.Ds~=0);
        if size(nks,1)>1
            nks = max(nks);
        end
        nk = 1-nks;
    else
        nk = findnk(sys.As,sys.Bs,sys.Ds);
    end
    %    try
    %       nk = ones(1,size(sys.Ds,2))-max(isnan(sys.Ds)); %MORE FANCY DELAYS
    %    catch
    %       nk =[];
    %    end
    %
    if any(any(isnan(sys.Ks))')
        DisturbanceModel = 'Estimate';
    elseif norm(sys.Ks)==0
        DisturbanceModel = 'None';
    else
        DisturbanceModel = 'Fixed';
    end
    
    Value = [{a;b;c;d;k;x0;da;db;dc;dd;dk;dx0};IDMPropValues(1:end-2);...
        {nk;DisturbanceModel; };IDMPropValues(end-1);Validm];
end
