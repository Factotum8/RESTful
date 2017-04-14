use 5.010;
use strict;
use warnings;
use List::MoreUtils qw(uniq);

defined $ARGV[0] 
	or die "Script is started without an argument. $!";

my $RawFile = "$ARGV[0]";
open(my $raw, '<:encoding(UTF-8)', $RawFile)
  or die "Could not open file '$ARGV[0]' $!";
 

my $wrfile = '/home/hrono/projects/RESTful/tools/result.slm.xml';
open(my $wr, '>', $wrfile) or die "Не могу открыть '$wrfile' $!";

my $header= <<'END_HEADER';
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE SLMTraining SYSTEM "http://10.30.0.3/dtd/SLMTraining.dtd">
<SLMTraining version="1.0.0" xml:lang="ru-RU">
<param name="fsm_out"><value>slm.fsm</value></param>
<param name="wordlist_out"><value>slm.wordlist</value></param>
<param name="ngram_order"><value>3</value></param>
<param name="cutoffs"><value>0 0</value></param>
<param name="smooth_weights"><value>0.1 0.9 0.9 0.9</value></param>
<param name="smooth_alg"><value>GT-disc-int</value></param>
<vocab>
END_HEADER

printf $wr "$header";

my $word;
my @tmpArray;
my @wordArray;
my @sentenceArray;


while ( my $row = <$raw> ){

	$row =~ tr /A-Z\"a-z\._\[\]\(\)\-\d\+\t0-9\?\\;/ /;
	$row = lc $row;
	$row =~ s/[ ]+/ /g;

	$word = $row;

	@tmpArray = split (/ /,$word);
	# say join ( "\n",@tmpArray );

	foreach my $i (0..$#tmpArray){

		push @wordArray, "$tmpArray[$i]";
	}

	# say join ( ':',split (/ /,$word) ), "\n";

	push @sentenceArray, "$row";
}

@wordArray = uniq @wordArray;
@wordArray = sort {$a cmp $b} @wordArray;

foreach my $i (2..$#wordArray){

	printf $wr "\t<item>$wordArray[$i]</item>\n";
}
	
my $slm_header= <<'SLM_HEADER';
</vocab>
<training>
SLM_HEADER

printf $wr "$slm_header";

foreach my $i (0..$#sentenceArray){

	my $str = $sentenceArray[$i];
	$str =~ s/\r\n$//;

	printf $wr "\t<sentence count='1'>$str</sentence>\n";
}

my $end_file= <<'END_FILE';
</training>
</SLMTraining>
END_FILE

printf $wr "$end_file";

close $wr;
close $raw;
