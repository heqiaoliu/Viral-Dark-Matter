% Link   Link
%

%    Copyright 2009 The Mathworks, Inc.

classdef Link < rptgen.idoc.Group
    
    properties (Dependent)
        Target;
        IsInternal;
    end
    
    % Accessor methods
    methods
        function Target = get.Target(this)
            Target = this.Doms.target;
        end
        
        function set.Target(this, newTarget)
            transaction = this.Document.createTransaction();
            if (isa(newTarget, 'rptgen.idoc.Node'))
                this.Doms.setTarget(newTarget.Doms.asImmutable());
            else
                this.Doms.setTarget(newTarget);
            end
            transaction.commit();
        end
        
        function IsInternal = get.IsInternal(this)
            IsInternal = this.Doms.isInternal;
        end
        
        function set.IsInternal(this, newIsInternal)
            transaction = this.Document.createTransaction();
            this.Doms.isInternal = newIsInternal;
            transaction.commit();
        end
    end
    
    methods
        function this = Link(varargin)
            this = this@rptgen.idoc.Group(varargin{:});
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsLink();
        end
        
        function initialize(this,varargin)
            if ~isempty(varargin)
                this.Target = varargin{1};
            end
            
            if (length(varargin) > 1)
                this.import(varargin{2});
            end
        end
    end
end
