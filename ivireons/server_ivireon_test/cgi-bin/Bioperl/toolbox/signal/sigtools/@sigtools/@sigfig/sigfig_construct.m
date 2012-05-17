function sigfig_construct(this, varargin)
%SIGFIG_CONSTRUCT Create the contained figure

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2009/01/05 18:02:17 $

hFig = figure(varargin{:});

set(this, 'FigureHandle', hFig);

addlistener(hFig, 'ObjectBeingDestroyed', @(h, ev) lclfbd_listener(this));
this.ObjectBeingDestroyedListener = ...
    handle.listener(this, 'ObjectBeingDestroyed', @(h, ev) lclobd_listener(hFig));

%-------------------------------------------------------------------
function lclfbd_listener(this)
%Local Figure Being Deleted Listener

cleanup(this);
delete(this);

%-------------------------------------------------------------------
function lclobd_listener(hFig)
%Local Object Being Deleted Listener

delete(hFig);

% [EOF]
