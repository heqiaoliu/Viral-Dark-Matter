function update(this)
%UPDATE Update JumpTo object to react to a new data source

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2010/03/31 18:41:42 $


% Update the maximum number of frames
source = this.hAppInst.DataSource;
if isa(source, 'uiscopes.AbstractBufferedSource')
    this.Maxframe = this.hAppInst.DataSource.Data.NumFrames;
else
    this.Maxframe = 0;
end

% Reset the jumpto frame target.
if this.MaxFrame ~= 0
    this.FrameStr = '1';
end

% Force a dialog update to update the maxframe widget.
this.show(false);

% [EOF]
