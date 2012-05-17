function varargout = sfexplr( varargin )
    % SFEXPLR Launches the Model Explorer.
    
    %   Jay R. Torgerson
    %   Copyright 1995-2010 The MathWorks, Inc.
    %   $Revision: 1.13.2.2 $  $Date: 2010/05/20 03:35:24 $

    if nargin > 1 && isequal(lower(varargin{1}), 'view')
        objId = varargin{2};
        objUddH = idToHandle(sfroot, objId);
        if isa(objUddH, 'Stateflow.SLFunction')
            varargin{2} = objUddH.getDialogProxy;
        elseif isa(objUddH, 'Stateflow.AtomicSubchart')
            varargin{2} = objUddH.UdiAlias;
        end
    end
    
    if nargout>0
        varargout = cell(1,nargout);
        [varargout{:}] = daexplr(varargin{:});
    else
        daexplr(varargin{:});
    end
