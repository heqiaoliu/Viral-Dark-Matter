function sys = pvset(sys,varargin)
%PVSET  Set properties of IDNLHW models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/10/02 18:54:21 $

% Author(s): Qinghua Zhang

ni = nargin;
if ni<3 || ~rem(ni,2)
    ctrlMsgUtils.error('Ident:general:CompletePropertyValuePairs','IDNLHW','idnlhw')
end

error(nargoutchk(1, 1, nargout, 'struct'));

[ny, nu] = size(sys);

estimflag = pvget(sys, 'Estimated');
nbfkmodified = false;

for i=1:2:ni-1,
    % Set each Property Name/Value pair in turn.
    Property = varargin{i};
    Value = varargin{i+1};
    
    % Perform assignment
    switch Property
        case 'nb'
            if ~isnonnegintmat(Value)
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset1','nb')
            end
            if ~isequal(size(Value), [ny, nu])
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset2','nb')
            end
            
            nb = Value;
            % Modify the size of Btail accordingly
            Btail = cell(ny,nu);
            for ky=1:ny
                for ku=1:nu
                    % Btail{ky,ku} = ones(1,nb(ky,ku));
                    Btail{ky,ku} = NaN(1,nb(ky,ku));
                end
            end
            sys.Btail = Btail;
            nbfkmodified = true;
            estimflag = 0;
            
        case 'nf'
            if ~isnonnegintmat(Value)
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset1','nb')
            end
            if ~isequal(size(Value), [ny, nu])
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset2','nf')
            end
            nf = Value;
            % Modify the size of f accordingly
            for ky=1:ny
                for ku=1:nu
                    % F{ky,ku} = ones(1,1+nf(ky,ku));
                    F{ky,ku} = NaN(1,1+nf(ky,ku));
                    F{ky,ku}(1) = 1;
                end
            end
            sys.f = F;
            nbfkmodified = true;
            estimflag = 0;
            
        case 'nk'
            if ~isnonnegintmat(Value)
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset1','nk')
            end
            if ~isequal(size(Value), [ny, nu])
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset2','nk')
            end
            sys.nk = Value;
            nbfkmodified = true;
            estimflag = 0;
            
        case 'b'
            if ~iscell(Value) || ~isequal(size(Value), [ny, nu])
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset3','b',ny,nu)
            end
            empentries = cellfun(@isempty, Value);
            if any(all(empentries,2))
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset4a')
            end
            if ~(all(all(cellfun(@isrealrowvec, Value) | empentries)))
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset3','b',ny,nu)
            end
            nzentries = cellfun(@any, Value);
            if any(~any(nzentries,2))
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset4b')
            end
            
            Btail = cell(ny,nu);
            nk = zeros(ny,nu);
            for ky=1:ny
                for ku=1:nu
                    bkk = Value{ky,ku};
                    indbfirst = find([bkk 1], 1 );
                    nk(ky,ku) = indbfirst-1;
                    Btail{ky,ku} = bkk(indbfirst:end);
                end
            end
            sys.nk = nk;
            sys.Btail = Btail;
            estimflag = -1;
            
        case 'f'
            if ~(iscell(Value) && all(all(cellfun(@isrealrowvec, Value)))) ...
                    || ~isequal(size(Value), [ny, nu])
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset3','f',ny,nu)
            end
            for ky=1:ny
                for ku=1:nu
                    if  Value{ky,ku}(1)~=1
                        ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset5')
                    end
                    %           if all(isfinite(Value{ky,ku}))
                    %             if ~all(abs(roots(Value{ky,ku}))<1.0)
                    %               error('nlident:nonmonicf', ...
                    %                 'Each cell of f must contain the coefficients of a polynomial with roots inside the unitary circle.')
                    %             end
                    %           end
                end
            end
            sys.f = Value;
            estimflag = -1;
            
        case {'InputNonlinearity', 'OutputNonlinearity'}
            if strcmp(Property, 'InputNonlinearity')
                [Value, msg] = nlobjcheck(Value, nu, 'Input');
            else
                [Value, msg] = nlobjcheck(Value, ny, 'Output');
            end
            error(msg)
            sys.(Property) = Value;
            estimflag = -1;
            
        case 'InitialState'
            %
            sys.InitialState = Value;
            estimflag = -abs(estimflag); % -1 if estimflag~=0
            
            % Private property
        case 'ncind'
            if ~isnonnegintmat(Value)
                ctrlMsgUtils.error('Ident:idnlmodel:idnlhwPvset1','ncind')
            end
            sys.ncind = Value;
            
        case 'Algorithm'
            [Value, msg] =  bbalgodef(Value);
            error(msg)
            
            % check Weighting matrix explicitly for its size
            val = Value.Weighting;
            if (size(val,1) ~= ny)
                ctrlMsgUtils.error('Ident:general:incorrectWeighting1',ny);
            end
            
            sys.Algorithm = Value;
            estimflag = -abs(estimflag); % -1 if estimflag~=0
            
        case 'CovarianceMatrix'
            if ~isempty(Value) && isnumeric(Value) && estimflag
                if ndims(Value)~=2
                    ctrlMsgUtils.error('Ident:idnlmodel:invalidCovarianceMatrix')
                end
                np = numel(getParameterVector(sys));
                [nrows, ncols] = size(Value);
                if nrows~=np || ncols~=np
                    ctrlMsgUtils.error('Ident:general:CovarianceMatrixNotSquare')
                end
            elseif ischar(Value)
                [value, msg] = strchoice({'estimate', 'none'}, Value);
                if ~isempty(msg)
                    ctrlMsgUtils.error('Ident:idnlmodel:invalidCovarianceMatrix')
                end
            end
            sys.CovarianceMatrix = Value;
            estimflag = -abs(estimflag); % -1 if estimflag~=0
            
        case 'EstimationInfo'
            sys.EstimationInfo = Value;
            
        case 'Ts'
            % Ts>0 for IDNLHW models
            sys.idnlmodel = pvset(sys.idnlmodel,'Ts',Value);
            if Value==0
                ctrlMsgUtils.error('Ident:general:positiveNumPropVal','Ts')
            end
            
        otherwise
            % IDNLMODEL properties (other than Ts)
            sys.idnlmodel = pvset(sys.idnlmodel, Property, Value);
            estimflag = -abs(estimflag); % -1 if estimflag~=0
            
    end % switch
end % for

if nbfkmodified
    msg = nbfkchck(pvget(sys,'nb'), pvget(sys,'nf'), pvget(sys,'nk'));
    error(msg)
    sys.InputNonlinearity = initreset(sys.InputNonlinearity);
    sys.OutputNonlinearity = initreset(sys.OutputNonlinearity);
end

if ~strcmp(Property, 'Estimated') && pvget(sys, 'Estimated')
    if estimflag~=1 && pvget(sys, 'Estimated')==1 && ~strcmp(Property, 'EstimationInfo')
        sys.EstimationInfo.Status = 'Model modified after last estimate';
    end
    sys = pvset(sys, 'Estimated', estimflag);
end

% FILE END
