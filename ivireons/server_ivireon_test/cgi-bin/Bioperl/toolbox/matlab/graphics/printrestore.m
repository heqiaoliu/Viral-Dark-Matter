function pj = printrestore( pj, h )
%PRINTRESTORE Reset a Figure or Simulink model after printing.
%   When printing a model or Figure, some properties have to be changed
%   to create the desired output. PRINTRESTORE resets the properties back to 
%   their original values.
%
%   Ex:
%      pj = PRINTRESTORE( pj, h ); %modifies PrintJob pj and Figure/model h
%
%   See also PRINT, PRINTOPT, PRINTPREPARE.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2008/11/04 21:19:54 $


error( nargchk(2,2,nargin) )

if (~useOriginalHGPrinting())
    error('MATLAB:Print:ObsoleteFunction', 'The function %s should only be called when original HG printing is enabled.', upper(mfilename));
end

% call private version.
pj = restore(pj, h);

