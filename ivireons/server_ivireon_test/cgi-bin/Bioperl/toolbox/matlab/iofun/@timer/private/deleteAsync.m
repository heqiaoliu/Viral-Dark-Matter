function deleteAsync(obj, event)
%Private helper function for deletion of the timer objects.  This function
%is called asynchronously, through timercb, when a timer is to be deleted.
%An asynchronous call ensures that any other events in the queue, like a
%stop, are handled first.

% Copyright 2004-2007 The MathWorks, Inc.

len = length(obj);
for lcv=1:len
    try
        obj.jobject(lcv).dispose;
		obj.jobject(lcv).delete;
		mltimerpackage('Delete',obj.jobject(lcv));
    catch exc %#ok<NASGU>
    end
end