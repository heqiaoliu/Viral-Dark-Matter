function randomInit( idx )
%randomInit - initialise the random state for a task

%  Copyright 2006-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.6 $    $Date: 2009/04/15 22:57:41 $ 

randset = fix( 2^10 * idx * pi );
stream = RandStream('mt19937ar','seed',randset);
RandStream.setDefaultStream(stream);
