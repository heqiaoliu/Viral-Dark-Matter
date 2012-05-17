function registerpanel(hFDA, varargin)
%REGISTERPANEL Register a panel with FDATool
%   REGISTERPANEL(hFDA,FCNH,LABEL) Registers the panel that will be constructed
%   with the function handle FCNH.  LABEL is a string that identifies the panel
%   and must be a valid field name for a structure.
%
%   REGISTERPANEL(hFDA,FCNH,LABEL,OPTS) Registers the panel with the options
%   in the structure OPTS.  These options include:
%
%   'tooltip'   - The Tooltip to the selection button
%   'icon'      - The icon rendered on the selection button.
%                 This icon must be smaller than 25x25 pixels.
%
%   REGISTERPANEL(hFDA,STRUCT,LABEL,OPTS) Registers the panel using the optional
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
%   $Revision: 1.4.4.1 $  $Date: 2008/05/31 23:28:39 $

hSB = getsidebar(hFDA);

registerpanel(hSB, varargin{:});

% [EOF]
