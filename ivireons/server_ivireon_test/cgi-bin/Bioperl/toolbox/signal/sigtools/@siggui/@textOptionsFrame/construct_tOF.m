function construct_tOF(h, varargin)
%CONSTRUCT_TOF  handle inputs and defaults for the textOptionsFrame here

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:10:15 $

if nargin > 1 , set(h, 'Text', varargin{1}); end % Set the Text property
if nargin > 2 , set(h, 'Name', varargin{2}); end % Set the Name property 

% Set the tag using the siggui inherited method
settag(h);

% [EOF]
