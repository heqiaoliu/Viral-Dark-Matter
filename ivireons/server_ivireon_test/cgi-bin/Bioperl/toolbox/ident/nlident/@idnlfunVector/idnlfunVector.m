classdef  (CaseInsensitiveProperties = true, TruncatedProperties = true) idnlfunVector < idnlfun
    %idnlfunVector Create array of multiple nonlinearity estimator objects.
    % This object is not instantiated directly. It comes into existence
    % when nonlinearity estimator objects are concatenated. Example:
    %   Obj1  = treepartition
    %   Obj2 = wavenet
    %   ObjArray = [Obj1, Obj2]
    % ObjArray is an object of class idnlfunVector.
    %
    % Usage: idnlfunVector objects are used for representation of
    % nonlinearities in IDNLARX and IDNLHW models containing more than one
    % channels.
    
    % Copyright 2005-2008 The MathWorks, Inc.
    % $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:53:43 $
    
    % Author(s): Qinghua Zhang
    
    properties (Hidden = true)
        % Note: GetAccess and SetAccess must be 'public' to be accessible outside @idnlfunVector
        ObjVector = {};
    end
    
    methods %(Access = 'public')
        function this = idnlfunVector(varargin)
            for k=1:nargin
                if ~isa(varargin{k}, 'idnlfun')
                    ctrlMsgUtils.error('Ident:idnlfun:vectorCheck1')
                end
            end
            this.ObjVector = varargin(:);
        end
        
        %------------------------------------------------------
        function display(this)
            disp(sprintf('%dx1 array of nonlinearity estimator objects', numel(this.ObjVector)));
        end
        
        %------------------------------------------------------
        function result = subsref(this,refstruct)
            StrucL = length(refstruct);
            switch refstruct(1).type
                case '.'
                    ctrlMsgUtils.error('Ident:idnlfun:vectorCheck2')
                case '()'
                    if length(refstruct(1).subs)>1
                        for ks=2:length(refstruct(1).subs)
                            indk = refstruct(1).subs{ks};
                            if ~isequal(indk, ':') && ~isequal(indk, 1)
                                ctrlMsgUtils.error('Ident:idnlfun:vectorCheck3')
                            end
                        end
                    end
                    refarg = refstruct(1).subs{1};
                    if ischar(refarg) && refarg==':'
                        refarg = 1:numel(this.ObjVector);
                    end
                    if StrucL>=1 && isposintmat(refarg)
                        if any(refarg>numel(this.ObjVector))
                            ctrlMsgUtils.error('Ident:idnlfun:vectorCheck4')
                        end
                        if isscalar(refarg)
                            result = this.ObjVector{refarg};
                        else
                            result = idnlfunVector(this.ObjVector{refarg(:)});
                        end
                        if StrucL>1
                            result = subsref(result,refstruct(2:StrucL));
                        end
                    else
                        ctrlMsgUtils.error('Ident:idnlfun:vectorCheck5')
                    end
                otherwise
                    ctrlMsgUtils.error('Ident:general:unSupportedSubsrefType',...
                        refstruct(1).type,'IDNLFUNVECTOR')
            end
        end
        
        %------------------------------------------------------
        function this = subsasgn(this, refstruct,value)
            
            if nargin==1,
                return
            end
            StrucL = length(refstruct);
            switch refstruct(1).type
                case '.'
                    ctrlMsgUtils.error('Ident:idnlfun:vectorCheck6')
                case '()'
                    if length(refstruct(1).subs)>1
                        for ks=2:length(refstruct(1).subs)
                            indk = refstruct(1).subs{ks};
                            if ~isequal(indk, ':') && ~isequal(indk, 1)
                                ctrlMsgUtils.error('Ident:idnlfun:vectorCheck7')
                            end
                        end
                    end
                    refarg = refstruct(1).subs{1};
                    if ischar(refarg) && refarg==':'
                        refarg = 1:numel(this.ObjVector);
                    end
                    if StrucL>=1 && isposintmat(refarg)
                        if any(refarg>numel(this.ObjVector))
                            ctrlMsgUtils.error('Ident:idnlfun:vectorCheck4')
                        end
                        if StrucL==1
                            if isscalar(refarg)
                                if isempty(value)
                                    % Remove the component
                                    this.ObjVector(refarg) = [];
                                elseif isa(value, 'idnlfun') && isscalar(value)
                                    this.ObjVector{refarg} = value;
                                elseif ischar(value)
                                    nlnames = idnlfunclasses;
                                    ind = strmatch(lower(strtrim(value)), nlnames);
                                    if length(ind)>1
                                        ctrlMsgUtils.error('Ident:idnlfun:ambiguousNLName')
                                    end
                                    if ~isempty(ind)
                                        value = nlnames{ind(1)};
                                    else
                                        ctrlMsgUtils.error('Ident:idnlfun:invalidNLName',value);
                                    end
                                    this.ObjVector{refarg} = feval(value);
                                else
                                    ctrlMsgUtils.error('Ident:idnlfun:vectorCheck8')
                                end
                                
                            else % Non scalar refarg
                                
                                if ~(isempty(value) || (isa(value, 'idnlfun') && numel(value)==length(refarg)))
                                    ctrlMsgUtils.error('Ident:idnlfun:vectorCheck9')
                                end
                                
                                if isempty(value)
                                    this.ObjVector(refarg) = [];
                                elseif isa(value, 'idnlfunVector')
                                    this.ObjVector(refarg) = value.ObjVector;
                                else
                                    for ki=1:length(refarg)
                                        this.ObjVector{refarg(ki)} = value(ki);
                                    end
                                end
                            end
                        else  %StrucL>1
                            if ~isscalar(refarg)
                                ctrlMsgUtils.error('Ident:idnlfun:vectorCheck10')
                            end
                            this.ObjVector{refarg} = subsasgn(this.ObjVector{refarg},refstruct(2:end),value);
                        end
                    else
                        ctrlMsgUtils.error('Ident:idnlfun:vectorCheck11')
                    end
                otherwise
                    ctrlMsgUtils.error('Ident:general:unknownSubsasgn',refstruct(1).type,'IDNLFUNVECTOR')
            end
            
            if numel(this.ObjVector)==1
                % idnlfunVector containing a single idnlfun object is converted to idnlfun
                this = this.ObjVector{1};
            end
        end
        
        %------------------------------------------------------
        function s = length(this)
            s =numel(this.ObjVector);
        end
        
        %------------------------------------------------------
        function s = numel(this)
            s =numel(this.ObjVector);
        end
        
        %------------------------------------------------------
        function status = isscalar(this)
            status = numel(this.ObjVector)==1;
        end
        
    end %methods
    
end %class

% FILE END