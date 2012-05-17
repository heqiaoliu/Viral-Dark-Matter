function registerpanel(hSB, fcnHndl, label, opts)
%REGISTERPANEL Registers a panel with FDATool
%   REGISTERPANEL(hSB,FCNH,LABEL) Registers the panel that will be constructed
%   with the function handle FCNH.  LABEL is a string that identifies the panel
%   and must be a valid field name for a structure.
%
%   REGISTERPANEL(hSB,FCNH,LABEL,OPTS) Registers the panel with the options
%   in the structure OPTS.  These options include:
%
%   'tooltip'   - The Tooltip to the selection button
%   'icon'      - The icon rendered on the selection button.
%                 This icon must be smaller than 25x25 pixels.
%
%   REGISTERPANEL(hSB,STRUCT,LABEL,OPTS) Registers the panel using the optional
%   structure mechanism.  STRUCT is a structure of function handles which
%   contains the following fields:
%
%   'hide'      - Function to hide the panel
%   'show'      - Function to show the panel
%   'setstate'  - Function which will set the state of the panel
%   'getstate'  - Function which will return the state of the panel
%
%   These functions will receive the figure handle of FDATool as their first
%   input argument.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2008/05/31 23:28:18 $

error(nargchk(3,4,nargin,'struct'));

if nargin == 3, opts = []; end

constructors = get(hSB, 'Constructors');
constructors = {constructors{:}, fcnHndl};
set(hSB, 'Constructors', constructors);

labels = get(hSB, 'Labels');
labels = {labels{:}, label};
set(hSB, 'Labels', labels);

thisrender(hSB,'renderselectionbutton', opts);

% [EOF]
