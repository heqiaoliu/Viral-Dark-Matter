function h = gethandles(hFDA,varargin)
%GETHANDLES Return the specified handle to an object in FDATool
%   GETHANDLES(HFDA) Returns the handle structure stored in FDATool.
%
%   GETHANDLES(HFDA,FIELD) Returns the handle referred to in FIELD.
%
%   GETHANDLES(HFDA,SUB1,SUB2,...) Returns the handle referred to by
%   the structure path stored in SUB1, SUB2, etc.
%
%   Examples:
%       hFig = fdatool;
%       hDesignFilter = getfdahandles(hFig,'actionFr','btn',1);
%       hMenus = getfdahandles(hFig,'menus','main');
%       hDesignParams = getfdahandles(hFig,'design_params');

%   Author(s): P. Pacheco, P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2007/12/14 15:21:10 $ 

error(nargchk(1,4,nargin,'struct'));

h = get(hFDA, 'Handles');

if nargin > 1,
    h = getfield(h,varargin{:});
end

% [EOF]
