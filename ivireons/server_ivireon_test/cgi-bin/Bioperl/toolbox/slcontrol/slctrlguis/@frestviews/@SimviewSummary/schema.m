function schema
% SCHEMA Class definition for @SimviewSummary (bird eye view pane in
% simview figure)

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:50:02 $

% Find parent package
pkg = findpackage('frestviews');
% Register class
c = schema.class(pkg, 'SimviewSummary');

% Class attributes
schema.prop(c, 'SummaryBode', 'handle'); %@bodeplot of resppack
schema.prop(c, 'XRangeSelectors', 'MATLAB array');   % @XRangeSelector of resppack
schema.prop(c, 'SelectorListeners', 'MATLAB array');   % Listeners for xrangeselectors
