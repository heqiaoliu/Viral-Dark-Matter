function Close(this, varargin)

    % Copyright 2009-2010 The MathWorks, Inc.
    if(nargin > 1)
        this.guiForceClose = varargin{1};        
    end
    
    close(this.HDialog);
end