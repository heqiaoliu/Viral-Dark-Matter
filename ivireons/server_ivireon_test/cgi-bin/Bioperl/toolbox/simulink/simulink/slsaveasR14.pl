###################################
# the below line can be moved to the top for debugging purposes.
#! /usr/local/bin/perl
###################################
#
# Modifys an mdl file outside of Simulink to match an
# earlier release 

###########################################
# What this script does ....
#  1) This reads in a data file and creates a list of 
#     rules to change the model file to the older format
#  2) reads the model file into an object heirarchy
#  3) applys the rules
#  4) writes the resulting object heirarchy to the 
#     new model file.
###########################################

# Copyright 1990-2010 The MathWorks, Inc.
# 

($dataFile) = @ARGV;

open(DAT_IN, "<$dataFile") || die "Unable to open $dataFile";
my(@all_lines) = <DAT_IN>;
close(DAT_IN);

chomp($infilename       = shift(@all_lines)); # line 1
chomp($outfilename      = shift(@all_lines)); # 2
chomp($maxLineLen       = shift(@all_lines)); # 3
chomp($numFiles         = shift(@all_lines)); # 4

RULEFILE: for ($idx = 1; $idx <= $numFiles; $idx += 1){
    $ruleFile = shift(@all_lines);
    # if we are saving to the current version there may not
    # be a rule file.
    open(RULE_IN, "<$ruleFile") || next RULEFILE;
    @rule_lines = <RULE_IN>;
    close(RULE_IN);

    # add rule_lines at the end of all lines
    splice(@all_lines, -1, 0, @rule_lines);
}

$rules = get_rules(\@all_lines);              # lines 5+
UpdateModel($infilename, $outfilename, $rules);

#################################################
sub get_rules()
{
    my($lines_ref) = shift;

    
    my(@rule_sets);
    my($sets_ref) = \@rule_sets;

    read_rules($sets_ref, $lines_ref);

    return $sets_ref;
}

################################################
sub UpdateModel
{
  ($mdl_IN,$mdl_OUT,$rules_ref) =  @_;

  open(IN, "<$mdl_IN") || die "Unable to open $mdl_IN";
  open(OUT,">$mdl_OUT") || die "Unable to create $mdl_OUT. Please check the directory permission\n";

  $mdl_ref   = read_top_obj(IN);

  foreach $rule ( @{$rules_ref}){
      tree_walk($mdl_ref, $rule, \&rule_match);
  }

  write_obj(OUT, $mdl_ref);
}

#################################################
# rule object functions
#################################################
# rules are hashes of the form
# hash->names    name of this object
# hash->val      required value for this object
# hash->action   action key for this location
# hash->subs     further rules for sub objects of this object
#                 this is a 2D array with the first index showing 
#                 logical OR and the second showing logical AND

# example:
#  %hash->name       = model
#       ->action     = ""
#       ->subs->[0]  =  %hash2->name    = version
#                         ->action      = rename 6.1,,6.0
#                         ->val         = "6.1"
#                         ->subs->[0]   = ();
#################################################
sub new_ruleref
{
    my($name, $val, $action) = @_;

    my($ref);
    {
        my(%new_rule);
        $new_rule{"name"} = escape_symbolic_ref($name);
        $new_rule{"val"} = $val;
        $new_rule{"symval"} = 0;
        $new_rule{"action"} = $action;
        $new_rule{"priority"} = 2;
        $new_rule{"subs"} = [[]];
        $ref = \%new_rule;
    }
    return $ref;
}

# This function has been added to display a rule 
# while in the perl debugger.  Under normal circumstances
# it will not be called.
sub pr
{
    my($rule) = shift;
    my($indent) = shift;
    my($after) = 0;

    print $indent;
    print $rule->{"priority"}, " ", 
          $rule->{"name"},     " | ", 
          $rule->{"val"},      " ",
          $rule->{"symval"},   " : ", 
          $rule->{"action"},   "\n";

    foreach $orset ( @{ $rule->{"subs"}} ){
        if($after){
            print $indent, "-----\n";
        }
        foreach $kid ( @{$orset} ){
            pr($kid, $indent."  ");
        }
        $after = 1;
    }
}

