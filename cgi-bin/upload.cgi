#!/usr/bin/perl -wT

use strict; 
use CGI; 
use CGI::Carp qw ( fatalsToBrowser ); 
use File::Basename;
use CGI::Debug( report => ['errors', 'empty_body', 'time', 
                            'params', 'cookies', 'environment',
                            ],
                 on     => 'fatals',
                 to     => { browser => 1,
                             log     => 1,
                             file    => '/tmp/my_error',
                             mail    => ['staff@company.orb',
                                         'webmaster',
                                         ],
                         },
                 header => 'control',
                 set    => { error_document => 'oops.html' },
                 );

print "Content-type: text/html \n\n";

$CGI::POST_MAX = 1024 * 5000;
my $safe_filename_characters = "a-zA-Z0-9_.-";
my $upload_dir = "http://viraldarkmatter.sdsu.edu/data/upload";
my $query = new CGI; my $filename = $query->param("photo"); my $email_address = $query->param("lname");
if ( !$filename ) { 
    print $query->header ( ); 
    print "There was a problem uploading your photo (try a smaller file)."; 
    exit;
}
my ( $name, $path, $extension ) = fileparse ( $filename, '\..*' ); 
$filename = $name . $extension;
$filename =~ tr/ /_/; $filename =~ s/[^$safe_filename_characters]//g;
if ( $filename =~ /^([$safe_filename_characters]+)$/ ) { 
    $filename = $1; 
} else {
    die "Filename contains invalid characters"; 
}
my $upload_filehandle = $query->upload("photo");
open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!";
binmode UPLOADFILE;
while ( <$upload_filehandle> ) {
    print UPLOADFILE;
}
close UPLOADFILE;

print $query->header ( );
print
<<END_HTML;
<!DOCTYPE html> <head> <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Thanks!</title>
<style type="text/css">
img {border: none;} </style>
</head>
<body>
<p>Thanks for uploading your photo!</p>
<p>Your email address: $email_address</p>
<p>Your photo:</p>
<p><img src="/upload/$filename" alt="Photo" /></p>
</body>
</html>
END_HTML
