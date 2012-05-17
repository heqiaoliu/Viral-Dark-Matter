function Value = get(sys,Property)
%GET  Access/query IDDATA property values.
%
%   VALUE = GET(DAT,'Property')  returns the value of the specified
%   property of the IDDATA set DAT.
%
%   Without left-hand argument,  GET(DAT)  displays all properties
%   of DAT and their values.
%
%   See also IDDATA/SET.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.11.2.6 $ $Date: 2008/10/02 18:46:49 $

ni = nargin;
error(nargchk(1,2,ni,'struct'));

if ni==2,
    CharProp = ischar(Property);
    if CharProp,
        Property = {Property};
    elseif ~iscellstr(Property)
        ctrlMsgUtils.error('Ident:general:invalidPropertyName1')
    end
end

AllProps = pnames(sys);
%AllValues = pvalues(sys);
if strcmpi(sys.Domain,'frequency')
    freqflag = 1;
    tsnames = AllProps(11:14);
    fsnames = {'Ts';'Units';'Frequency';'TimeUnit'};
    AllProps(11:14)= fsnames;
    %    AsgnValues(11:14)={ 'Sampling Interval (0 means continuous time data)';...
    %          'Scalar  (First frequency)';...
    %          'N-vector of frequencies';...
    %          'String: Frequency unit'};
else
    freqflag = 0;
end
if nargin ==2
    % Loop over each queried property
    Nq = numel(Property);
    Value = cell(1,Nq);
    for i=1:Nq,
        % Find match for k-th property name and get corresponding value
        % RE: a) Must include all properties to detect multiple hits
        %     b) Limit comparison to first 7 chars (because of OutputName)
        Pr = Property{i};
        if strcmpi(Pr,'n'),Pr='ns';end
        if strcmpi(Pr(1),'n')&& ~strcmpi(Pr(2),'o') && ~strcmpi(Pr(2),'a')
            y=sys.OutputData;u=sys.InputData; if isempty(y),y={[]};end
            if isempty(u),u={[]};end
            Ncap=[];Ny=size(y{1},2);Nu=size(u{1},2);
            for kk=1:length(y)
                Ncap = [Ncap,max(size(y{kk},1),size(y{kk},1))];
            end
            if strcmpi(Pr,'ns')
                Value{i}=Ncap;
            elseif strcmpi(Pr,'ny')
                Value{i}=Ny;
            elseif strcmpi(Pr,'nu')
                Value{i} = Nu;
            elseif strcmpi(Pr,'ne')
                Value{i}=length(y);
            else
                ctrlMsgUtils.error('Ident:general:invalidProperty',Pr,'IDDATA');
            end
        else
            try
                prop = pnmatchd(Pr,AllProps,7);
                if freqflag
                    fsind = strmatch(prop,fsnames,'exact');
                    if ~isempty(fsind)
                        prop = tsnames(fsind);
                    end
                end
                Value{i} = pvget(sys,prop);
            catch E
                throw(E)
            end
        end
    end
    % Strip cell header if PROPERTY was a string
    if CharProp,
        Value = Value{1};
    end
    if  isa(Value,'cell') && length(Value)==1
        if length(prop) <5
            Value = Value{1};
        elseif ~any(strcmpi(prop(end-3:end),{'unit','name'}))
            Value = Value{1};
        end
    end
elseif nargout,

    Value = cell2struct(pvget(sys),AllProps,1);
else
    vals = pvget(sys);
    props = AllProps;
    for kk=[3,6,9,10,11,12,13,15]
        if length(vals{kk})==1
            vals{kk} = vals{kk}{1};
        end
    end

    propse = cell(19,1);
    valse = cell(19,1);
    propse([1 2 3 5 6 7 9:19]) = props(1:17);
    valse([1 2 3 5 6 7 9:19]) =vals(1:17);
    propse{4} = 'y';
    valse{4} = 'Same as OutputData';
    propse{8} = 'u';
    valse{8} = 'Same as InputData';
    cell2struct(valse,propse,1)
end

% end iddata/get.m