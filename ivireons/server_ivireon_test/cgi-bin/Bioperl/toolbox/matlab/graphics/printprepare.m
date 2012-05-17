function pj = printprepare( pj, h )
%PRINTPREPARE Method to modify a Figure or Simulink model for printing.
%   It is not always desirable to have output on paper equal that on screen.
%   The dark backgrounds used on screen would saturate paper with toner. Lines
%   and text colored in light shades would be very hard to see if dithered on 
%   standard gray scale printers. Arguments to PRINT and the state of some 
%   Figure properties dictate what changes are required while rendering the 
%   Figure or model for output.
%
%   Ex:
%      pj = PRINTPREPARE( pj, h ); %modifies PrintJob pj and Figure/model h
%
%   See also PRINT, PRINTOPT, PRINTRESTORE.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2008/11/04 21:19:53 $

error( nargchk(2,2,nargin) )

if (~useOriginalHGPrinting())
  error('MATLAB:Print:ObsoleteFunction', 'The function %s should only be called when original HG printing is enabled.', upper(mfilename));
end

% make sure the printjob is validated
if ~pj.Validated
  pj.Handles = {h};
  pj = validate(pj);
end

% call private version.
pj = prepare(pj, h);
