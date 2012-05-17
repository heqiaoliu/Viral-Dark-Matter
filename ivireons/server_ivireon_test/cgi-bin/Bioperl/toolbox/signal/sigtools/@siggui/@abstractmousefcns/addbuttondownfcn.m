function addbuttondownfcn(this, hg, interrupt)
%ADDBUTTONDOWNFCN Add the AxesTool button down function to an HG object
%   ADDBUTTONDOWNFCN(H, HG) Add the AxesTool buttondown function to HG.  The
%   HG Object will now send the ButtonDown event as its button down function.
%   
%   This can only be done for an axes or one of its children.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2010/05/20 03:10:34 $

% This should be a private method

error(nargchk(2,3,nargin,'struct'));

if isempty(hg), return; end

if nargin < 3, interrupt = 'off'; end

hax = ancestor(hg, 'axes');
if isempty(hax)
    error(generatemsgid('GUIErr'),'Input must be an axes or the child of an axes.');
end

set(hg, 'ButtonDownFcn', @(hcbo, ev) abstract_buttondownfcn(this, hcbo), ...
    'Interruptible', interrupt);

% [EOF]
