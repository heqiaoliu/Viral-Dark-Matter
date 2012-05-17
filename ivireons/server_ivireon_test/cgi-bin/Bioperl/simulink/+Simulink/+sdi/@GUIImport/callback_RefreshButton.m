function callback_RefreshButton(this, ~, ~, varargin)

    % Copyright 2010 The MathWorks, Inc.

    if (nargin > 3)
        % Recompute simulation outputs
        this.updateSimOut(varargin{1});
    else
        % Recompute simulation outputs
        this.updateSimOut();
    end
    
    % Update table
    this.transferDataToScreen_refreshTable();
end
