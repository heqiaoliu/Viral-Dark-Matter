function thisrender(this, varargin)
%THISRENDER Render the Selector
%   THISRENDER(hSct, hFig, POS) Render the Selector to the figure hFig with the
%   position POS.
%
%   THISRENDER(hSct, hFig, POS, CTRLPOS) Render the Selector.  CTRLPOS will be used
%   to determine the position of the radiobuttons and popups, instead of POS, which
%   will be used to render the frame and label.  If CTRLPOS is not used POS will
%   determine the position of the controls.
%
%   THISRENDER(hSct, POS) Render the selector to the position POS.  When hFig is
%   not specified, the value stored in the object is used.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.3 $  $Date: 2004/04/13 00:25:27 $

selector_render(this, varargin{:});

% [EOF]
