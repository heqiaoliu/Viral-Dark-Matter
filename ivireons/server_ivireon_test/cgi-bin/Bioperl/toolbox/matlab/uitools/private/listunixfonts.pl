#
# Copyright 1984-2002 The MathWorks, Inc. 
# $Revision: 1.4 $  $Date: 2002/06/21 20:31:29 $
#

# fetch font list using xls fonts
@fonts = `xlsfonts`;
if ($?) {
    # something broke, try to handle the error nicely
    # TBD
    exit(0);
}

# cleanup results and send to stdout

my %fonts; # use hash to enforce uniqueness
foreach (@fonts) {
    my $font;
    # these are the formats to look for:
    # -adobe-courier-bold-o-normal--0-0-75-75-m-0-hp-roman8
    # 10x20
    # 12x24
    # 12x24kana
    # clr7x10
    # lucidasans-bolditalic-10

    # ignore all font which begin with numbers - boring...
    next if(/^\d/);

    # handle fonts starting with -
    if (/^\-[^\-]+\-([^\-]+)/) {
        $font = $1 unless ($1 =~ /^\d/);
    }

    if ($font) {
        $fonts{$font} = 1;
    }
}
print join("\n", sort(keys(%fonts)));
exit(0);
