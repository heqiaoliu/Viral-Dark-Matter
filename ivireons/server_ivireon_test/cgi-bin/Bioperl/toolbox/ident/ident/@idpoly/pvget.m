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

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.5 $  $Date: 2009/12/05 02:03:37 $

error(nargchk(1, 2, nargin, 'struct'));

if nargin==2
    % Value of single property: VALUE = PVGET(SYS,PROPERTY)
    % Public IDPOLY properties
    switch Property
        case pnames(sys,'specific')
            Ind = strmatch(Property,{'a','b','c','d','f','da','db','dc','dd','df'},'exact');
            if ~isempty(Ind)
                [V{1:Ind}] = polydata(sys);
                Value = V{end};
            else
                Value = sys.(Property);
            end
        case 'BFFormat'
            Value = sys.BFFormat;
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
    hw = ctrlMsgUtils.SuspendWarnings;
    [a,b,c,d,f,da,db,dc,dd,df] = polydata(sys);
    delete(hw)
    % remove BFFormat and idmodel from IDMPropValues list
    Value = [{a;b;c;d;f;da;db;dc;dd;df}; IDMPropValues(1:end-2); Validm];
end
