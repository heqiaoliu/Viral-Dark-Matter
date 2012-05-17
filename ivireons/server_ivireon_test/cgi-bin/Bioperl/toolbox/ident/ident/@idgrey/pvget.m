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
%       $Revision: 1.3.4.1 $  $Date: 2009/07/09 20:52:04 $

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
            else
                Value = sys.(Property);
                %Value = builtin('subsref',sys,struct('type','.','subs',Property));
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
    [Validm] = pvget(sys.idmodel);
    [a,b,c,d,k,x0,da,db,dc,dd,dk,dx0] = ssdata(sys);
    
    %%LL%% Here we should make the same modification of NoiseVariance
    Value = [{a;b;c;d;k;x0;da;db;dc;dd;dk;dx0};IDMPropValues(1:end-1); Validm];
end