sub comp_rules
{
    my($ruleA) = shift;
    my($ruleB) = shift;
    
    return 0 if ($ruleA->{"name"}     ne $ruleB->{"name"});
    return 0 if ($ruleA->{"val"}      ne $ruleB->{"val"});
    return 0 if ($ruleA->{"action"}   ne $ruleB->{"action"});
    return 0 if ($ruleA->{"priority"} ne $ruleB->{"priority"});
  # insert actions are never equal because we don't know what is in $hold
    return 0 if ($ruleA->{"action"} eq "insert");
    return 0 if ($ruleA->{"action"} eq "insertsib");
    return 0 if ($ruleA->{"action"} eq "remove");
    return 1;
}

sub last_orset_ref
{
    my($rule) = shift;
    return $rule->{"subs"}->[ $#{$rule->{"subs"}} ];
}

sub add_orsubrule
{
    my($toprule) = shift;
    my($subrule) = shift;

    # if the last orset is empty put this rule there
    if(scalar( @{ last_orset_ref($toprule) } ) == 0 ){
        add_subrule($toprule,$subrule);
    }else{
        # if the last orset is not empty create a new one and
        # add it to toprule
        my($tmp_orset) = [ $subrule ];
        push( @{ $toprule->{"subs"}},$tmp_orset)
    }
}

sub add_orset
{
    my($toprule) = shift;
    my($orsetref) = shift;
    push( @{ $toprule->{"subs"}}, $orsetref);
}

sub add_subrule
{
    my($toprule) = shift;
    my($subrule) = shift;
    my($orset) = last_orset_ref($toprule);
    push( @{$orset}, $subrule);
}

sub add_rule
{
    my($arrayref) = shift;
    my($newrule) = shift;
    my($found)   = 0;

    foreach $toprule (@{ $arrayref }){
        if( comp_rules($toprule, $newrule) ){
            
            foreach $orset ( @{$newrule->{"subs"}} ){
                add_orset($toprule, $orset);
            }
            $found = 1;
            last;
        }
    }
    
    if (!($found)){
        push( @{ $arrayref }, $newrule);
    }
}

sub sort_rules
{
    my($arrayref) = shift;
    sub by_priority { $a->{"priority"} <=> $b->{"priority"} }
    @{$arrayref} = sort by_priority @{$arrayref};
}

#################################################
# Model object functions
################################################
# container objects are essentially structures 
# but we use hashes in Perl
# container hashes have the following 6 keys
#  $name  -> string that is the name
#  $val   -> string that holds the value of a name value pair
#  $parent -> reference to this objects parent object or ""
#  @sline -> array of lines to start an object
#  @eline -> array of line that closes an object, may be empty
#  @subs  -> array of objects inside this one
#################################################
sub new_objref
{
    my($ref);
    {
        my(%new_obj);
        $new_obj{"name"}   = "";
        $new_obj{"val"}    = "";
        $new_obj{"parent"} = "";
        @new_obj{"sline"}  = [];
        @new_obj{"eline"}  = [];
        @new_obj{"subs"}   = [];
        $ref = \%new_obj;
    }
    return $ref;
}

sub duplicate_obj
{
    my($src) = shift;
    my($dupe) = new_objref();
    my($idx);

    $dupe->{"name"} = $src->{"name"};
    $dupe->{"val"}  = $src->{"val"};
    # parent intentionally left out
    $idx = 0;
    foreach $slinesub (@{ $src->{"sline"}}){
        $dupe->{"sline"}[$idx++] = $slinesub;
    }
    $idx = 0;
    foreach $elinesub (@{ $src->{"eline"}}){
        $dupe->{"eline"}[$idx++] = $elinesub;
    }

    foreach $subobj (@{ $src->{"subs"}} ){
        $newsub = duplicate_obj($subobj);
        add_sub($dupe, $newsub);
    }

    return $dupe;
}


# This has been added to display an object while
# in the debugger.  Under normal circumstaces it will 
# not be called.
sub po
{
    my($obj) = shift;
    my($depth) = shift;

    foreach $part ( @{$obj->{"sline"}} ){
        print $part, "\n";
    }
    if($depth > 1){
        foreach $kid ( @{ $obj->{"subs"}} ){
            po( $kid, $depth-1 );
        }
    }
    foreach $part ( @{$obj->{"eline"}} ){
        print $part, "\n";
    }
}

sub find_refidx
{
    my($topref) = shift;
    my($subref) = shift;

    $idx = 0;
    foreach $objref ( @{$topref->{"subs"}}){
        if ( $objref == $subref){
            return $idx;
        }
        $idx++;
    }
    return -1;
}

sub remove_obj
{
    my($subref) = shift;
    my($topref) = $subref->{"parent"};
    $subref->{"parent"} = "";
    
    if($topref){
        $idx = find_refidx($topref,$subref);
        if($idx >= 0){
            splice( @{$topref->{"subs"}}, $idx, 1);
        }
        return $subref;
    }
    return undef();
}

sub rotate_obj
{
    my($subref) = shift;
    my($topref) = $subref->{"parent"};
    if($topref){
        $idx = find_refidx($topref,$subref);
        if($idx >= 0){
            $tmpobj = splice(@{$topref->{"subs"}}, $idx, 1);
            push( @{$topref->{"subs"}}, $tmpobj); 
        }
    }
}

sub insert_sub
{
    my($topref) = shift;
    my($holdref) = shift;
    my($subref) = duplicate_obj($holdref);
    add_sub($topref, $subref);
}

sub add_sub
{
    my($topref) = shift;
    my($subref) = shift;
    if($subref->{"name"} && $topref->{"name"}){
        push( @{ $topref->{"subs"} }, $subref);
        $subref->{"parent"} = $topref;
    }
}

########## TRANSFORM FUNCTIONS ##################
#this is the top treewalking function
# it applys the referenced function to 
# every node of the tree
################################################
sub tree_walk($topref, $data_ref, $func_ref)
{
    my($topref) = shift;
    my($data_ref) = shift;
    my($func_ref) = shift;

    foreach $obj (@{$topref->{"subs"}}){
        tree_walk($obj, $data_ref, $func_ref);
    }
    
    &$func_ref($topref,$data_ref);
}

####################################################
# if passed to tree_walk does action for whole tree
# tries to match the passed in rule set to this node 
# of the tree.
# if the rule set matches applies any action
####################################################
sub rule_match($objref, $rules_ref)
{
    my($objref) = shift;
    my($rules_ref) = shift;
    my($nomatch, $norulematch);

    #first  make sure this top obj has all the right name
    if( $objref->{"name"} ne $rules_ref->{"name"}){
        if( $rules_ref->{"name"} ne "WILDCARD" ){
            return 0;
        }
    }

    # second  make sure this top obj has the right value
    if( $rules_ref->{"val"} ){
        $val = get_obj_value($objref);
        if($rules_ref->{"symval"}){
            $pat = $rules_ref->{"val"};
        }else{
            $pat = escape_string($rules_ref->{"val"});
        }
        if(!($val =~ /^["]?$pat["]?\s*$/)){
            return 0;
        }
    }

    $nomatch = 1;
    # third push further rules down the chain to 
    # make sure they come back true
    ORSET: foreach $orset (@{$rules_ref->{"subs"}}){

        RULE: foreach $subrule (@{$orset}){

            #make sure each subrule in the orset is matched.
            $norulematch = 1;
            OBJ: foreach $subobj (@{$objref->{"subs"}}){
                  $tmpmatch = rule_match($subobj, $subrule);
                  if ($tmpmatch){
                      $norulematch = 0;
                  }
            }

            #switch the results if the action is negation.
            if ($subrule->{"action"} eq "negation" ){
                if( $norulematch ){
                    $norulematch = 0;
                }else{
                    $norulematch = 1;
                }
            }
            # if no obj matched this rule in the orset this orset 
            # doesn't pass try the next one.
            next ORSET if $norulematch;
        }
        # all subrules of this orset matched, this orset is good.
        $nomatch = 0;
    }

    # if no orsets were good return that this doesn't match
    return 0 if $nomatch;

    # fourth perform action for this rule
    if ($rules_ref->{"action"}){
        apply_action($objref, $rules_ref);
    }
    return 1;
}

###############################################
# applies the rules action to the object if 
# all parent rules and previous siblings match
# Note: younger siblings do not need to match 
# for action to be taken.
#  Actions that can be taken (with syntax) include
#     rename oldval,,newval     
#          change oldval to newval not just for 
#          names but for other conditional string 
#          replacements
#     revalue newval        
#          change the value of a pair to newval
#          regardless of the current value
#     remove
#          removes the object be it pair or container
#     insertsib
#          places the last removed object or named
#          object as a younger sibling of the current object.
#     insert
#          insert the last removed object or named object as a 
#          child of the current object.
#     error msg
#          print error msg because the current
#          configuration should never happen.
#    
# Unimplemented:
#     negation
#          this 'action' is handled in the match_rule function.
###############################################
sub apply_action($objref, $ruleref)
{
    my($objref) = shift;
    my($ruleref) = shift;
    my($action) = $ruleref->{"action"};
    $hold1; #deliberately global
    %hold1; #deliberately global

    # replace one value with another value
    # used for conditional change of value
    # and change of name
    if( $action =~ /^rename\s+(.*?),,(.+)$/){
        $pat = escape_string($1); $rep = $2;
        $objref->{"sline"}[0] =~ s/$pat/$rep/;
        $objref->{"name"} =~ s/$pat/$rep/;
        $objref->{"name"} = escape_symbolic_ref($objref->{"name"});

    }elsif($action =~ /^revalue\s+(.+)$/){
    # replace whatever value with a given value
    # unconditional change of value
        $rep = $1;
        if($ruleref->{"val"}){
            $pat = $ruleref->{"val"};
        }else{
            $pat = get_obj_value($objref);
        }

        if(!($ruleref->{"symval"})){
            $pat = escape_string($pat);
        }

        $objref->{"sline"}[0] =~ /^(\s*\S+\s+)(["]?)(.*)(\2)$/;
        $name = $1;  $quote = $2;  $val = $3;
        if(($pat =~ /^"/) && ($quote)){
            $val = $quote.$val.$quote;
            $quote = '';
        }

        if($ruleref->{"symval"}){
            $val =~ s/$pat/$rep/;
            $val = eval $val;
        }else{
            $val =~ s/$pat/$rep/;
        }

        if($val =~ /^"/){ 
            $quote = ''; 
        }
        $objref->{"sline"}[0] = $name.$quote.$val.$quote;

        
    # remove an object from the tree
    }elsif( $action =~ /^remove(\s+(.+))?$/){
        if($2){
            $hold1{$2} = remove_obj($objref);
        }else{
            $hold1 = remove_obj($objref);
        }

    #added for testing purposes
    }elsif( $action =~ /^rotate$/){
        rotate_obj($objref);

    # insert the last removed object back 
    # at the same level as the current object
    }elsif( $action =~ /^insertsib(\s+(.+))?$/){
        $topref = $objref->{"parent"};
        if($2){
            insert_sub($topref,$hold1{$2});
        }else{
            add_sub($topref,$hold1);
        }

    # insert the last removed object back 
    # as a child of the current object
    }elsif( $action =~ /^insert(\s+(.+))?$/){
        if($2){
            insert_sub($objref,$hold1{$2});
        }else{
            add_sub($objref,$hold1);
        }

    # perform a math operation on a value
    }elsif( $action =~ /^mathop\s+(.+)$/){
        $op = $1;
        $oldval = get_obj_value($objref);
        $strcmd = $oldval.$op;
        $newval = eval $strcmd;
        $objref->{"sline"}[0] =~ s/$oldval/$newval/;

    }elsif( $action =~ /^recursive_substr_replace\s+(.+),,(.+)$/){
        $oldsubstr = $1;
        $newsubstr = $2;
        recursive_substr_replace($objref, $oldsubstr, $newsubstr);

    # display an error text because this rule 
    # shouldn't be matched
    }elsif( $action =~ /^error/){
        print $action;
    }
}
 
########## UTILITY FUNCTIONS ####################
# for object reading
# These functions need to know something about
# the model file format.  They should be the only
# ones 
#################################################
sub is_start_obj
{
    my($line) = shift;
    return ($line =~ /^\s*[a-zA-Z][a-zA-Z0-9_.]*\s*{\s*$/);
}

sub is_end_obj
{
    my($line) = shift;
    return ($line =~ /^\s*}\s*$/);
}

sub is_cont_val
{
    my($line) = shift;
    return ($line =~ /^\s*\"/);
}

# should handle multiline values as well
# but so far no need
sub get_obj_value
{
    my($objref) = shift;
    my($val);
    $objref->{"sline"}[0] =~ /^\s*(\S+)\s+(.*)$/;
    return $2;
}

sub get_name_from_line
{
    my($line) = escape_symbolic_ref(shift);
    $line =~ /^\s*([\\a-zA-Z_\$.0-9]+)/;
    return $1;
}

sub fill_hold
{
    my($pair) = new_objref();
    my($container) = new_objref();

    $pair->{"name"} = "pair";
    $pair->{"val"}  = "val";
    $pair->{"sline"}[0] = "  pair   val";
    
    $container->{"name"} = "container";
    $container->{"sline"}[0] = " container{";
    $container->{"eline"}[0] = " }";

    $hold1{"pair"} = $pair;
    $hold1{"container"} = $container;
}

######### MORE UTILITY FUNCTIONS ##########################

###########################################################
# this functions turns strings/blocknames/etc that are passed
# in from outside Perl into patterns that can be used
# for pattern matching.  The return value of this string
# should not be written out.
##########################################################
sub escape_string
{
    my($results);
    my($input) = shift;

    $results = escape_symbolic_ref($input);

    #escape any backslashes
    $results =~ s/\\/\\\\/g;

    #backslash [] and ^ so that they show up properly
    $results =~ s/([\[\]^])/\\$1/g;

    #surround any special character except backslash, [] and ^
    #in its own character class to insure matching
    $results =~ s/([-*.?|{}()\$+])/[$1]/g;

    return $results;
}

#############################################
# handles $ in strings will be needed more places
# than escape_string because there are more places
# where Perl tries to follow symbolic references
sub escape_symbolic_ref
{
    my($results);
    my($input) = shift;

    $results = $input;
    # "$" needs to be escaped even in a character class
    # or a string for printing.  With any function use it will
    # be assumed to reference.
    $results =~ s/\$/\\\$/g;

    return $results;
}

sub recursive_substr_replace($objref, $oldsubstr, $newsubstr)
{
    my($objref) = shift;
    my($oldsubstr) = shift;
    my($newsubstr) = shift;

    foreach $subobj (@{$objref->{"subs"}}){
        #replace for all my children
        recursive_substr_replace($subobj, $oldsubstr, $newsubstr);
    }
    #now replace for me
    $objref->{"sline"}[0] =~ s/$oldsubstr/$newsubstr/;
}

############## READ OBJ FUNCTIONS ##############
# start the read of a top level obj
# there may be multiple top lvl objects
# so group them all under one root object.
sub read_top_obj
{
    *FH = shift;

    $topref = new_objref();

    $$topref{"name"} = "root";

    while(<FH>){
        $line = $_;
        chomp($line);

        # if this starts a new object
        if ( is_start_obj($line) ){
            $ret_ref = read_container_obj($fh, $line);
            add_sub($topref, $ret_ref);
        # else skip the line
        }
    }

    # fill the basic hold spots in global vars
    fill_hold();

    return $topref;
}

# Function: read_gen_obj =========================
# Abstract:
#    read in a container obj, look for new objs and
#    objs ending.  Perform object type specific 
#    checks on the lines with possible autoend 
#    of object.
sub read_container_obj 
{
    *FH = shift;
    my($line) = shift;

    my($objref) = new_objref();
    $objref->{"name"} = get_name_from_line($line);
    push(@{ $objref->{"sline"} },$line);

    while(<FH>){
        $line = $_;
        chomp($line);

        # if line ends object
        if ( is_end_obj($line) ){
            push(@{ $objref->{"eline"}},$line);
            return $objref;

        # if this starts a new object
        }elsif( is_start_obj($line) ){
            $ret_ref = read_container_obj($fh, $line);
            add_sub($objref,$ret_ref);

        # if line continues last value or
        # if line continues object definition
        }elsif( is_cont_val($line) ){
            $idx = scalar(@{ $objref->{"subs"}});
            if ($idx > 0){
                push( @{ $objref->{"subs"}[$idx-1]->{"sline"}}, $line);
            }else{
                push( @{ $objref->{"sline"} }, $line);
            }
        }else{
            # if line is new value
            # or line is blank
            if ( $line =~ /^\s*$/){
                # if line is blank skip it.
            }else{
                $prm_ref = new_objref();
                $prm_ref->{"name"} = get_name_from_line($line);
                push(@{ $prm_ref->{"sline"}}, $line);
                add_sub($objref,$prm_ref);
            }
        }
    }

    return $objref;
}

######### WRITE FUNCTION ##############
sub write_obj 
{
    *FH = shift;
    my($obj) = @_;
    my($line);

    foreach $part (@{ $obj->{"sline"} }) {
        $line = break_long_line($part, $maxLineLen);
        print FH $line, "\n";
    }
    foreach $childobj ( @{ $obj->{"subs"} }) {
        write_obj( FH, $childobj );
    }
    foreach $part (@{ $obj->{"eline"} }) {
        $line = break_long_line($part, $maxLineLen);
        print FH $line, "\n";
    }
}

####################################################
# used to breakup lines to be written into acceptable 
# lengths.  Searches for an acceptable spot to break
# unicode characters but if it doesn't find one will 
# just break at some point.
####################################################
sub break_long_line
{
    my($line,$MAXLINELEN) = @_;
    my(@lines);

    $LINEBREAKEND = 100;
    $LINEBREAKSTART = 80;

    # keep MAXLINELEN small enough perl's regexp 
    # can handle it.
    if($MAXLINELEN > 32700){ $MXLINELEN = 32700;}

    if($MAXLINELEN > 500){
        $LINEBREAKSTART = int( $MAXLINELEN * 0.8 );
        $LINEBREAKEND   = $LINEBREAKSTART + 50;
    }

    my($end) = 0;
    my($nlremoved) = chomp($line);
    my($len) = length($line);
    if($len > $MAXLINELEN){
        # if this line consists of multiple lines
        if ($line =~ /[\n]/){

            $mynlr = $nlremoved;
            @multiLines = split /\n/, $line;
            foreach $tmpLine ($multiLines){
              $tmpLine = BreakLongLine($tmpLine);   
            }
            $line = join '\n', @multiLines;

            if($mynlr){
                $line = $line.'\n';
            }
            return $line;
        }

        $lines[$end] = $line;

        #quote value if not already quoted
        if($line !~ /^\s*\"/){
            $line =~ /(\s*\w*\s*)(.*)/;
            $ident = $1;
            $val   = $2;
            # if val isn't quoted, quote it.
            if ($val !~ /^\"/){
                $lines[$end] = $1."\"".$2."\"";
            }
        }

        #break appart string
        while($len > $MAXLINELEN) {
            # try to break the string on a good boundry
            if($lines[$end] !~ /^(.{$LINEBREAKSTART,$LINEBREAKEND}[\w\s\-])([\w\s\-].*)$/){
                # if that doesn't work try to break on a half-good boundry
                if($lines[$end] !~ /^(.{$LINEBREAKSTART,$LINEBREAKEND}[\w\s\-])(.*)$/){
                    # if that doesn't work just break the string
                    $lines[$end] =~ /^(.{$LINEBREAKSTART})(.*)$/;
                    $first = $1;
                    $second = $2;
                }else{
                    $first = $1;
                    $second = $2;
                }
            }else{
                $first = $1;
                $second = $2;
            }
            $lines[$end] = $first;
            $end++;
            $lines[$end] = $second;
            $len = length($lines[$end]);
        }

        #put back together inserting ""s
        while($end != 0){
            $lines[$end-1] = $lines[$end-1]."\"\n\"".$lines[$end];
            pop(@lines);
            $end--;
        }
    
        $line = $lines[0];
    }

    if($nlremoved){
        $line = $line."\n";
    }

    return $line;
}

################################################
# This function parses one line from the datafile
# into tokens and then builds them 
# into a rules heirarchy.
#################################################
sub  read_rules()
{
    my($sets_ref) = shift;
    my($lines_ref) = shift;    
    my($line, $rule, $priority);

    foreach $line ( @{ $lines_ref }){

        chomp($line);
        @toks = split /([|:<>])/, $line;
        if(@toks){  #skip proccessing for empty lines
            combine_escaped(\@toks);
            $priority = shift(@toks); # should be '<' or a priority
            if($priority eq '<'){
                #give the default priority
                $priority = 2;
            }else{
                #shift of the '<'
                shift(@toks);
            }
            $rule = build_rule_from_tok(shift(@toks),\@toks);
            $rule->{"priority"} = $priority;
            if(@toks){
                print "problem building rule for line:", $line;
            }else{
                add_rule($sets_ref,$rule);
            }
        }
    }
    sort_rules($sets_ref);
}

#################################################
# This function rejoins tokens that should stay 
# broken apart because the separators were
# escaped.  The '&' escape character is removed 
# from the string as well.
#################################################
sub combine_escaped()
{
    my($toks_ref) = shift;
    my($idx);

    for($idx = ($#{ $toks_ref}); $idx >= 0; $idx--){
        if($toks_ref->[$idx] =~ /^\s*$/){
            #if empty remove this token
            splice(@{$toks_ref},$idx,1);
        }else{
            # if not empty check to see if this token
            # should be combined with the next token.
            $toks_ref->[$idx] =~ /(.*?(&&)*)(&)?$/;
            $esc = $3;
            if($3){
                # combine this token, the escaped next separator, and the next token
                $token = $1.$toks_ref->[$idx+1].$toks_ref->[$idx+2];
                splice(@{$toks_ref},$idx,3,$token);
            }
            $toks_ref->[$idx] =~ s/&&/&/g;
        }
    }
}

#####################################################
# This function recursively builds a rules heirarch 
# from a set of tokens.  Not all tokens may be used 
# by a given call, the unused ones should be part of 
# sibling or parent rules.
#####################################################
sub build_rule_from_tok
{
    my($name) = shift;
    my($toks_ref) = shift;
    my($rule) = new_ruleref($name);
    my($curtok,$cursep, $subrule,$tmpaction);

    while(@{$toks_ref}){
        $cursep = shift(@{ $toks_ref});


        SWITCH : {
            if($cursep eq "<"){ 
                # start of a sub rule
                $curtok = shift(@{ $toks_ref});
                $subrule = build_rule_from_tok($curtok,$toks_ref);
                add_subrule($rule,$subrule);
                last SWITCH; 
            }
            if($cursep eq "|"){ 

                $curtok = shift(@{ $toks_ref});
                if ($curtok eq "<"){
                    # new or subrule
                    $curtok = shift(@{$toks_ref});
                    $subrule = build_rule_from_tok($curtok, $toks_ref);
                    add_orsubrule($rule,$subrule);
                }else{
                    # given value
                    if($curtok =~ /^[&]sym[&](.*)$/){
                        $rule->{"val"} = $1;
                        $rule->{"symval"} = 1;
                    }else{
                        $rule->{"val"} = $curtok;
                    }
                }
                last SWITCH; 
            }
            if($cursep eq ":"){ 
                #given action
                $curtok = shift(@{ $toks_ref});
                if($curtok =~ /^rename\s*(.*)/){
                    $rule->{"action"} = "rename ".$rule->{"name"}.",,".$1;
                }elsif($curtok =~ /^repval\s*(.*)/){
                    $rule->{"action"} = "revalue ".$1;
                }else{
                    $rule->{"action"} = $curtok;
                }
                last SWITCH; 
            }
            if($cursep eq ">"){ 
                # end this rule
                return $rule;
                last SWITCH; 
            }
        }
    }
    # this push should force an error to be displayed
    # when we get back to the calling function.
    push(@{$toks_ref},">");
    return $rule;
}

