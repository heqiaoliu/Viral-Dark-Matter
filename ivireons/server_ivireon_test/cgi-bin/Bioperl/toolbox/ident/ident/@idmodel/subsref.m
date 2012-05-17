function L = subsref(L,Struct)
%SUBSREF  Subsref method for IDMODEL models
%   The following reference operations can be applied to any IDMODEL
%   object MOD:
%      MOD(Outputs,Inputs)     select subsets of I/O channels.
%      MOD.Fieldname           equivalent to GET(MOD,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in MOD(1,[2 3]).inputname or
%   MOD.cov(1:3,1:3)
%
%   The channel reference can be made by numbers or channel names:
%     MOD('velocity',{'power','temperature'})
%   For single output systems MOD(ku) selects the input channels ku
%   while for single input systems MOD(ky) selcets the output
%   channels ky.
%
%   MOD('measured') selects just the measured input channels and
%       ignores the noise inputs.
%   MOD('noise') gives a time series (no measured input channels)
%       description of the additive noise properties of MOD.
%
%   To jointly address measured and noise channels, first convert
%   the noise channels using NOISECNV.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.10.2.7 $ $Date: 2009/03/09 19:13:41 $

ni = nargin;
if ni==1,
    return
end
StructL = length(Struct);

% Peel off first layer of subreferencing
switch Struct(1).type
    case '.'
        % The first subreference is of the form sys.fieldname
        % The output is a piece of one of the system properties
        try
            if StructL==1,
                result = get(L,Struct(1).subs);
            else
                tmpval = get(L,Struct(1).subs);
                %{
                if isstruct(tmpval) && isfield(tmpval,'SearchMethod')
                    tmpval.SearchDirection = tmpval.SearchMethod;
                end
                %}
                result = subsref(tmpval,Struct(2:end));
            end
            L = result;
        catch E
            throw(E)
        end
    case '()'
        indices = Struct(1).subs;
        indrow = indices{1};
        indcol = indices{2};


        % Set output names and output groups
        L.OutputName = L.OutputName(indrow);%,1);
        L.OutputUnit = L.OutputUnit(indrow);%,1);


        % Set input names and input groups
        L.InputName = L.InputName(indcol);%,1);
        L.InputUnit = L.InputUnit(indcol);%,1);
        L.InputDelay = L.InputDelay(indcol);
        L.NoiseVariance = L.NoiseVariance(indrow,indrow);

        L.Algorithm.Weighting = L.Algorithm.Weighting(indrow,indrow);

    otherwise
        ctrlMsgUtils.error('Ident:general:unSupportedSubsrefType',Struct(1).type,upper(class(L)))
end
