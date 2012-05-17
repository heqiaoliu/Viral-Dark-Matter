function oldval = showNotImplementedDialog( varargin )
    % showNotImplementedDialog: This funciton sets a persistent flag
    % indicating whether we want to show a message box when someone clicks
    % a menu or toolbar item that hasn't yet been implemented. This is so
    % we can have a message box for interactive use and not have it for 
    % automated use.
	persistent ison;
    if isempty( ison )
        ison = true;
    end
	oldval = ison;
	if nargin == 1
		ison = varargin{1};
	end
end