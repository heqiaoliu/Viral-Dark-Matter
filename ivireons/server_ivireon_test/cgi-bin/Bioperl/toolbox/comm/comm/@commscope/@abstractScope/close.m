function close(this)
%CLOSE  Close a communications scope
%   CLOSE(H) method closes the figure of the communications scope object H.
%
%   EXAMPLES:
%
%     % Create an eye diagram scope object
%     h = commscope.eyediagram;
%     % Call the plot method to display the scope
%     plot(h);
%     % Close the scope
%     close(h)
%     
%   See also COMMSCOPE, COMMSCOPE.EYEDIAGRAM.

%   @commscope/@abstractScope
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/10 21:19:16 $

if ( this.isScopeAvailable )
    close(this.PrivScopeHandle);
end
%-------------------------------------------------------------------------------
% [EOF]
