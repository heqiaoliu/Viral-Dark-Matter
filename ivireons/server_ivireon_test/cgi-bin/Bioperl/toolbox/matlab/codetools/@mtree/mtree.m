classdef mtree
%MTREE  Create and manipulate M parse trees
%   This is an experimental program whose behavior and interface is likely
%   to change in the future.

% Copyright 2006-2010 The MathWorks, Inc.
 
    properties (SetAccess='protected', GetAccess='protected', Hidden)
        T    % parse tree array
                 % column 1: kind of node
                 % column 2: index of left child
                 % column 3: index of right child
                 % column 4: index of next node
                 % column 5: position of node
                 % column 6: size of node
                 % column 7: symbol table index (V)R/
                 % column 8: string table index
                 % column 9: index of parent node
                 % column 10: setting node
                 % column 11: lefttreepos
                 % column 12: righttreepos
                 % column 13: true parent
                 % column 14: righttreeindex
                 % column 15: rightfullindex
        S    % symbol table
        C    % character strings
        IX   % index set (default is true for everything)
        n    % number of nodes
        m    % sum(IX)
        lnos % line number translation
        str  % input string that created the tree
    end
    properties (GetAccess='public', Constant, Hidden)
        N  = mtree_info(1)  % node names
        K  = mtree_info(2)  % node key
        KK = mtree_info(3)  % the internal names (for debugging)
        Uop = mtree_info(4) % true if node is a unary op
        Bop = mtree_info(5) % true if node is a binary op
        Stmt = mtree_info(6) % true if node is a statement
        Linkno = mtree_info(7) % maps link to index
        Lmap = mtree_info(8) % link map
        Linkok = mtree_info(9) % is link OK for a given node
        PTval = mtree_info(10) % array of nodes whose V is a position value
        V  = { '2.50', '2.50' };   % version array
    end
    methods
        function [v1,v2] = version(o)
        %VERSION  [v1,v2] = version(tree) returns the Mtree version numbers
            v1 = o.V{1};
            v2 = o.V{2};
        end
    end
    methods (Access='protected')
        % housekeeping methods
        function L = linelookup( o, P )
        %LINELOOKUP  (Mtree internal function to look up lines)
            np = length(P);
            L = zeros( np, 1 );
            if np==0
                return;
            end
            LL = o.lnos;
            ln = length(LL);
            guess = max( floor(ln*(P(1)/LL(end))), 1);  % first guess
            for i=1:np
                if( LL(guess) < P(i) )
                    % go up
                    if guess >= ln
                        guess = ln+1;
                    else
                        for j=guess+1:ln
                            if( LL(j) >= P(i) )
                                guess = j-1;
                                break
                            end
                            if( j == ln )
                                guess = ln+1;
                                break
                            end
                        end
                    end
                else
                    % go down
                    if guess ~= 1
                        for j=guess-1:-1:1
                            if( LL(j) < P(i)  )
                                guess = j;
                                break
                            end
                            if j == 1
                                guess = 1;
                                break
                            end
                        end
                    end
                end
                L(i) = guess;
            end
        end
    end
    methods
        % CONSTRUCTOR
        function o = mtree( text, varargin )
        %MTREE  o = MTREE( text, options ) constructs an mtree object
        %
        % Options include:
        %     -file:  the text argument is treated as a filename
        %     -comments:   comments are included in the tree
        %     -cell:  cell markers are included in the tree
            if nargin == 0 || ~ischar( text )
                error( 'matlab:mtree:usage', ...
                       'Usage: mtree( text [, options] ): options ''-file'', ''-cell'', ''-comments''.' );
            end
            opts = {};
            for i=1:nargin-1
                if strcmp( varargin{i}, '-file' )
                    try
                        fname = text;
                        text = fileread(text);
                    catch x 
                        error( 'matlab:mtree:input', ...
                            'cannot read input file %s', fname );
                    end

                else
                    switch varargin{i}
                        case '-comments'
                            opts{end+1} = '-com'; %#ok<AGROW>
                        otherwise
                            opts{end+1} = varargin{i}; %#ok<AGROW>
                    end
                end
            end
            % o = ckversion( o );
            % now, sanitize text by replacing all non-ascii characters by
            % ?
            o.str = text;
            for i=1:length(text)
                if double(text(i)) > 127
                    text(i) = '?';
                end
            end
            loc = feature( 'locale' );
            ja = false;
            if strcmp( loc.ctype, 'ja_JP.Shift_JIS' )
                opts = [ { '-ja' } opts ];
                ja = true;
            end
            [o.T,o.S,o.C] = mtreemex( text, opts{:} );
            % this code needs to be clever about old MAC files
            L1 = text==char(10);
            if sum(L1)==0  % there are no newlines in the file 
                L1 = text==char(13);
            end
            o.lnos = [ 0 find(L1) length(text) ]';
            o = wholetree( o );
            % fix up strings to be UTF-16
            TT = o.T;
            err = o.K.ERR;
            CC = o.C;
            sstr = o.str;
            for i=1:size(TT,1)
                cx = TT(i,8);
                pos = TT(i,5);
                sz = TT(i,6);
                if ~cx || ~pos || ~sz 
                    continue
                elseif TT(i,1) == err
                    if ~ja
                        continue;
                    end
                else
                    CC{cx} = sstr( pos:(pos+sz-1) );
                end
            end
            o.C = CC;
        end
        % return the full tree (without JOIN nodes)
        function o = wholetree( o )
        %WHOLETREE  o = WHOLETREE(o) the whole tree from a subset of nodes
            nt = size( o.T, 1 );
            if nt==0
                i = 0;
            else
                % empty range in MATLAB sets i to []
                for i=nt:-1:1
                    if o.T(i,1) ~= o.K.JOIN 
                        break;
                    end
                end
            end
            o.n = i;
            o.m = o.n;
            o.IX = true( 1, o.n );
        end
    end
    methods (Hidden)
        function b = eq( o, oo )
        %EQ  Mtree == operator
            b = sametree(o,oo) && o.n == oo.n && o.m==oo.m && ...
                    all( o.IX==oo.IX );
        end
        function b = ne( o, oo )
        %NE  Mtree ~= operator
            b = ~sametree(o,oo) || o.m~=oo.m || o.n ~= oo.n || ...
                    any( o.IX~=oo.IX );
        end
        function b = le( o, oo )
        %LE  Mtree <= operator (returns true if first argument is a subset
        %    of the second)
            b = sametree(o,oo) && all( ~o.IX | oo.IX );
        end
        function o = subtree(o)
        %SUBTREE  subtree is deprecated -- use Tree
            o = Tree(o);
        end
        function o = fullsubtree( o )
        %FULLSUBTREE is deprecated -- use Full
            o = Full(o);
        end
        function o = list(o)
        %LIST  list is deprecated -- use List
            o = List(o);
        end
        function o = full(o)
        %full  full is deprecated -- use wholetree
            o = wholetree(o);
        end
        function b = isfull(o)
        %isfull  isfull is deprecated -- use iswhole
            b = iswhole(o);
        end
    end
    methods
        function m = count( o )
        %COUNT  m = count( obj ) returns the number of Mtree nodes in obj
            m = o.m;
        end
        function oo = root( o )
        %ROOT  r = ROOT( obj ) returns the root of the Mtree obj
            oo = o;
            oo.IX = [ true false(1,o.n-1) ];
            oo.m = 1;
        end
        function oo = null( o )
        %NULL  nobj = NULL( obj ) returns the empty Mtree object
            oo = o;
            oo.IX = false(1,o.n);
            oo.m = 0;
        end
    end
    methods (Access='protected',Hidden)
        function oo = makeAttrib( o, I )
        %makeAttrib oo = makeAttrib( o, I )  Mtree internal utility fcn

        % makes a set of nodes from a logical vector
            oo = o;
            if ~isa( I, 'logical' )
                oo.IX = false( 1, o.n );
                oo.IX(I) = true;
            else
                oo.IX = I;
                %{
                if o.n ~= length(I)
                    error( 'MATLAB:mtree:internal','bad makeAttrib size' );
                end
                %}
            end
            oo.m = sum(oo.IX);
        end
        function [I,ipath,flag,rest] = pathit( o, I, ipath )
        %PATHIT  [Iset,ipath,flag,rest] = PATHIT( o, I, ipath )  Mtree
        %
        % This function takes a path and follows the links part
        % It returns an index set Iset the same size as the original set
        % in o.  I has zeros where the path does not exist, and the 
        % resulting node indices where they do exist.
        %
        % PATHIT also returns the remainder of the path in rest
        %
        % if * or + or & or | is seen, or their text counterparts List,
        % Tree, Full, Any, or All, flag is returned nonzero, with
        % bits set as follows:
        %     0 if none of the above are seen
        %     1 if + or List is seen, 
        %     2 if * or Tree, 
        %     3 if Full is seen
        %     4 if & or All is seen
        %     8 if | or Any is seen
        %     
        % If flag is 0, path is empty, and Iset contains the 
        % final index set.
        % If flag is nonzero, Iset has the index set before the first link
        % that is qualified by one of these operators or links, path has
        % the path segment that is qualified by one or more of the 
        % operators, and rest has everything else
        
            if isa( I, 'logical' )
                error( 'matlab:mtree:internal', 'index set must be integral' );
            end
            flag = 0;
            rest = '';
            if isempty( ipath )
                return;
            end
            % chk( o );
            
            % pick up the segments of the path between the dots, if any
            dots = [0 strfind(ipath,'.') (length(ipath)+1)];
            j = 1;
            while j < length(dots)
                j = j + 1;
                ix = dots(j-1)+1;
                jx = dots(j)-1;
                if length(I) ~= o.m
                    error( 'matlab:mtree:internal', ...
                           'pathit error--bad I length.' );
                end
                JX = find(I~=0);  % nonzero I indices
                pth = ipath(ix:jx);  % current path segment
                %  There are two kinds of qualifiers
                %  +, *, &, and | follow a legal path segment
                %  All, Any, List, Tree, and Full are following dot segments
                
                %  The next function collects these qualifiers
                %  If there are any, it sets pth to the current path
                %  segment, collects the qualifiers in flag, and
                %  sets j to read the next segment
                [j,flag,pth] = collect_qualifiers(pth, ipath, dots, j);
                
                if isempty( pth ) || flag >= 4
                    rest = ipath( dots(j)+1:end );
                    ipath = pth;
                    return
                end
                
                if isempty( pth ) || flag >= 4
                    rest = ipath( jx+2:end );
                    ipath = pth;
                    return;
                end
                switch pth   
                    case 'L'
                        I(JX) = o.T( I(JX), 2 );  % left
                    case 'R'
                        I(JX) = o.T( I(JX), 3 );  % right
                    case {'X','N'}
                        I(JX) = o.T( I(JX), 4 );  % next
                    case 'P' 
                        I(JX) = o.T( I(JX), 9 );  % parent
                    case { 'Kind', 'Member', 'String', 'K', 'A', 'E', ...
                           'Empty', 'Regexp', '~Regexp','~Member', ...
                           '~A', 'Fun', 'Var', 'S', 'F', 'SameID', ...
                           'Isvar', 'Isfun', 'Null', 'StringVal' }  
                        if flag
                            error( 'matlab:mtree:path', ...
                                   'must use *, +, etc. only on links' );
                        end
                        rest = ipath(ix:end);
                        ipath = '';
                        return;
                        % agrees with LINK array in nodeinfo
                    otherwise
                        try
                            lix = o.Linkno.(pth);
                        catch x 
                            error( 'matlab:mtree:path', ...
                                   'Illegal path link: "%s".', pth );
                        end
                        if isempty(JX)
                            continue;  % just find the end of the path
                        end
                        zok = o.Linkok( lix, o.T( I(JX), 1 ) );
                        % this is very subtle!!!
                        % zok has a boolean value that is true if the
                        % link is OK for the associated JX value
                        % If the link is not OK, it means that
                        % the associated I index should be zeroed.
                        
                        I( JX(~zok) ) = 0;  % zero some I values
                        JX = JX(zok);       % preserve the rest
                        
                        MM = o.Lmap{lix};
                        lm = length(MM);
                        for k=1:lm
                            % run the path
                            I(JX) = o.T( I(JX), MM(k) );
                            if k ~= lm 
                                JX = find(I~=0);
                            end
                        end
                end
                ix = jx+2;
                if flag
                    ipath = ipath( ix:end );
                    return
                end
            end
            ipath = '';
        end
        function a = restrict( o, ipath, s )
        %RESTRICT  a = restrict( o, ipath, s )    Mtree internal function
        % this is very tricky.  At each stage, we need to keep
        % track of the original index set so we can zero out the
        % elements that do not match.  a must be a subset of o
        
            % chk(o);
            a = o;
            I = find( a.IX );
            if length(I) ~= o.m
                error( 'matlab:mtree:internal','length inconsistency.' );
            end
            [II,ipath,flag,rest] = pathit( o, I, ipath );
            % II has the set of nodes you get by following the path
            % everything we learn from II must be reflected back to I
            if length(II) ~= length( I )
                error( 'matlab:mtree:internal', 'pathit bad return' );
            end
            if flag 
                if flag<4
                    error( 'matlab:mtree:restrict', ...
                           [ 'find requires &, |, Any, or All in path', ...
                             'after +, *, List, Tree, or Full.' ] );
                end
                % first, apply the path qualifier with no & or |
                [II,pth,flag1,rest1] = pathit( o, II, ipath );
                if flag1 ~= 0 || ~isempty(rest1) || ~isempty(pth)
                    error( 'matlab:mtree:internal', ...
                        'internal error in &, |, Any, or All processing' );
                end
                if flag < 8
                    % used an & qualifier
                    % we go through the elements one by one, recursively
                    for i=1:o.m
                        ii = II(i);
                        if ii == 0
                            I(i) = 0;
                            continue;
                        end
                        aa = o;
                        aa.IX = false(1,o.n);
                        aa.IX(ii) = true;  % one element set
                        aa.m = 1;
                        if bitand( flag, 1 )
                            aa = List(aa);
                        end
                        if bitand( flag, 2 )
                            aa = Tree(aa);
                        end
                        aaa = restrict( aa, rest, s );
                        if aaa ~= aa
                            I(i) = 0;
                        end
                    end
                else
                    % we used an | qualifier
                    % we go through the elements one by one, recursively
                    for i=1:o.m
                        ii = II(i);
                        if ii == 0
                            I(i) = 0;
                            continue;
                        end
                        aa = o;
                        aa.IX = false(1,o.n);
                        aa.IX(ii) = true;  % one element set
                        aa.m = 1;
                        if bitand( flag, 1 )
                            aa = List(aa);
                        end
                        if bitand( flag, 2 )
                            aa = Tree(aa);
                        end
                        aaa = restrict( aa, rest, s );
                        if isnull(aaa)
                            I(i) = 0;
                        end
                    end
                end
                % we've done the real work recursively
                a.IX = false(1,o.n);
                a.IX(I(I~=0)) = true;
                a.m = sum(a.IX);
                if any( a.IX & ~o.IX )
                    error( 'matlab:mtree:internal', 'restrict failure' );
                end
                return
            end
            % flag == 0, so no + or |
            % all the path should be consumed
            if ~isempty( ipath )
                error( 'matlab:mtree:internal','path inconsistency' );
            end
            if length(II) ~= o.m
                error( 'matlab:mtree:internal','length inconsistency.' );
            end
            JX = find(II~=0);  % which elements are nonzero
            J = II(JX);  % nonzero elements
            a.IX = false( 1, a.n );  % the resulting index set
            switch rest
                
                case { 'S', 'String' }  
                    % no symbol table stuff yet
                    % 8 is the index for strings
                    for i=1:length(J)
                        % J(i) corresponds to I(JX(i))
                        k = o.T(J(i),8);
                        if k && any( strcmp( o.C{k}, s ) )
                            a.IX( I(JX(i)) ) = true;
                        end
                    end
                
                case 'StringVal'
                    for i=1:length(J)
                        % J(i) corresponds to I(JX(i))
                        k = o.T(J(i),8);
                        if k && any( strcmp( dequote(o.C{k}), s ) )
                            a.IX( I(JX(i)) ) = true;
                        end
                    end
                    
                case { 'F', 'Fun', 'V', 'Var' }
                    % no symbol table stuff yet
                    % 8 is the index for strings
                    % 7 is the symbol table index
                    % In the symbol table, 5 is column with type flags
                    id = o.K.ID;
                    for i=1:length(J)
                        % J(i) corresponds to I(JX(i))
                        if o.T(J(i),1) ~= id
                            % not an ID
                            continue;
                        end
                        sx = o.T( J(i), 7 );
                        if ~sx
                            continue;
                        end
                        % check the type bits from the symbol table...
                        sb = bitand( o.S( sx, 5 ), 6 );
                        if (rest(1)=='F' && sb~=2) || (rest(1)=='V' && sb~=4)
                            continue;  % not the right kind of name
                        end
                        k = o.T(J(i),8);
                        if k && any( strcmp( o.C{k}, s ) )
                            a.IX( I(JX(i)) ) = true;
                        end
                    end
                    
                case 'SameID'
                    % return ID's in A which agree with those in s
                    % s is an object
                    % 7 is the index for the symbol table
                    % first, create an index set from s
                    id = o.K.ID;
                    xx = false( 1, size(o.S,1) );
                    Q = find( s.IX );
                    Q = Q( o.T( Q, 1 ) == id ); % ID's in Q
                    Q = Q( o.T( Q, 7 ) ~= 0 );  % nonzero table entries
                    xx( o.T( Q, 7 ) ) = true;  % true if ID is in set s
                    % now, strip out indices that aren't ID's
                    ok = o.T( II(JX), 1 ) == id;
                    ok(ok) = xx( o.T( II(JX(ok)), 7 ) );
                    a.IX( I(ok) ) = true;
                    
                case {'K','Kind'}
                    if isa( s, 'cell' )
                        for j=1:length(s)
                            try
                                k = o.K.(s{j});  % a desired kind
                            catch x 
                                error( 'matlab:mtree:kind', ...
                                       'unknown node kind: %s', s{j} );
                            end
                            
                            % set the elements corresponding to those
                            % elements where J has kind k
                            matches = o.T(J,1) == k;
                            a.IX( I(JX(matches)) ) = true;
                        end
                    else
                        try
                            k = o.K.(s);
                        catch x 
                            error( 'matlab:mtree:kind', ...
                                   'unknown node kind: %s', s );
                        end
                        % this is subtle!
                        % The matches are tagged to the J vector
                        % J(i) corresponds to I(JX(i))
                        matches = o.T(J,1)==k;
                        a.IX( I(JX(matches)) ) = true;
                    end
                    
                case {'A','Member'}  % another attribute
                    a.IX( I( JX(s.IX(II(JX))) ) ) = true;
                    
                case {'~A','~Member', 'Nonmember'} % attribute is false
                    % this can succeed because II is zero, or because
                    % II is nonzero and it's not in the set
                    a.IX( [I( JX(~s.IX(II(JX))) ) I(II==0)] ) = true;
                    
                case {'E','Empty','Null'}  % empty
                    if s 
                        % looking for empty stuff
                        a.IX( I(II==0) ) = true;
                    else
                        % looking for nonempty stuff
                        a.IX( I(II~=0) ) = true;
                    end
                    
                case { 'Isvar', 'Isfun' } % look for a variable (resp. fun)
                    id = o.K.ID;
                    for i=1:length(J)
                        % J(i) corresponds to I(JX(i))
                        if o.T(J(i),1) ~= id
                            if ~s
                                a.IX( I(JX(i)) ) = true;
                            end
                            continue;  % it's not an ID node
                        end
                        sx = o.T( J(i), 7 );
                        if ~sx
                            if ~s
                                a.IX( I(JX(i)) ) = true;
                            end
                            continue;
                        end
                        % check the type bits from the symbol table...
                        sb = bitand( o.S( sx, 5 ), 6 );
                        if (rest(3)=='f' && sb~=2) || (rest(3)=='v' && sb~=4)
                            if ~s
                                a.IX( I(JX(i)) ) = true;
                            end
                            continue;  % not the right kind of name
                        end
                        a.IX( I(JX(i)) ) = s;
                    end
                case { 'Regexp', '~Regexp' }
                    % no symbol table stuff yet
                    % 8 is the index for strings
                    % note that this is done on the StringVal
                    for i=1:length(J)
                        % J(i) corresponds to I(JX(i))
                        k = o.T(J(i),8);
                        if k 
                            ix = regexp( dequote(o.C{k}), s, 'once' );
                            if isempty(ix) 
                                if rest(1)=='~'
                                    a.IX( I(JX(i)) ) = true;
                                end
                            else
                                if rest(1)=='R'
                                    a.IX( I(JX(i)) ) = true;
                                end
                            end
                        end
                    end
                    
                    
                otherwise
                    error( 'matlab:mtree:path','bad path: "%s".', ipath );
            end
                
            a.m = sum( a.IX );
            % chk( a );
        end
    end
    methods
        % 'path' is deprecated since it interferes with the builtin
        function a = path(o, pth )
        %PATH a = PATH( obj, path_string )   Deprecated Mtree -- use mtpath
            a = mtpath( o, pth );
        end
        function a = mtpath(o, pth )
        %MTPATH a = MTPATH( obj, path_string )  Follow an Mtree path
        % returns the set of nodes generated by following a path from obj
        
        % this is a recursive implementation to handle + and *
            a = o;
            I = find(a.IX);
            [I,pth,flag,rest] = pathit( o, I, pth );
            % on return, if no + and *, flag is 0 and pth and rest are
            % empty
            % if flag is nonzero, then it should be less than 4
            % pth has the path component to which the */+ is applied
            % II reflects the path before that
            % rest has any further path elements that are applied later
            I = I(I~=0);   % throw out dead ends

            % for L, R, and X, a.m = length(I).  But this isn't true for P
            
            a.IX = false( 1, o.n );
            a.IX(I) = true;
            a.m = sum(a.IX);
            if flag
                if flag >= 4
                    error( 'matlab:mtree:andor', ...
                           'Calls to PATH do not recognize "&" and "|"' );
                end
                if bitand(flag, 1)
                    a = List( a );
                end
                if bitand(flag, 2)
                    a = Tree( a );
                end
                % when flag is nonzero, we may still have path to do
                % recurse
                if ~isempty( pth )
                    a = mtpath( a, pth );
                end
                if ~isempty( rest )
                    a = mtpath( a, rest );
                end
            end
        end
   
        function c = strings( o )
        %STRINGS  c = STRINGS( obj ) return the strings for the Mtree obj

            c = cell( 1, o.m );
            SX = o.T( o.IX, 8 );  % string indices
            J = (SX==0);  % elements with no strings
            [c(J)] = {''};
            [c(~J)] = o.C(SX(~J));
        end
        function c = stringvals( o )
        %STRINGVALS c = STRINGVALS( obj ) return the string values for obj
            c = strings(o);
            for i=1:length(c)
                c{i} = dequote( c{i} );
            end
        end
        function s = string( o )
        %STRING str = STRING( o )  return a string for an Mtree node
        
            % o must be a single element set -- returns the string
            % an error if count(o)~=1 or the node does not have a string
            i = find( o.IX );
            if length(i)~=1
                error( 'matlab:mtree:string', ...
                       '"string" argument does not have 1 element.' );
            end
            i = o.T(i,8);
            if i==0
                error( 'matlab:mtree:nostring', ...
                       '"string" called on node which has no string.' );
            end
            s = o.C{i};
        end
        function s = stringval( o )
        %STRINGVAL str = STRINGVAL( o )  return the string value for a node
            s = dequote( string(o) );
        end
        function a = find( o, varargin )
        %FIND   Deprecated Mtree method -- use mtfind
        
            % deprecated, because code analysis report checks argument count
            a = mtfind( o, varargin{:} );
        end
        function a = mtfind( o, varargin )
        %MTFIND a = MTFIND( obj, args )  sets a to the subset of obj nodes
        %  that match all the patterns specified in args.  The patterns are
        %  specified by pairs.  The first part of the pair begins with a
        %  path, which may be empty, and then contains a test to be run on
        %  the nodes that result from following that path.  The second
        %  member of the pair gives the acceptable results of this test.
        %  Only those nodes that pass all the tests are included in the
        %  output a.  Tests that take a string argument may also take
        %  a cell array of strings as argument -- the test passes if the
        %  indicated string matches one of the strings in the cell array.
        %      'Kind', str    passes if the node Kind is str
        %      'Fun', str     passes if the node is a function named str
        %      'Var', str     passes if the node is a variable named str
        %      'SameID', x    passes if the node is the same variable as x
        %      'IsVar', b     passes if the node being a variable matches b
        %      'IsFun', b     passes if the node being a function matches b
        %      'String', str  passes if the string value of the node is str
        %      'Null', b      passes if the nullness of the node is b
        %      'Member', x    passes if the node is in the set x
        %      'Nonmember', x passes if the node is not in the set x

            na = nargin - 1;
            a = o;
            % chk(a);
            for i=1:2:na
                if( i+1 > na )
                    error( 'matlab:mtree:find', ...
                           'missing argument to "find".' );
                end
                a = restrict( a, varargin{i}, varargin{i+1} );
                % chk(a);
                if any( a.IX & ~o.IX )
                    error( 'matlab:mtree:internal', 'find implementation' );
                end
            end
        end
        function o = sets( o )
        %SETS  oo = SETS( obj )  Returns the nodes that set obj's values
        %  SETS is defined only on ID nodes, and returns sets of ID nodes
        
            % expand set based on the setters of JOIN nodes
            % we add the nodes pointed to by JOIN nodes to o
            % we also add indexed nodes that are set
            % we need to run this over the whole nodeset
            % we start with the setters of o
            I = o.T( o.IX, 10 );
            I = I(I>0);     % the ones that are present
            nt = size(o.T,1);
            done = false( 1, nt );
            todo = done;
            todo(I) = I>o.n;
            X = false( 1, o.n );   % the eventual answer
            X(I(I<=o.n)) = true;   % it includes the real nodes of I
            while( any(todo) )
                for i=find(todo)
                    todo(i) = false;
                    done(i) = true;
                    if i <= o.n
                        j = o.T( i, 10 );
                        if j && ~done(j)
                            if j<=o.n
                                X(j) = true;
                            end
                            todo(j) = true;
                        end
                        continue
                    end
                    % its a join node
                    jl = o.T(i,2);  % left
                    jr = o.T(i,3);  % right
                    if jl <= o.n
                        X(jl) = true;
                    elseif ~done(jl) && ~todo(jl)
                        todo(jl) = true;
                    end
                    if jr <= o.n
                        X(jr) = true;
                    elseif ~done(jr) && ~todo(jr)
                        todo(jr) = true;
                    end
                end
            end
            o = makeAttrib( o, X );
            % chk(o);
        end
    end
    methods   % methods for following paths...
        function o = Left(o)
        %Left  o = Left(obj)   returns the Left children of Mtree obj
        
            % fast for single nodes...
            lix = o.Linkno.Left;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Arg(o)
        %Arg  o = Arg(obj)   returns the Arg children of Mtree obj

        % fast for single nodes...
            lix = o.Linkno.Arg;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Try(o)
        %Try  o = Try(obj)   returns the TRY blocks for TRY nodes in obj

            % fast for single nodes...
            lix = o.Linkno.Try;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Attr(o)
        %Attr  o = Attr(obj)   the attributes for class sections in obj

            % fast for single nodes...
            lix = o.Linkno.Attr;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Right(o)
        %Right  o = Right(obj)   returns the Right children of Mtree obj

            % fast for single nodes...
            lix = o.Linkno.Right;
            J = o.T( o.IX, 3 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Body(o)
        %Body  o = Body(obj)   returns the Body children of Mtree obj

            % fast for single nodes...
            lix = o.Linkno.Body;
            J = o.T( o.IX, 3 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Catch(o)
        %Catch  o = Catch(obj)   the Catch blocks for TRY nodes in obj

            % fast for single nodes...
            lix = o.Linkno.Catch;
            J = o.T( o.IX, 3 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            J = o.T( J, 3 );  % apply 'Right' again
            J = J(J~=0);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = CatchID(o)
        %CatchID  o = CatchID(obj)   the catch IDs of TRY nodes in obj

            % fast for single nodes...
            lix = o.Linkno.CatchID;
            J = o.T( o.IX, 3 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            J = o.T( J, 2 );  % apply 'Left' again
            J = J(J~=0);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Next(o)
        %Next  o = Next(obj)   returns the Next nodes of nodes in Mtree obj

            % fast for single nodes...
            lix = o.Linkno.Next;
            J = o.T( o.IX, 4 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Parent(o)
        %Parent  o = Parent(obj)  returns the parents of nodes in Mtree obj

            % fast for single nodes...
            lix = o.Linkno.Parent;
            J = o.T( o.IX, 9 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            % the standard drill gets o.m wrong, since two nodes in o
            % may have the same parent (e.g., J may have duplicate entries)
            o.m = nnz(o.IX);
        end
        function o = Outs(o)
        %Outs  o = Outs(obj)   returns the first output of FUNCTIONs in obj

            % fast for single nodes...
            lix = o.Linkno.Outs;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);  
            J = o.T( J, 2 );  % apply 'Left' again
            J = J(J~=0);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Index(o)
        %Index  o = Index(obj)   returns the FOR index for FOR nodes in obj

            % fast for single nodes...
            lix = o.Linkno.Index;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            J = o.T( J, 2 );  % apply 'Left' again
            J = J(J~=0);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Cattr(o)
        %Cattr  o = Cattr(obj)   returns the attributes of CLASSDEFS in obj

            % fast for single nodes...
            lix = o.Linkno.Cattr;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            J = o.T( J, 2 );  % apply 'Left' again
            J = J(J~=0);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Vector(o)
        %Vector  o = Vector(obj)   returns the Left children of Mtree obj

            % fast for single nodes...
            lix = o.Linkno.Vector;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            J = o.T( J, 3 );  % apply 'Right' again
            J = J(J~=0);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Cexpr(o)
        %Cexpr  o = Cexpr(obj)   class expression for CLASSDEFS in obj
        %   The class expression contains the class name and superclass
        %   names as well

            % fast for single nodes...
            lix = o.Linkno.Cexpr;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            J = o.T( J, 3 );  % apply 'Right' again
            J = J(J~=0);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Ins(o)
        %Ins  o = Ins(obj)   the first input of FUNCTIONs in Mtree obj

            % fast for single nodes...
            lix = o.Linkno.Ins;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            J = o.T( J, 3 );  % apply 'Right' again
            J = J(J~=0);
            J = o.T( J, 3 );  % apply 'Right' again
            J = J(J~=0);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = Fname(o)
        %Fname o = Fname(obj)   The function names for FUNCTIONS in obj

            % fast for single nodes...
            lix = o.Linkno.Fname;
            J = o.T( o.IX, 2 );
            KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
            J = J(KKK);
            J = o.T( J, 3 );  % apply 'Right' again
            J = J(J~=0);
            J = o.T( J, 2 );  % apply 'Left' again
            J = J(J~=0);
            o.IX(o.IX) = false;   % reset
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = lhs( o ) % find the LHS of EQUALS nodes
        %LHS  o = LHS( obj )   The first assigned value of an EQUALS node
        %   This function looks below [ ] if present to find the first
        %   value that is assigned to by an EQUALS node.
        
            oo = Left( mtfind( o, 'Kind', 'EQUALS' ) );
            ooo = mtfind( oo, 'Kind', 'LB' );
            o = (oo-ooo) | List(Arg(ooo));  % apply List to get multiple LHS
        end
        function o = previous( o )
        %PREVIOUS  o = PREVIOUS( obj )   The previous node in an Mtree List
            o = P( o & (X(P(o))) );
        end
        function oo = first( o )
        %FIRST  o = FIRST( obj )   The first node in an Mtree List
            o1 = X(P(o));
            o2 = P( o & o1 );  % previous nodes
            oo = o - o1;  % nodes already at head of List
            while ~isnull( o2 )
                o1 = X(P(o2));
                o3 = P( o2 & o1 );
                oo = oo | (o2 - o1);
                o2 = o3;
            end
        end
        function o = last( o )
        %LAST  o = LAST( obj )   The last node in an Mtree List
            while true
                oo = X(o);
                o = (o - P(oo)) | oo;
                if isnull(oo)
                    return;
                end
            end
        end
    end
    methods
        function oo = setter( o )
        %SETTER  oo = setter( obj )  returns the setter of node obj
        
            % ignores the case where the node is the target of an assignment
            if count(o) ~= 1 
                error( 'matlab:mtree:setter', ...
                       'setter must be called on a single node' );
            end
            J = o.T(o.IX,10);  % 10 is the column with SET information
          
            if ~J || o.T(J,1) == o.K.JOIN
                oo = o;
                return;
            end
            % if J is an ID node, try once more
            if o.T(J,1) == o.K.ID
                JJ = o.T(J,10);
                if JJ 
                    if o.T(JJ,1) ~= o.K.JOIN
                        J = JJ;
                    end
                elseif o.T(J,4)==0
                    % J is a simple assignment
                    P = o.T(J,9);  % 9 for parent
                    % check that P exists, is =, has only one lhs, and the
                    % lhs is J  (4 is next, 1 is kind, 2 is left)
                    % make this work for [x] = ...  also
                    % simple case first: if LHS is J, simple assignment
                    if P
                        if o.T(P,1) == o.K.EQUALS && o.T(P,2) == J  
                        % J is the left descendent of P
                            J = o.T(P,3);  % rhs of =
                        % now, do [x] case: parent is [, no next, parent
                        % of parent is =
                        elseif o.T(P,1) == o.K.LB
                            PP = o.T(P,9);   % 
                            if o.T(PP,1) == o.K.EQUALS && o.T(PP,2)==P
                                J = o.T(PP,3);  % rhs of =
                            end
                        end
                    end
                end
                oo = makeAttrib( o, J );
            end
        end
    end
    methods (Hidden)
        % these are low-level methods that are used for testing or special purposes
        % and will not be documented
        function b = sametree( o, oo ) %#ok<MANU,INUSD>
        %SAMETREE  b = sametree( o, oo )  true of trees the same (NOT YET!)
            b = true;
            return
        end
        function oo = rawset( o )
        % RAWSET  oo = rawset(o)  the real nodes that set o (no JOINS)
            J = o.T( o.IX, 10 );  % setting nodes
            J = J(J~=0 & (J<=o.n));
            oo = makeAttrib( o, J );
        end
        function T = newtree( o, varargin )
        %NEWTREE  T = newtree(obj,varargin) make a tree out of a subtree
        %  the arguments are the same as for TREE2STR
            if count(o) ~= 1
                error( 'MATLAB:mtree:newtree', 'argument must be a single node' );
            end
            % returns a new MTREE object based on subtree of the node o
            % for now, o must be a single node
            % TODO: add arguments to allow changes
            % for now, use tree2str to do this
            T = mtree( tree2str( o, 0, true, varargin{:} ) );
        end
        function s = getpath( o, r )
        %GETPATH  s = getpath( o, r )  returns the raw path from o to f
            if nargin<2
                r = root(o);
            end
            x = r;
            s = '.';
            while x ~= r
                if isnull(x)
                    s = '';
                    return;  % no path from r to o
                end
                y = mtpath( x, 'Parent' );
                if x == mtpath( y, 'L' )
                    s = [ '.L' s ]; %#ok<AGROW>
                elseif x == mtpath( y, 'R' )
                    s = [ '.R' s ]; %#ok<AGROW>
                elseif x == mtpath( y, 'N' )
                    s = [ '.N' s ]; %#ok<AGROW>
                else
                    error( 'impossible path' );
                end
                if y == r
                    return;
                end
            end
        end
        function o = L(o)
        %L  o = L(o)  Raw Left operation
        
            % fast for single nodes...
            J = o.T( o.IX, 2 );
            J = J(J~=0);
            o.IX(o.IX) = false;
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = R(o)
        %R  o = R(o)  Raw Right operation
        
            J = o.T( o.IX, 3 );
            J = J(J~=0);
            o.IX(o.IX) = false;
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = P(o)
        %P  o = P(o)  Raw Parent operation
        
            J = o.T( o.IX, 9 );
            J = J(J~=0);
            o.IX(o.IX) = false;
            o.IX(J)= true;
            o.m = length(J);
        end
        function o = X(o)
        %X  o = X(o)  Raw Next operation
        
            J = o.T( o.IX, 4 );
            o.m = o.m - sum( J==0 );
            J = J(J~=0);
            o.IX(o.IX) = false;
            o.IX(J)= true;
        end
        function o = or( o, o2 )
        %OR  o = o1 | o2      | operation on trees
        
            o.IX = o.IX | o2.IX;
            o.m = sum( o.IX );
        end
        function o = and( o, o2 )
        %AND  o = o1 & o2     & operation on trees
        
            o.IX = o.IX & o2.IX;
            o.m = sum( o.IX );
        end
        function o = not( o )
        %MOT  o = ~o        ~ operation on trees
        
            o.IX = ~o.IX;
            o.m = sum( o.IX );
        end
        function o = minus( o, o2 )
        %MINUS  o = o1 - o2     set difference operation on trees
        
            o.IX = o.IX & (~o2.IX);
            o.m = sum( o.IX );
        end
    end
    methods
        function oo = allsetter( o, o2 )
        %ALLSETTER oo = allsetter( obj, o2 )  Deprecated Mtree method
            X = false( 1, o.n );
            for i=indices(o)
                x = select( o, i );
                y = sets(x);
                if count(o2&y) < count(y)
                    continue;  % this one is not in
                end
                % now, check for assignment to x
                % TODO: is the above comment incorrect?
                % is ALLSETTER used?  Or necessary?
                y = setter( x );
                if isnull( y&o2 )
                    continue;  % this one is not in
                end
                X(i) = true;
            end
            oo = o;
            oo = makeAttrib( oo, X );
        end
        function oo = anysetter( o, o2 )
        %ANYSETTER  oo = anysetter( obj, o2 )  Deprecated Mtree method
            X = false( 1, o.n );
            for i=indices(o)
                x = select( o, i );
                y = sets(x);
                if ~isnull(o2&y)
                    X(i) = true;
                    continue;  % this one is in
                end
                % now, check for assignment to x
                % TODO: is the above comment incorrect?
                % is ANYSETTER used?  Or necessary?
                y = setter( x );
                if ~isnull( y&o2 )
                    X(i) = true;
                    continue;  % this one is in
                end
            end
            oo = o;
            oo = makeAttrib( oo, X );
        end
        function disp(o)
        %DISP  DISP(obj)  display the Mtree object obj

            if o.m==o.n
                fprintf('  mtree (complete: %d nodes)\n',o.n);
            else
                fprintf('  mtree (subtree: %d of %d nodes)\n',o.m,o.n);
            end
            if o.m<10
                show(o);
            end
        end
        function show(o)
        %SHOW  SHOW(obj)  show all the members of the Mtree obj
        
            J = find(o.IX); % indices of selected nodes in table
            Q = o.T(J,1); % "kind" numbers for selected nodes
            KKK = o.KK(Q); % "kind" strings for selected nodes
            SS = strings(o);
            for i=1:numel(J)
                if isempty(SS{i})
                    fprintf('     Node %d: %s\n',J(i),KKK{i});
                else
                    fprintf('     Node %d: %s "%s"\n',J(i),KKK{i},SS{i});
                end
            end
        end
        function dump(o)
        %DUMP  DUMP(obj)   Deprecated.  Use RAWDUMP or DUMPTREE
        
            % in R2010a, dump will become dumptree
            rawdump(o);
        end
        function dumptree(o)
        %DUMPTREE  DUMPTREE(obj)  Dump the tree with link names

            persistent linknames pno nxtno prtord
            if isempty( linknames )
                linknames = fieldnames( o.Linkno );
                % Clean this up.  Get rid of single letters
                for ii=1:length(linknames)
                    linknames{ii} = [ '*' linknames{ii} ':' ];
                end
                pno = o.Linkno.Parent;
                nxtno = o.Linkno.Next;
                printorder = { 'Left', 'Right', 'Arg',  'Fname', 'Ins', ...
                               'Outs', 'Index', 'Vector', 'Cattr', ...
                               'Attr', 'Cexpr', 'Try', 'CatchID', ...
                               'Catch', 'Body', 'Next' };
                prtord = zeros( 1, length(printorder) );
                for ii=1:length(prtord)
                    prtord(ii) = o.Linkno.(printorder{ii});
                end
            end
            if isnull(o)
                return;
            end
            ix = find( o.IX, 1 );  % find the root of the first subtree
            recdump( 0, ix, '*<root>:' );
            function recdump( ind, nix, c )
                % dumps node nix, indenting %d characters w. char c
                % note: we do tail recursion on 'Next' links
                while( nix )
                    if( o.IX(nix) )
                        fprintf( '%3d  ', nix );
                    else
                        fprintf( '%3d  ', nix );
                    end
                    for i=1:ind
                        fprintf( '   ' );
                    end
                    fprintf( '%s  ', c );
                    % dump the current node
                    sx = o.T(nix,8);
                    s = '';
                    if sx~=0
                        s = [ ' (' o.C{sx} ')' ];
                    end
                    ln = linelookup( o, o.T(nix,5) );
                    ch = o.T(nix,5)-o.lnos(ln);
                    fprintf( '%s: %3d/%02d %s\n', o.KK{o.T(nix,1)}, ln, ch, s );
                    % now, determine the links that are legal for the node
                    OK = o.Linkok(:,o.T(nix,1));  % logical array
                    
                    for i=prtord( OK(prtord) )
                        switch( i )
                            case { nxtno, pno }
                                % don't do parent, do Next specially
                            otherwise
                                % apply the link, see if anything is there
                                M = o.Lmap{ i };
                                jx = nix;
                                for j=1:length(M)
                                    jx = o.T( jx, M(j) );
                                    if jx == 0
                                        break;
                                    end
                                end
                                if jx ~= 0
                                    % print the link recursively
                                    recdump( ind+1, jx, linknames{i} );
                                end
                        end
                    end
                    % now, do next node
                    % note the tail recursion
                    nix = o.T(nix, 4);
                    c = '>Next:';
                end
            end
        end
        function rawdump(o)
        %RAWDUMP  RAWDUMP(obj)  Dump the full tree, showing all nodes
        %    The members of the set obj are highlighted in the dump
        
            if isnull(o)
                return;
            end
            recdump( 0, 1, '*' );
            function recdump( ind, nix, c )
                % dumps node nix, indenting %d characters w. char c
                % note tail recursion on the 'next' node
                while( nix )
                    if( o.IX(nix) )
                        fprintf( '%3d===  ', nix );
                    else
                        fprintf( '%3d     ', nix );
                    end
                    for i=1:ind
                        fprintf( '   ' );
                    end
                    fprintf( '%s  ', c );
                    % dump one node
                    sx = o.T(nix,8);
                    s = '';
                    if sx~=0
                        s = [ ' (' o.C{sx} ')' ];
                    end
                    ln = linelookup( o, o.T(nix,5) );
                    ch = o.T(nix,5)-o.lnos(ln);
                    fprintf( '%s: %3d/%02d %s\n', o.KK{o.T(nix,1)}, ln, ch, s );
                    if o.T(nix,2) % left
                        recdump( ind+1, o.T(nix,2), '*' );
                    end
                    if o.T(nix,3) % right
                        recdump( ind+1, o.T(nix,3), '*' );
                    end
                    nix = o.T(nix, 4);
                    c = '>';
                end
            end
        end
        function o = List( o )
        %LIST  o = List(obj)   Return the nodes that follow (with Next)
        %      some node in obj

            % it appears that a loop is the best way to do this...
            IXX = o.IX;
            for i=find(IXX)
                % follow next path
                j = o.T(i,4);
                while( j && ~IXX(j) )
                    IXX(j) = true;
                    j = o.T(j,4);
                end
            end
            o.IX = IXX;
            o.m = sum(IXX);
        end
        function o = Full( o )
        %FULLSUBTREE  o = FULLSUBTREE( obj )  Return all the nodes reached
        %   from nodes in obj using paths that do not include Parent
        
            I = find( o.IX );
            xx = false(1,o.n);
            for i=I
                xx(i:o.T(i,15)) = true;
            end
            o.m = nnz(xx);
            o.IX = xx;
        end
        function o = Tree( o )
        %TREE  o = TREE( obj )  Return all nodes reached from nodes  
        %    in obj by paths that do not include Parent or start with Next

            I = find( o.IX );
            xx = false(1,o.n);
            for i=I
                xx(i:o.T(i,14)) = true;
            end
            o.m = nnz(xx);
            o.IX = xx;
        end
        function oo = asgvars( o )
        %ASGVARS  o = ASGVARS( obj )  Assigned variables.
        %   Returns all nodes assigned to by EQUALS nodes in obj.  This 
        %   includes nodes whose assignment is indexed.  It does not 
        %   include FOR indices, function inputs, GLOBALs, or PERSISTENTs.

            x = Left( mtfind( o, 'Kind', 'EQUALS' ) );
            lbs = mtfind( x, 'Kind', 'LB' );
            x = mtfind( ((x-lbs)|List(Arg(lbs))) );
            oo = mtfind( x, 'Kind', 'ID' );
            x = x - oo;
            % must be DOT, DOTLP, SUBSCR, or CELL
            % empty args (~) just disappear from the List
            while ~isnull( x )
                x = mtpath( x, 'Left' );
                ooo = mtfind( x, 'Kind', 'ID' );
                oo = oo | ooo;
                x = x - ooo;
            end
        end
        function oo = geteq( o )
        %GETEQ  o = GETEQ( obj )   Get EQUALS node.
        %   Returns the EQUALS node, if any, that assigns to variables or 
        %   expressions in obj.
        
            oo = null( o );
            while ~isnull( o )
                p = mtfind( Parent(o), 'Kind', 'EQUALS' );
                %o1 = mtfind( o, 'Parent.Kind', 'EQUALS' );
                %o1 = o1 & mtpath( o1, 'Parent.Left' );  % o1 are left children
                o1 = o & Left(p);
                oo = oo | Parent( o1 ); % all EQUALS nodes
                o = o - o1;
                o = Parent(o);
                % if we get to EXPR or PRINT or FOR, too far!
                % this should just be for efficiency
                o = o - mtfind( o, 'Kind', { 'EXPR', 'PRINT', 'FOR' } );
            end
        end
        function oo = dominator( o )
        %DOMINATOR  o = DOMINATOR( obj )  Return the dominator set of obj
        %   The dominator is the set of nodes in obj whose parent is not
        %   in obj.  The dominator of a subtree is the root of that
        %   subtree.  The dominator of a List is the head of the List.

            if ismember( root(o), o )
                
            end
            oo = mtfind( o, 'Parent.~Member', o );
        end
        function ooo = dominates( oo, o )
        %DOMINATES  oo = DOMINATES( obj, o )   Return nodes that dominate
        %   Returns nodes in obj that can reach some node in o by a path
        %   that does not involve Parent
        
            ooo = null(oo);
            while ~isnull( o )
                ooo = ooo | (o & oo);
                o = Parent(o);
            end
        end
        function b = isbop( o )
        %ISBOP  b = ISBOP( obj )   Boolean array, true if node is binary
        
            b = o.Bop( o.T(o.IX,1) );
        end
        function b = isuop( o )
        %ISUOP  b = ISUOP( obj )   Boolean array, true if node is unary
        
            b = o.Uop( o.T(o.IX,1) );
        end
        function b = isop( o )
        %ISOP  b = ISOP( obj )   Boolean array, true if node is an operator
        
            b = isbop(o) | isuop(o);
        end
        function b = isstmt( o )
        %ISSTMT  b = ISSTMT( obj )   True of node heads a statement
        
            b = o.Stmt( o.T(o.IX,1) );
        end
        function o = ops( o )
        %OPS  o = OPS( obj )   Returns the operator nodes in obj
        
            o = uops(o) | bops(o);
        end
        function o = bops( o )
        %BOPS  o = BOPS( obj )  Returns the binary operator nodes in obj

            o.IX(o.IX) = o.Bop( o.T(o.IX,1) );
            o.m = sum( o.IX );
        end
        function o = uops( o )
        %UOPS  o = UOPS( obj )  Returns the unary operator nodes in obj
        
            J = find( o.IX );
            o.IX(J) = o.Uop( o.T(J,1) );
            o.m = sum( o.IX );
        end
        function o = stmts( o )
        %STMTS  o = STMTS( obj )  Returns the statement nodes in obj
        
            J = find( o.IX );
            o.IX(J) = o.Stmt( o.T(J,1) );
            o.m = sum( o.IX );
        end
        function o = operands( o )
        %OPERANDS  o = OPERANDS( obj )  Return the (raw) operands of obj
            o = ops(o);
            o = mtpath( o, 'L' ) | mtpath( o, 'R' );
        end
        function oo = depends( o )
        %DEPENDS  o = DEPENDS( obj )  Returns nodes that obj depends on

            e = geteq( o );
            % lhs = mtpath( e, 'Left+' );   % expressions assigned to
            oo = mtpath( e, 'Right' );   % contents of RHS
            % oo = oo | dominates( lhs, o );
            % add argument to call
            oo = oo | mtpath( mtfind( o, 'Kind', 'CALL' ), 'Right+' );
            % add operands of operators
            oo = oo | operands( o );
        end
        function o = setdepends( o )
        %SETDEPENDS  o = SETDEPENDS( obj )  Nodes obj depends on or set by
            o = o|sets( o );
            o = o|depends( o );
        end
        function o = growset( o, fh )
        %GROWSET  obj = GROWSET( obj, fh )  Enlarge obj using function fh
        %   GROWSET grows obj by adding nodes o where fh( o, obj ) is true
        %   If continues this process until fh( o, obj ) is false for all
        %   nodes o not in the expanded obj.
            work = true;
            oo = null( o );
            while work
                work = false;
                for i=find( ~o.IX )
                    % i is not in o
                    ooo = oo;
                    ooo.IX(i) = true;
                    if fh( o, ooo )
                        o.IX(i) = true;
                        work = true;
                    end
                end
            end
            o.m = sum(o.IX);
        end
        function o = fixedpoint( o, fh )
        %FIXEDPOINT  obj = FIXEDPOINT( obj, fh )  Grow obj applying fh
        %   FIXEDPOINT applies the function fh to the set obj, and adds
        %   the result to obj.  It continues this until the set no longer
        %   grows.
            nn = count(o);
            while true
                o = o | fh(o);
                mm = count(o);
                if mm==nn
                    return;
                end
                nn = mm;
            end
        end
        function L = lineno( o )
        %LINENO  L = lineno( obj )   Line numbers of the nodes in obj

            L = linelookup( o, o.T( o.IX, 5 ) );  % vector of positions
        end
        function C = charno( o )
        %CHARNO  C = charno( obj )   Character positions of nodes in obj

            C = o.T( o.IX, 5 ) - o.lnos(lineno(o));
        end
        function P = position( o )
        %POSITION  P = POSITION( obj )   String indices of nodes in obj

            P = o.T( o.IX, 5 );
        end
        function [l,c] = pos2lc( o, pos )
        %POS2LC  [L,C] = POS2LC( obj, pos )   convert position to line/char
        
            l = reshape( linelookup( o, pos ), size(pos) );
            c = pos - reshape( o.lnos( l ), size(pos) );
        end
        function pos = lc2pos( o, l, c )
        %LC2POS  pos = LC2POS( obj, L, C )   Convert line/char to position
            pos = reshape( o.lnos(l), size(l) ) + c;
        end
        function EP = endposition( o )
        %ENDPOSITION  EP = ENDPOSITION( obj )  The close of nodes in obj
        %   NOTE: this gives the position of the matching parenthesis,
        %   or bracket or END of the node(s) in obj
            EP = o.T( o.IX, 5 ) + o.T( o.IX, 6 ) - 1;
        end
        function LP = leftposition(o)
        %LEFTPOSITION  pos = LEFTPOSITION(obj)  return leftmost position
        %   The leftmost position of any node in obj
        
            LP = min( position(o) );
        end
        function RP = rightposition(o)
        %RIGHTPOSITION  pos = RIGHTPOSITION(obj)  return rightmost position
        %   The rightmost position of any node in obj, including possible
        %   closing symbols (right parens and brackets, comments, etc.)

            RP = max( endposition(o) );
            IXX = find( o.IX );
            IXX = IXX(o.PTval(o.T( IXX, 1 )));
            if ~isempty(IXX)
                RP = max( RP, max( o.T( IXX, 7 ) ) ); 
            end
        end
        function RP = righttreepos(o)
        %RIGHTTREEPOS  rp = RIGHTTREEPOS(obj)  rightmost posn of subtree
            RP = o.T( o.IX, 12 );
        end
        function LP = lefttreepos(o)
        %LEFTTREEPOS  rp = LEFTTREEPOS(obj)  leftmost position of subtree
            LP = o.T( o.IX, 11 );
        end
        function RP = righttreeindex(o)
        %RIGHTTREEINDEX  ix = RIGHTTREEINDEX(obj)  Rightmost subtree index
            RP = o.T( o.IX, 14 );
        end
        function RP = rightfullindex(o)
        %RIGHTFULLINDEX  xi = RIGHTFULLINDEX(obj) Right full subtree index
            RP = o.T( o.IX, 15 );
        end
        function oo = trueparent(o)
        %TRUEPARENT  o = TRUEPARENT(obj)  Parent node of a List
            II = o.T( o.IX, 13 );
            II(II==0) = [];
            oo = makeAttrib( o, II );
        end
        function b = isempty( o )
        %ISEMPTY  Deprecated -- use ISNULL
            b = (o.m==0);
        end
        function b = isnull( o )
        %ISNULL  b = ISNULL( obj )  True if obj is empty
        
            b = o.m==0;
        end
        function a = kinds( o )
        %KINDS  a = KINDS( obj )   Return a cell array of Kind names
        
            a = o.KK( o.T( o.IX, 1 ));
        end
        function a = kind( o )
        %KIND  str = KIND( obj )   Return the Kind name for a node
        
            if count(o) ~= 1
                error( 'MATLAB:mtree:kind', 'kind must be called on a single node' );
            end
            a = o.KK{ o.T( o.IX, 1 ) };
        end
        function b = iskind( o, kind )
        %ISKIND  b = ISKIND( obj, K )  true if node has kind K
        %   K may be a string or a cell array of string
        %   b will be a vector if the object has more than one node
        
            b = false(1,o.m);
            I = find( o.IX );
            for i=1:o.m
                ii = I(i);
                oo = makeAttrib( o, ii );
                if ~isnull( mtfind( oo, 'Kind', kind ) )
                    b(i) = true;
                end
            end
        end
        function b = anykind( o, kind )
        %ANYKIND  b = ANYKIND( obj, K )  does any node in obj have Kind K
        %   K may be a string or a cell array of strings
        
            b = any( iskind( o, kind ) );
        end
        function b = allkind( o, kind )
        %ALLKIND  b = ALLKIND( obj, K )  do all nodes in obj have Kind K
        %   K may be a string or a cell array of strings
        
            b = all( iskind( o, kind ) );
        end
        function b = isstring( o, strs )
        %ISSTRING  b = ISSTRING( obj, S ) true if nodes have string S
        %   S may be a string or a cell array of strings
        
            b = false(1,o.m);
            I = find( o.IX );
            for i=1:o.m
                ii = I(i);
                oo = makeAttrib( o, ii );
                if ~isnull( mtfind( oo, 'String', strs ) )
                    b(i) = true;
                end
            end
        end
        function b = allstring( o, strs )
        %ALLSTRING  b = ALLSTRING( obj, S ) true if all nodes have string S
        %   S may be a string or a cell array of strings
        
            b = all( isstring( o, strs ) );
        end
        function b = anystring( o, strs )
        %ANYSTRING  b = ANYSTRING( obj, S ) true if some node has string S
        %   S may be a string or a cell array of strings
        
            b = any( isstring( o, strs ) );
        end
        function b = ismember( o, a )
        %ISMEMBER  b = ISMEMBER( obj, o ) true if node in obj is in o
        
            b = a.IX( o.IX );
        end
        function b = allmember( o, a )
        %ALLMEMBER  b = ALLMEMBER( obj, S ) are all nodes in obj also in o
        
            b = all( ismember( o, a ) );
        end
        function b = anymember( o, a )
        %ANYMEMBER  b = ANYMEMBER( obj, o ) is any node in obj also in o
        
            b = any( ismember( o, a ) );
        end
        function o = select( o, ix )
        %SELECT  o = SELECT( obj, ix )  Index into an Mtree object
        %   o contains those nodes in obj whose indices are in ix
        %   If ix contains an index for a node that is not in obj, and
        %   error is thrown
        
            if ~all( o.IX(ix) )
                error( 'matlab:mtree:select', ...
                       'must select a member of the set of nodes' );
            end
            o.IX = false( 1, o.n );
            o.IX(ix) = true;
            o.m = sum( o.IX );
        end
        function [ln,ch] = lastone( o )
        %LASTONE  [L,C] = lastone( o )  line/char of end of nodes
        %   This returns the positions of the matching paren, bracket, or
        %   END of the nodes in o.
        
            Pos = o.T( o.IX, 7 ); % these are positions
            ln = zeros(length(Pos),1);
            for i=1:length(Pos)
                ln(i) = linelookup( o, Pos(i) );
            end
            ch = Pos - o.lnos(ln);
        end
        function n = nodesize( o )
        %NODESIZE  n = NODESIZE(obj)  Returns the sizes of nodes in obj
        %   n will be an empty array if obj is null
        
             n  = o.T(o.IX,6);
        end
        function I = indices(o)
        %INDICES  ix = INDICES(obj)  Returns a vector of obj node indices
            I = find( o.IX );
        end
        function b = iswhole( o )
        %ISWHOLE  b = ISWHOLE( obj )  Returns true if obj is a whole tree
            b = o.m == o.n;
        end
        function s = tree2str( S, varargin )
        %TREE2STR  s = TREE2STR( obj, args )  Converts a tree into a string
        %   By default, this function converts the subtree of every node
        %   in obj to a string.  Two optional arguments may be supplied:
        %      An amount to indent each line of the output.  Default is 0.
        %      true if only subtrees should be done, false if full subtrees
        %          should be done.  Default is true
        %   As a special case, if a full tree obj is supplied as argument, 
        %   it is treated as List(root(T))
        %   A final argument may be a cell array consisting of pairs of
        %   arguments.  The first member of each pair is an Mtree object
        %   that specifies certain nodes in the tree.  The second member
        %   of each pair is a string.  TREE2STR will replace the subtree
        %   headed by each node in the first member of a pair by the
        %   string when it generates output.

            % return if tree was in error
            if count(S)==0
                s = '';
                return;
            elseif count(S)==1 && iskind(S, 'ERR' )
                 warning( 'Mtree:tree2str:errtree', ...
                         'Syntax error in argument: %s', string( S ) );
                s = '';
                return;
            end 
            if iswhole(S)
                S = List(root(S));
            end
            
            if nargin==2 && iscell( varargin{1} )
                s = tt2ss( S, 0, true, varargin{1} );
            else
                s = tt2ss( S, varargin{:} );
            end

        end
    end
    methods % (Hidden)
        % these methods are only for the very well informed...
        % I wanted to make them protected and Hidden, but the Simulink
        % dependency analysis test explicitly tests for this method
        % being visible.  TODO: track down why this is so....

        function o = setIX( o, I )
        %setIX  o = setIX( o, I )    low-level Mtree constructor
        
            if ~isa( I, 'logical' )
                o.IX = false( 1, o.n );
                o.IX(I) = true;
            else
                o.IX = I;
            end 
            o.m = sum( o.IX );
        end
        function I = getIX( o )
        %getIX  I = getIX( obj )   return the logical index set for obj
        
            I = o.IX;
        end
    end
    methods (Access=protected,Hidden)
        % DEBUGGING: check an object
        function chk( o )
        %CHK  CHK(obj)  Internal use only (for debugging).
            if length( o.IX ) ~= o.n
                error( 'matlab:mtree:internal','bad length for IX.' );
            end
            if o.n > size(o.T,1)
                error( 'matlab:mtree:internal','o.n value out of range.' );
            end
            if o.m < 0 || o.m > o.n
                error( 'matlab:mtree:internal','o.m value out of range.' );
            end
            if sum( o.IX ) ~= o.m
                error( 'matlab:mtree:internal','bad m value.' );
            end
        end
        %{
        function o = makept( o )
        %MAKEPT  obj = makept( obj )  Internal function to make obj.PT
            nn = o.n;
            pt = [ o.T(1:nn,5), o.T(1:nn,5)+o.T(1:nn,6)-1, zeros( nn, 1 ), ...
                    (1:nn)', (1:nn)' ];
            % make links to true parents
            for i=1:o.n
                xL = o.T(i,2);
                xR = o.T(i,3);
                xN = o.T(i,4);
                if xL
                    pt( xL, 3 ) = i;
                end
                if xR
                    pt( xR, 3 ) = i;
                end
                if xN
                    pt( xN, 3 ) = pt( i, 3 );
                end
            end
            IXX = o.PTval( o.T(:,1) );
            pt(IXX,2) = max( pt(IXX,2), o.T(IXX,7) );
            % compute the right positions from back to front
            % also compute the righttreeindex and rightfullindex
            for i=nn:-1:2    % root node has no parent
                p = pt( i, 3 );   % true parent
                if p
                    pt( p, 1 ) = min( pt(i,1), pt(p,1) );
                    pt( p, 2 ) = max( pt(i,2), pt(p,2) );
                end
                p = o.T( i, 9 );   % tree parent
                if p
                    if i ~= o.T(p,4)
                        % note: uses pt(i,5)...
                        pt( p, 4 ) = max( pt(i,5), pt(p,4) );
                    end
                    pt( p, 5 ) = max( pt(i,5), pt(p,5) );
                end
            end
            o.PT = pt;
        end
        %}
    end
end

function [L,MAPS,z] = nodeinfo()
%NODEINFO  [L,MAPS,z] = NODEINFO()  Low-level initialization helper fcn

    [~,K] = mtreemex;
    LINK = { 
               'Left',    2;
               'Right',   3;
               'Next',    4;
               'Body',    3;
               'Arg',     2;
               'Fname',   [2 3 2];
               'Ins',     [2 3 3];
               'Outs',    [2 2];
               'Index',   [2 2];
               'Vector',  [2 3];
               'Cexpr',   [2 3];
               'Cattr',   [2 2];
               'Attr',    2;
               'Try',     2;
               'Catch',   [3 3];
               'CatchID', [3 2];
               'Parent',  9 };
         
    n = length(LINK);
    lnk = cell( 2, n );
    lnk(1,:) = LINK(:,1)';
    lnk(2,:) = num2cell( 1:n );
    L = struct( lnk{:} );
    
    MAPS = LINK(:,2)';
    
    KN = fieldnames(K);
    k = length(KN);
    z = false( n, k );
    saw_op = false( 1, k );
         
    bops = { 'DOTLP' 'PLUS' 'MINUS' 'MUL' 'DIV' 'LDIV' 'EXP' 'COLON' 'DOT' ...
          'DOTMUL' 'DOTDIV' 'DOTLDIV' 'DOTEXP' 'AND' 'OR' 'ANDAND' 'OROR' ...
          'LT' 'GT' 'LE' 'GE' 'EQ' 'NE' 'EQUALS' 'CELL' 'SUBSCR' 'CALL' ...
          'DCALL' 'LP' 'ANON' 'EVENT' 'ATBASE' 'ATTR' 'JOIN' 'CEXPR' };  
      
    uops = { 'DOTTRANS' 'TRANS' 'NOT' 'QUEST' 'UMINUS' 'UPLUS', ...
             'ROW' 'EXPR' 'PRINT', 'GLOBAL', 'PERSISTENT' 'AT', ...
             'LC', 'LB', 'BLKCOM' 'ATTRIBUTES' 'PARENS' 'IF' };
      
    leaves = { 'ID' 'INT' 'DOUBLE' 'STRING' 'DUAL' 'BANG' 'ANONID', ...
               'FIELD', 'ERR', 'BREAK', 'RETURN', 'CONTINUE', 'CELLMARK', ...
               'COMMENT' };
           
    illegal = { 'ERROR' 'COMMA' 'EOL' 'END' 'LIST', 'SEMI', ...
                'RP' 'RB' 'RC', 'ETC', 'BLKEND' 'DISTFOR' };
      
    lbody = { 'WHILE' 'SWITCH' 'CASE' 'CATCH' 'SPMD' 'IFHEAD' 'ELSEIF'};
    
    elother = { 'ELSE', 'OTHERWISE' };
    
    xtry = { 'TRY' };
    
    xfun = { 'FUNCTION' 'PROTO' };
    
    xfor = { 'FOR', 'PARFOR' 'OLDFUN' };
    
    cls = { 'CLASSDEF' };
    
    sect = { 'PROPERTIES' 'METHODS' 'EVENTS' 'ENUMERATION' };
  
    % links allowed for various types
    % we add Next and Parent later
    ni = {
            bops, { 'Left', 'Right' };
            uops, { 'Arg' };
            leaves, {};
            illegal, {};
            lbody, { 'Left', 'Body' };
            elother, { 'Body' };
            xtry, { 'Try', 'Catch' 'CatchID' };
            xfun, { 'Fname', 'Ins', 'Outs', 'Body' };
            xfor, { 'Index', 'Vector', 'Body' };
            cls, { 'Cexpr', 'Cattr', 'Body' };
            sect, { 'Attr', 'Body' };
         };
    
    for i=1:length(ni)
        ops = ni{i,1};
        links = ni{i,2};
        z1 = zeros( 1, length(links) );
        z2 = zeros( 1, length(ops) );
        for ii=1:length(links)
            z1(ii) = L.(links{ii});
        end
        for ii=1:length(ops)
            z2(ii) = K.(ops{ii});
        end
        if any( saw_op(z2) )
            error( 'op %s appears twice, second time in row group %d\n', ...
                             ops{ find( saw_op(z2), 1 ) }, i );
        end
        saw_op(z2) = true;
        if any( z(z1,z2)~=0 )
            error( 'duplicate pair in row group %d', i );
        end
        z(z1,z2) = true;
    end
    
    % check for missing ones
    if any( ~saw_op )
        soix = find( ~saw_op, 1 );
        error( 'op %s (index %d) unaccounted for', KN{ soix }, soix );
    end
     
    %  Fix up next and parent
    z(L.Next,:) = true;
    z(L.Parent,:) = true;
    L.L = L.Left;
    L.R = L.Right;
    L.N = L.Next;
    L.P = L.Parent;
    L.X = L.Next;
      
end
function x = mtree_info(n)
%MTREE_INFO  x = MTREE_INFO(n)  Low-level initialization helper fcn
%   Used to do static initializion of N, K, and KK
    persistent N K KK
    if isempty(N)
        [N,K,v] = mtreemex;
        if ~strcmp( v, mtree.V{2} )
            error( 'MATLAB:mtree:version', ...
                'mtree code expects %s, mtreemex version %s.\n', ...
                mtree.V{2}, v );
        end
        KK = fieldnames( K );
    end
    persistent LNK LMAP LOK
    persistent Uop Bop Stmt
    if isempty(LNK)
        [LNK,LMAP,LOK] = nodeinfo();
    end
    if n==1
        x = N;
    elseif n==2
        x = K;
    elseif n==3
        x = KK;
    elseif n==4   % unary ops
        x = false( 1, length(KK) );
        s = { 'DOTTRANS' 'TRANS' 'NOT' 'QUEST' 'UMINUS' 'UPLUS', ...
                        'ROW' 'AT', 'LC', 'LB' };
        for i=1:length(s)
            x( K.(s{i}) ) = true;
        end
        Uop = x;
    elseif n==5   % binary ops
        x = false( 1, length(KK) );
        s = {'DOTLP' 'PLUS' 'MINUS' 'MUL' 'DIV' 'LDIV' 'EXP' 'COLON' 'DOT', ...
          'DOTMUL', 'DOTDIV', 'DOTLDIV', 'DOTEXP', 'AND', 'OR', ...
          'ANDAND' 'OROR', 'LT', 'GT', 'LE', 'GE', 'EQ', 'NE', ...
          'CELL', 'SUBSCR', 'ANON', 'ATBASE', 'ATTR' }; 
        for i=1:length(s)
            x( K.(s{i}) ) = true;
        end
        Bop = x;
    elseif n==6   % statements
        x = false( 1, length(KK) );
        s =     {'EXPR' 'PRINT' 'GLOBAL' 'PERSISTENT' 'DCALL' ...
                 'BREAK' 'RETURN', 'CONTINUE' 'WHILE' 'SWITCH' ...
                 'CASE' 'IF' 'TRY' 'FOR' 'PARFOR' 'OTHERWISE' ...
                 'DISTFOR' 'CELLMARK' 'COMMENT' 'BLKCOM' 'SPMD' };
        for i=1:length(s)
            x( K.(s{i}) ) = true;
        end
        Stmt = x;
    elseif n==7 % link names
        x = LNK;
    elseif n==8 % link map
        x = LMAP;
    elseif n==9 % is link OK with a node
        x = LOK;
    elseif n==10
        x = Uop | Bop | Stmt;
        x( [K.PARENS K.LP K.RP K.LB K.CALL K.SUBSCR ...
               K.FUNCTION K.CLASSDEF K.PROPERTIES ...
               K.EVENTS K.METHODS K.ENUMERATION K.ETC] ) = true;
    end
end

function s = dequote( s )
    % return the string resulting from removing the quotes from s
    k = 0;
    i = 1;
    n = length(s);
    while i <= n
        if s(i)==''''
            if i+1<=n && s(i+1)==''''
                k = k + 1;
                s(k) = '''';
                i = i + 1;
            end
            i = i + 1;
            continue
        else
            k = k + 1;
            s(k) = s(i);
            i = i + 1;
        end
    end
    s = s(1:k);
end

function s = tt2ss( S, ind, top, map, xmap )
%TT2SS  s = tt2ss( S, ind, top, map, xmap )
%  A non-MCOS version of tree2str, rewritten for speed

    kcom = mtree.K.COMMENT;
    kbcom = mtree.K.BLKCOM;
    kcell = mtree.K.CELLMARK;
    T = S.T;
    C = S.C;
    IX = indices(S);
    s = '';
    persistent opclass opinfo KK K
    if isempty( opinfo )
        opclass = zeros( 1, length( mtree.KK ) );
        opinfo = cell( length( mtree.KK ), 3 );
        % expression cases
        %   0:  leaf
        %   1:  unary prefix
        %   2:  binary
        %   3:  unary suffix ('),
        %   4:  indexing, etc.
        %   5:  =
        %   6:  .
        %   7:  [ ] initialization
        %   8:  { } initialization
        %   9:  ROW
        %  10:  ANON
        %  11:  ATTR
        %  12:  ATBASE
        %  13:  illegal
        % two strings supplied as well
        %       opcode    prec case s1      s2
        precs = {
                'ID'        0   0   ''      ''
                'ANONID'    0   0   ''      ''
                'INT'       0   0   ''      ''
                'DOUBLE'    0   0   ''      ''
                'DUAL'      0   0   ''      ''
                'STRING'    0   0   ''      ''
                'PARENS'   15   1   '('     ')'
                'RP'        1  13   ''      ''
                'RC'        1  13   ''      ''
                'RB'        1  13   ''      ''
                'EQUALS'    2   5   '='     ''
                'ATTR'      2  11   '='     ''
                'OROR'      3   2   ' || '  ''
                'ANDAND'    4   2   ' && '  ''
                'OR'        5   2   ' | '   ''
                'AND'       6   2   ' & '   ''
                'GT'        7   2   '>'     ''
                'LT'        7   2   '<'     ''
                'GE'        7   2   '>='    ''
                'LE'        7   2   '<='    ''
                'EQ'        7   2   '=='    ''
                'NE'        7   2   '~='    ''
                'COLON'     8   2   ':'     ''
                'PLUS'      9   2   ' + '   ''
                'MINUS'     9   2   ' - '   ''
                'MUL'      10   2   '*'     ''
                'DOTMUL'   10   2   ' .* '  ''
                'DIV'      10   2   '/'     ''
                'DOTDIV'   10   2   ' ./ '  ''
                'LDIV'     10   2   '\'     ''
                'DOTLDIV'  10   2   ' .\ '  ''
                'NOT'      11   1   '~'     ''
                'AT'       11   1   '@'     ''
                'UMINUS'   11   1   '-'     ''
                'UPLUS'    11   1   '+'     ''
                'EXP'      12   2   '^'     ''
                'DOTEXP'   12   2   ' .^ '  ''
                'DOTTRANS' 13   1   ''      '.'''
                'QUEST'    13   1   '?'     ''
                'TRANS'    14   3   ''''    ''   % separate line to handle ('abc')'
                'LP'       15   4   '( '    ' )'
                'CALL'     15   4   '( '    ' )'
                'SUBSCR'   15   4   '( '    ' )'
                'CELL'     15   4   '{ '    ' }'
                'LC'       15   8   '{'     '}'
                'LB'       15   7   '['     ']'
                'DOT'      15   6   '.'     ''
                'ATBASE'   15  12   '@'     ''
                'DOTLP'    15   4   '.('	')'
                'ROW'       2   9   ';'     ''
                'ANON'      2  10   '@('    ')'
%                'DOTID'    15   0   ''      ''    % K doesn't define yet
            };
        % statement cases
        %  1:  function
        %  2:  class
        %  3:  properties
        %  4:  methods
        %  5:  events
        %  6:  enumeration
        %  7:  expr and print
        %  8:  if/ifhead/elseif/else
        %  9:  while
        % 10:  for, parfor, distfor
        % 11:  try/catch
        % 12:  break, continue, return
        % 13:  switch
        % 14:  case
        % 15:  otherwise
        % 16:  global / persistent
        % 17:  dual call
        % 18:  bang
        % 19:  CELLMARK
        % 20:  PROTO
        % 21:  SPMD
        % 22:  Comment / block comment
        stmts = {
                'FUNCTION'     -1   1   'function'      ''
                'CLASSDEF'     -1   2   'classdef'      ''
                'PROPERTIES'   -1   3   'properties'    ''
                'METHODS'      -1   4   'methods'       ''
                'EVENTS'       -1   5   'events'        ''
                'ENUMERATION'  -1   6   'enumeration'   ''
                'EXPR'         -2   7   ';'             ''
                'PRINT'        -2   7   ''              ''
                'IF'           -2   8   'if '           ''
                'IFHEAD'       -2   8   'if '           ''
                'ELSEIF'       -2   8   'if '           ''
                'ELSE'         -2   8   'if '           ''
                'WHILE'        -2   9   'while '        ''
                'FOR'          -2  10   'for '          ''
                'PARFOR'       -2  10   'parfor '       ''
                'DISTFOR'      -2  10   'for '          ''
                'TRY'          -2  11   'try'           'catch'
                'BREAK'        -2  12   'break'         ''
                'CONTINUE'     -2  12   'continue'      ''
                'RETURN'       -2  12   'return'        ''
                'SWITCH'       -2  13   'switch '       ''
                'CASE'         -3  14   'case '         ''
                'OTHERWISE'    -3  15   'otherwise'     ''
                'GLOBAL'       -2  16   'global '       ''
                'PERSISTENT'   -2  16   'persistent '   ''
                'DCALL'        -2  17   ''              ''
                'BANG'         -2  18   ''              ''
                'CELLMARK'     -2  19   ''              ''
                'PROTO'        -2  20   ''              ''
                'SPMD'         -2  21   'spmd'          ''
                'COMMENT'      -2  22   ''              ''
                'BLKCOM'       -2  23   ''              ''
            };
        KK = mtree.KK;
        K = mtree.K;
        for ii=1:length( precs )
            ixx = K.(precs{ii,1});
            opclass(ixx) = precs{ii,2};
            [opinfo{ ixx,1:3 }] = deal( precs{ii,3:5} );
        end
        for ii=1:length( stmts )
            ixx = K.(stmts{ii,1});
            opclass(ixx) = stmts{ii,2};
            [opinfo{ ixx,1:3 }] = deal( stmts{ii,3:5} );
        end
    end
    n = size( T, 1 );    % a bit larger than o.n
    if isempty(IX)
        return;
    end    
    if nargin < 2
        ind = 0;
    end
    if nargin < 3
        top = false;
    end
    if nargin < 4
        map = {};
    end
    if nargin < 5
        map = map(:);   % make it one dimensional
        xmap = zeros( 1, n );
        for imp=1:2:length(map)
            xmap( indices( map{imp} ) ) = imp+1;
            if ~ischar( map{imp+1} )
                error( 'mtree:tree2str:mapstr', [ 'The second member ', ...
                        'of a map pair must be a string.' ] );
            end
        end
    end
    sout = ' ';
    sout = sout( ones( 1, (8*n) ) );  % preallocate output string
    k = 0;
    if top
        % loop over IX, collecting info
        for iix=IX
            stmt2str( iix, ind, true );
        end
    else
        % it's a List, so just pass the first one...
        stmt2str( IX(1), ind, false );
    end
    s = sout(1:k);

    function scat( s, ind )
        n = length(s);
        if nargin > 1 && ind
            if k+4*ind > length(sout)
                sout = [ sout sout ];
            end
            kk = k + 4*ind;
            %if kk > length( sout )
            %    for i=1:4*ind
            %        sout(k+i) = ' ';
            %    end
            %end
            sout( k+1:kk ) = ' ';
            k = kk;
        end
        if n
            kk = k+n;
            if kk > length(sout)
                sout = [ sout sout ];
            end
        %for ij=1:n
        %    sout( k+ij ) = s(ij);
        %end
            sout( (k+1):kk ) = s;
            k = kk;
        end
    end
    function ix = ixpath( ix, s )
        if ~ix
            return;
        end
        switch( s )
            case { 'L' 'Left' 'Arg' 'Try' 'Attr' }
                ix = T(ix,2);
                return;
            case { 'R' 'Right' 'Body' }
                ix = T(ix,3);
                return;
            case { 'Next' 'X' 'N' }
                ix = T(ix,4);
                return;
            case 'P'
                ix = T(ix,9);
                return;
            case {'CatchID' }
                pth = [3 2];
            case {'Catch' }
                pth = [3 3];
            case 'Ins'
                pth = [2 3 3];
            case { 'Outs' 'Index' 'Cattr' }
                pth = [2 2];
            case  { 'Vector' 'Cexpr'}
                pth = [2 3 ];
            case 'L.N'
                pth = [ 2 4 ];
            case 'Fname'
                pth = [2 3 2];
            otherwise
                error( 'MATLAB:mtree:tree2str', 'ixpath needs %s', s );
        end
        ix = T(ix, pth(1) );
        for ixj=2:length(pth)
            if ~ix
                return;
            end
            ix = T(ix,pth(ixj));
        end
    end
    function n = ixlength( ix )
        n = 0;
        while ix
            n = n + 1;
            ix = T( ix, 4 );
        end
    end
    function ss = ixstring( ixt )
        ss = '';
        if ~ixt
            return;
        end
        if xmap(ixt)
            ss = map{xmap(ixt)};
            return;
        end
        six = T(ixt,8);
        if ~six
            return;
        end
        ss = C{six};
    end
    function ixc = followcom( s, ixt, top )
        if top
            % we don't look at the next one, since
            % we aren't allowed to
            scat( [s 10] );
            ixc = ixt;
            return
        end
        if T(ixt,1)==K.ID
            endpos = T(ixt,5);  % position (for enumerations)
        else
            endpos = T(ixt,7);  % end of statement
        end
        %fprintf( 'index %d, endpos %d\n', ixt, endpos );
        ixcf = T(ixt,4);  % first location of possible comment
        % we look for a string of comments.  If none, or if we do not find
        % one that follows the current statement, we print s and return
        % Otherwise we print s and the following comment, then print all
        % the comments up to the following comment, and then return ixc
        if ~ixcf || ( T(ixcf,1) ~= kcom && T(ixcf,1) ~= kbcom && ...
                                          T(ixcf,1) ~= kcell )
            % next one is not a comment
            % print s and return
            ixc = ixt;
            scat( [s 10] );
            return
        end
        
        % the next one, and possibly following ones, are comments
        % Look for one that follows the statement
        ixc = ixcf;
        last = false;
        while true
            % ixc is a COMMENT, BLKCOM, or CELLMARK
            cpos = T(ixc,5);
            if cpos > endpos
                last = true;   % the last one we will look at
            end
            if T(ixc,1) ~= kcom
                % not a COMMENT -- keep going
                ixc = T(ixc,4);
                if last && ~ixc || ( T(ixc,1)~= kcom && ...
                                     T(ixc,1) ~= kbcom && ...
                                     T(ixc,1) ~= kcell )
                    % no following comments -- return to caller
                    ixc = ixt;
                    scat( [s 10] );
                    return
                end
                continue
            end
            % ixc is a COMMENT -- see if it is at the end of ixt
            if cpos > endpos
                ins = S.str( endpos+1:cpos );
            else
                ins = S.str( cpos:endpos-1 );
            end
            if any( ins==10 )
                % look at next comment
                ixc = T(ixc,4);
                if last || ~ixc || ( T(ixc,1)~= kcom && ...
                                     T(ixc,1) ~= kbcom && ...
                                     T(ixc,1) ~= kcell )
                    % no following comments -- return to caller
                    ixc = ixt;
                    scat( [s 10] );
                    return
                end
                continue;   % just continue
            end
            % we found a continuation comment
            scat( [s '  ' ixstring(ixc) 10] );  % put it on the end
            % we will return ixc.  But first we print the comments
            % between ixt and ixc
            ix = ixcf;
            while ix ~= ixc
                stmt2str( ix, ind, true );  % print comment
                ix = T(ix,4);
            end
            return
        end
    end

    function ixt = bodycom( s, ixt )
        % this acts like followcom, but looks at the Body (or similar)
        % for the same-line comment.  We don't need to worry about other
        % comments getting in the way...
        pos = T(ixt,5);
        ixt = T(ixt,3);   % the body or right-hand size
        if ~ixt || T(ixt,1)~=kcom
            % complete the previous line, and continue down the body
            scat( [ s 10 ] );
            return
        end
        cpos = T(ixt,5);
        ins = S.str( pos:cpos );
        if any( ins==10 )
            % just finish current, start again on the body
            scat( [ s 10 ] );
            return
        end
        % output the comment, continue on next one
        scat( [s '  ' ixstring(ixt) 10] );
        ixt = T(ixt,4);
    end
    function ixt = trycom( s, ixt )
        % this acts like bodycom, but looks at the left (Try) side
        % for the same-line comment.  We don't need to worry about other
        % comments getting in the way...
        pos = T(ixt,5);
        ixt = T(ixt,2);   % the Try or left-hand size
        if ~ixt || T(ixt,1)~=kcom
            % complete the previous line, and continue down the body
            scat( [ s 10 ] );
            return
        end
        cpos = T(ixt,5);
        ins = S.str( pos:cpos );
        if any( ins==10 )
            % just finish current, start again on the body
            scat( [ s 10 ] );
            return
        end
        % output the comment, continue on next one
        scat( [s '  ' ixstring(ixt) 10] );
        ixt = T(ixt,4);
    end

    function stmt2str( ixt, ind, top )
        if nargin < 3
            top = false;
        end
        while ixt
            if imap( ixt )
                if top
                    return;
                end
                ixt = T(ixt,4);
                continue;
            end
            
            % here is a tree to do
            op = T(ixt,1);
            %kk = KK{op};
            if opclass( op ) >= 0
                % oops, it's an expression.  But that's OK.  The
                % indentation is just the precedence--we ignore top
                expr2str( ixt, ind );
                return;
            end
            switch opinfo{ op, 1 }
                case 1  %'FUNCTION'
                    fix = ixpath( ixt, 'Ins' );
                    fox = ixpath( ixt, 'Outs' );
                    % call tree2str to get mapping
                    if fox
                        if ixlength(fox)==1
                            scat( ['function ' ixstring(fox) ' = ' ], ind );
                        else
                            scat( 'function [', ind );
                            list2str(fox, ',' );
                            scat( '] = ' );
                        end
                    else
                        scat( 'function ', ind );
                    end
                    expr2str( ixpath( ixt, 'Fname' ), 0 );
                    if fix
                        scat( '(' );
                        list2str( fix, ',');
                        ibt = bodycom( ')', ixt );
                    else
                        ibt = bodycom( '', ixt );
                    end
                    stmt2str( ibt, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 2 %'CLASSDEF'      
                    scat( 'classdef ', ind );
                    av = ixpath( ixt, 'Cattr' );
                    if av
                        attrs( av );
                        scat( ' ' );
                    end
                    cx = ixpath( ixt, 'Cexpr' );
                    if ~imap( cx )
                        expr2str( cx );
                    end
                    B = bodycom( '', ixt );
                    stmt2str( B, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 3 %'PROPERTIES'
                    scat( 'properties ', ind );
                    attrs( ixpath( ixt, 'Attr' ) );
                    B = bodycom( '', ixt );
                    props( B, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 4 % 'METHODS'
                    scat( 'methods ', ind );
                    attrs( ixpath( ixt, 'Attr' ) );
                    B = bodycom( '', ixt );
                    stmt2str( B, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 5 % 'EVENTS'
                    scat( 'events ', ind );
                    attrs( ixpath( ixt, 'Attr' ) );
                    B = bodycom( '', ixt );
                    evnts( B, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 6 % 'ENUMERATION'
                    scat( 'enumeration ', ind );
                    attrs( ixpath( ixt, 'Attr' ) );
                    B = bodycom( '', ixt );
                    enums( B, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 7 % 'EXPR' and 'PRINT'
                    scat( '', ind );   % indentation
                    expr2str( T(ixt,2), 1 );
                    ixt = followcom( opinfo{op,2}, ixt, top );
                case 8 % 'IF'            
                    scat( 'if ', ind );
                    ixtt = T(ixt,2);      % find the IFHEAD
                    if ~imap( ixtt )
                        expr2str( T(ixtt,2), 1 );   % condition
                        ibt = bodycom( '', ixtt );
                        % the 'Then' part
                        stmt2str( ibt, ind+1 );
                    end
                    % now, handle ELSEIF and ELSE nodes
                    % we tell the difference because ELSE has left descendent null
                    while true
                        ixtt = T(ixtt, 4 );   % next piece of IF statement
                        if ~ixtt
                            break
                        end
                        if ~imap( ixtt )
                            if T(ixtt,2)  % elseif
                                scat( 'elseif ', ind );
                                expr2str( T(ixtt,2), 1 );
                            else
                                scat( 'else', ind );
                            end
                            ibt = bodycom( '', ixtt );
                            stmt2str( ibt, ind+1 );
                        end
                    end
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 9 % 'WHILE'
                    scat( 'while ', ind  );
                    expr2str( T(ixt,2), 1 );
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 10 % 'FOR', 'PARFOR'          
                    ees = ixpath( ixt, 'L.N' ); % expression list
                    if ees  % parfor with expressions
                        scat( ['parfor( ' ixstring( ixpath( ixt, 'Index' ) ) ' = '], ind );
                        expr2str( ixpath( ixt, 'Vector' ), 1 );
                        scat( ', ' );
                        list2str( ees, ', ' );
                        scat( ' )' );
                    else
                        scat( [opinfo{op,2} ixstring( ixpath( ixt, 'Index' ) ) ' = '], ind );
                        expr2str( ixpath( ixt, 'Vector' ), 1 );
                        scat( [ opinfo{op,3} ] );
                    end
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 11 % 'TRY'
                    scat( 'try', ind );
                    itb = trycom( '', ixt );
                    stmt2str( itb, ind+1 );
                    % there might be a CATCH node with no contents
                    cn = T( ixt, 3 );  
                    if cn
                        scat( 'catch', ind );
                        tcx = T( cn, 2 ); 
                        if tcx
                            scat( [' ' ixstring(tcx)] );
                        end
                        tc = bodycom( '', cn );
                        if tc 
                            stmt2str( tc, ind+1 );
                        end
                    end
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 12 % 'BREAK', 'CONTINUE', 'RETURN'         
                    scat( opinfo{op,2}, ind );
                    ixt = followcom( '', ixt, top );
                case 13 % 'SWITCH'  
                    scat( 'switch ', ind );
                    expr2str( T(ixt,2), 1 );
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 14 % 'CASE'
                    scat( 'case ', ind );
                    TL = ixpath( ixt, 'L' );
                    if ixlength( TL ) > 1
                        scat( '{' );
                        list2str( TL, ', ' );
                        scat( '}' );
                    else
                        expr2str( TL, 1 );
                    end 
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                case 15 % 'OTHERWISE'
                    scat( 'otherwise', ind );
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                case 16 % 'GLOBAL', 'PERSISTENT'        
                    scat( opinfo{ op, 2 }, ind );
                    list2str( T(ixt,2), ' ' );
                    ixt = followcom( '', ixt, top );
                case 17 % 'DCALL'         
                   scat( [ixstring( ixpath( ixt, 'L' ) ) ' '], ind );
                   list2str( ixpath( ixt, 'R' ), ' ' );
                   % if T(ixt,7)  % command dual followed by ;
                   if S.str( T(ixt,7) ) == ';'   % command dual, then ;
                       scat( ' ;' );
                   end
                   ixt = followcom( '', ixt, top );
                case 18 % 'BANG'
                    scat( ixstring( ixt ), ind );
                    ixt = followcom( '', ixt, top );
                case 19 % 'CELLMARK'
                    scat( [strtrim(ixstring( ixt )) 10 ], ind );
                case 20 % 'PROTO'
                    fix = ixpath( ixt, 'Ins' );
                    fox = ixpath( ixt, 'Outs' );
                    if fox
                        if ixlength(fox)==1
                            scat( [ixstring(fox) ' = ' ], ind );
                        else
                            scat( '[', ind );
                            list2str(fox, ',' );
                            scat( '] = ' );
                        end
                    end
                    expr2str( ixpath( ixt, 'Fname' ), 0 );
                    if fix
                        scat( '(' );
                        list2str( fix, ',');
                        scat( ')' );
                    end
                    ixt = followcom( '', ixt, top );
                case 21 % 'SPMD'
                    scat( 'spmd ', ind );
                    TL = ixpath( ixt, 'L' );
                    if TL
                        scat( '( ' );
                        TL = ixpath( ixt, 'L' );
                        list2str( ixpath( TL, 'L' ), ',' );
                        scat( ' )' );
                    end
                    ibt = bodycom( '', ixt );
                    stmt2str( ibt, ind+1 );
                    scat( 'end', ind );
                    ixt = followcom( '', ixt, top );
                case 22 % comment
                    comstring = strtrim( ixstring(ixt) );  % strip blanks
                    if isempty(comstring) || comstring(1) ~= '%'
                        comstring = [ '%  ' comstring ];  %#ok<AGROW> % for ... comments
                    end
                    scat( [comstring 10], ind );
                case 23 % block comment
                    scat( [ '%{' 10 ], ind );
                    stmt2str( T(ixt,2), 0, false );
                    scat( [ '%}' 10 ], ind );

                otherwise
                    error( 'MATLAB:mtree:tree2str', ...
                           'bad statement kind %s', KK{op} );
            end
            if top
                return
            end
            ixt = T(ixt,4);
        end
    end
    function attrs( ixt )
        % attribute list is ATTR nodes with attribute on lhs,
        % value on rhs
        if ~ixt || imap( ixt )
            return;
        end
        ixt = T(ixt,2);
        scat( '(' );
        sep = '';
        while ixt
            if ~imap(ixt)
                lhs = T( ixt, 2 );
                rhs = T( ixt, 3 );
                if ~rhs 
                    scat( [sep ixstring( lhs ) ] );
                elseif T(rhs,1)==K.NOT && ~T(rhs,2)
                    scat( [sep '~' ixstring( lhs )] );
                else
                    scat( [sep ixstring( T(ixt,2) ) '='] );
                    expr2str( T(ixt,3) ); 
                end
                sep = ', ';
            end
            ixt = T(ixt,4);
        end
        scat( ')' );
    end
    function props( ixt, ind )
        while ixt
            if ~imap( ixt )
                if T(ixt,1)==kcom || T(ixt,1)==kbcom || T(ixt,1)==kcell
                    stmt2str( ixt, ind, true );
                    ixt = T(ixt,4);
                    continue;
                end
                rt = T(ixt,3);
                scat( '', ind );
                expr2str( T(ixt,2) );
                if rt
                    scat( ' = ' );
                    expr2str( rt );
                end
                ixt = followcom( '', ixt, false );
            end
            ixt = T(ixt,4);
        end
    end
    function evnts( ixt, ind )
        while ixt
            if imap( ixt )
                ixt = T(ixt,4);
                continue;
            end
            if T(ixt,1)==kcom||T(ixt,1)==kbcom||T(ixt,1)==kcell
                stmt2str( ixt, ind, true );  % print comment
            else
                rt = T(ixt,3);
                scat( ixstring( T(ixt,2) ), ind );
                if rt
                    scat( '(' );
                    expr2str( rt );
                    scat( ')' );
                end
                ixt = followcom( '', ixt, false );
            end
            ixt = T(ixt,4);
        end
    end
    function enums( ixt, ind )
        while ixt
            if imap( ixt )
                ixt = T(ixt,4);
                continue;
            end
            if T(ixt,1)==kcom || T(ixt,1)==kbcom || T(ixt,1)==kcell
                % print a comment
                stmt2str( ixt, ind, true );
            else
                scat( '', ind );  % just do the indentation
                expr2str( ixt, 1 );
                ixt = followcom( '', ixt, false );
            end
            ixt = T(ixt,4);
        end                
    end

    function b = imap( ixt )
        if xmap(ixt)
            scat( map{xmap(ixt)} );
            b = true;
            return;
        else
            b = false;
        end
    end

    function expr2str( ixt, lev )
        % T is a node
        if ~ixt 
            return;
        end
        if nargin < 2
            lev = 1;
        end
        if imap(ixt)
            return;
        end
        close = '';
        tlev = lev;
        op = T(ixt,1);
        switch( opinfo{ op, 1 } )
            case 0    %  leaf nodes
                scat( [ ixstring( ixt ) close] );
                return;
            case 1    %  unary operators
                scat( opinfo{ op, 2 } );
                expr2str( T(ixt,2), tlev );
                scat( [ opinfo{ op, 3 } close ] );
                return;
            case 2    %  binary operators
                binary( ixt, opinfo{ op, 2 }, tlev );
                scat( [ opinfo{ op, 3 } close ] );
                return;
            case 3    %  unary suffix (')
                a = T( ixt, 2 );
                if T(a,1) == K.STRING
                    % need parens
                    scat( '(' );
                    expr2str( a, 0 );
                    scat( [')''' close] );
                else
                    expr2str( a, tlev );
                    scat( ['''' close] );
                end
                return;
          case 4    %  indexing, etc.
                rx = T(ixt,3);
                if ~rx
                    % should only happen for calls
                    lx = T(ixt,2);
                    knd = T(ixt,1);
                    expr2str( lx, tlev );
                    % a MATLAB mess--if the opcode is SUBSCR, print ()
                    % also, if the CALL node does not have the same
                    % position as the LHS, generate ()
                    if knd == K.SUBSCR || knd == K.LP || ...
                            (knd == K.CALL && T(lx,5)~=T(ixt,5))
                        scat( [ '()' close] );   % print a()
                    else
                        scat( close );
                    end
                else
                    expr2str( T(ixt,2), tlev );
                    scat( opinfo{ op, 2 } );
                    list2str( T(ixt,3), ', ' );
                    scat( [ opinfo{ op, 3 } close ] );
                end 
                return
            case 5    %  =
                lhs = T(ixt,2);
                rhs = T(ixt,3);
                if lhs && ~imap( lhs )
                    if T(lhs,1)==K.LB
                        lhslist = T(lhs,2);
                        scat( '[' );
                        list2str( lhslist, ',' );
                        scat( ']' );
                    else
                        expr2str( lhs, tlev );
                    end
                end
                scat( ' = ' );
                if rhs && ~imap( rhs )
                    expr2str( rhs, tlev );
                end
                scat( close );
                return
            case 6	  %  .
                expr2str( T(ixt,2), tlev );
                scat( [ '.' ixstring( T(ixt,3) ) close ] );
                return;
            case 7    %  [] initialization    
                tr = T(ixt,2);
                if ~tr
                    scat( ['[]' close] );
                else
                    scat( '[ ' );
                    list2str( tr, '; ' );
                    scat([ ' ]' close] );
                end
                return;
            case 8	  %  {} initialization
                tr = T(ixt,2);
                if ~tr
                    scat( ['{}' close] );
                else
                    scat( '{ ' );
                    list2str( tr, '; ' ); 
                    scat( [' }' close] );
                end
                return;
            case 9    %  ROW
                ta = T(ixt,2);
                if ta
                    list2str( ta, ', ');
                end
                scat( close );
                return;
            case 10   %  ANON
                scat( '@(' );
                list2str( T(ixt,2), ',' );
                scat( ') ' );
                expr2str( T(ixt,3), 2 );
                scat( close );
                return;
            case 11     %  ATTR
                attrs( ixt );
                return;
            case 12     %  ATBASE
                
                expr2str( T(ixt,2), 2 );
                scat( '@' );
                vr = T(ixt,3);
                sep = '';
                while( vr )
                    scat( [ sep ixstring(vr) ] );
                    vr = T(vr,4);  % next one
                    sep = ' ';
                end
                return
            otherwise   %  other
                error( 'MATLAB:mtree:tree2str', 'unknown expr node %s', mtree.KK{op} );
        end
    end
    % this is more subtle than it looks
    % if we have a*b*c, this naturally parses as
    %     (a*b)*c
    % if we see a tree that looks like
    %     a*(b*c)
    % we need to put parens back in to preserve this
    % we can get this effect by upping the precedence on the rhs
    % TODO:  with PARENS, is this logic still needed?
    % TODO:  what's the best way to make substitutions OK w.r.t. parens?
    function binary( ixt, ss, lev )
        if imap( ixt )
            return;
        end
        vr = T(ixt,3);
        expr2str( T(ixt,2), lev );
        scat( ss );
        expr2str( vr, lev+1 );
    end
    function list2str( ixt, ss )
        later = false;
        while ixt
            if later
                scat( ss );
            end
            later = true;
            if ~imap(ixt)
                expr2str( ixt, 1 );
            end
            ixt=T(ixt,4);
        end
    end
end

% helper function for pathit -- it collects qualifiers and returns
% them in flag
function [j,flag,pth] = collect_qualifiers( pth, ipath, dots, j )
    flag = 0;
    if isempty( pth )
        return;
    end
    
    pend = pth(end);
    if pend=='+' || pend=='*' || pend=='&' || pend== '|'
        % old-style qualifiers.  Collect and return
        while ~isempty( pth )
            pend = pth(end);
            if pend=='+'
                add_list();
            elseif pend=='*'
                add_tree();
            elseif pend=='&'
                add_all();
            elseif pend=='|'
                add_any();
            else
                % we are done
                return
            end
            pth(end) = '';   % delete last character
        end
        return    % nothing but qualifiers
    end
    
    % this is the new style, with later qualifiers separated by dots
    if is_qual( pth )
        % sets flag if true
        % in this case, we return a pth of ''
        pth = '';
        % but we still look for further qualifiers
    end
    % j is set to look for the next link
    while( j < length(dots) )
        if is_qual( ipath( dots(j)+1:dots(j+1)-1 ) )
            j = j + 1;
            continue
        end
        break
    end
    return
    
    function b = is_qual( str )
        b = true;
        switch( str )
            case 'List'
                add_list();
                return;
            case 'Tree'
                add_tree();
                return;
            case 'Full'
                add_full();
                return;
            case 'All'
                add_all();    
                return;
            case 'Any'
                add_any();
                return;
            otherwise
                b = false;
                return
        end
    end
    
    function add_all
        if bitand(flag,12)
            error( 'matlab:mtree:andor', ...
                   'more than one "&", "|", Any, or All per path segment' );
        end
        flag = flag + 4;
    end
    function add_any
        if bitand(flag,12)
            error( 'matlab:mtree:andor', ...
                   'more than one "&", "|", Any, or All per path segment' );
        end
        flag = flag + 8;
    end
    function add_list
        if bitand(flag,1)
            error( 'matlab:mtree:plus', ...
                   'more than one "+" or "List" per path segment' );
        end
        flag = flag + 1;
    end
    function add_tree
        if bitand(flag,2)
            error( 'matlab:mtree:star', ...
                   'more than one "*" or "Tree" per path segment' );
        end
        flag = flag + 2;
    end
    function add_full
        if bitand(flag,3)
            error( 'matlab:mtree:star', ...
                   '"Full" used with "Full", "List", or "Tree"' );
        end
        flag = flag + 3;
    end
end
