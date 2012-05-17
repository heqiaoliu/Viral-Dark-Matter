function close(h, varargin)
%CLOSE  Hides dialog.

%   Authors: Bora Eryilmaz
%   Revised:
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $ $Date: 2004/12/10 19:25:48 $

if h.isVisible
    % Hide dialog
    awtinvoke(h.Handles.Frame,'hide');
    
    % RE: Needed to properly manage Constr.Selected when dialog becomes visible again
    %     Do it first to remove all constraint listeners.
    h.Constraint = [];
    h.ConstraintList = [];
    
    % RE: Needed to correctly update list of constraints after hiding dialog
    h.Container = [];
end
