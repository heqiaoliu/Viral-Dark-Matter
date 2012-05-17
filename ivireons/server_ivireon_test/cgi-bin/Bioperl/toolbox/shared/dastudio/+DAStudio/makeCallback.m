function callback = makeCallback( varargin )
	% This function converts a function taking one parameter into
	% a function taking a variable number of parameters. It is assumed
	% that for our purposes the last parameter is the function handle,
	% and the rest are the additional parameters.
	len = length( varargin );
	if len > 1 
		callback = @(cbinfo)varargin{len}( varargin{1:len-1}, cbinfo );
	else
		callback = @(cbinfo)varargin{1}(cbinfo);
	end			
end