#!/usr/bin/env raku

my @f = qx"find ../task/Year* -iname '*.txt'".lines;
# ../task/Year 1/102/AUS_CMFT_Cond2-102-1.txt
# not sure how to get this to work
# grammar Fname {
#     token TOP { "/Year-" <year> "/" <id> "/" <task> "-" <id> "-" <run> ".txt" }
#     token year { [12] }
#     token id { \d**3 }
#     token task { \w+ }
#     token run { \d }
# }

my @all = ();
for @f -> $f {
    next unless $f ~~ rx{"Year " $<year> = (\d) "/" $<id> = (\d+) "/" $<task> = (.*) "-" \d**3};
    my %finfo = %$/;
    # merge SessionDate and SessionTime. assume that is always the order. only care about first 2 lines
    # extract datetime time from that
    my $dt = qqx{iconv -f utf16 -t utf8 "$f"|egrep "Session(Date|Time): "|sed 's/.*: //;2q'}.lines.join(" ");
    $dt ~~ rx{$<m>=(\d+) "-" $<d>=(\d+) "-" $<YC>=(\d**2) $<YY>=(\d**2) " " $<H>=(\d+)":" $<M>=(\d+) ":" $<s>=(\d+)};
    # N.B. folders drop century. 2011 is 11. We'll do that here too
    my %all = %$/, %finfo, { 'day' => "$<YY>$<m>$<d>", 'time' => "$<H>$<M>", 'file'=> $f.subst(/.* '/'/,"") };
    @all.push(%all);
}

# doesn't work in repl?
my $create =  q:to/END/;
create table task (
  id NUMERIC,
  day NUMERIC,
  time NUMERIC,
  year NUMERC,     -- timepoint: 1 or 2
  dayrank NUMERIC, -- unqiue id number for day ordered by time
  task TEXT,
  file TEXT
);
create table scan {
  day NUMERIC,
  time NUMERIC,
  dayrank NUMERIC, -- see task col
};
END

# first 6 digits are YYMMDD other bits are time (of start of aqcuistion, not task)
# also: qx<ls -d /data/Autism_Faces/raw/*/|sed 's:.*/raw/::;s:/::'>.lines
my @scans = qx<ls -d /data/Autism_Faces/raw/*/>.lines.map({ /$<date>=(\d**6) $<time>=(\d+)/; my %a=%$/});
# ({date => ｢110308｣, time => ｢160921｣} {date => ｢110314｣, time => ｢154520｣}

#use IO::Glob;
#glob("/data/Autism_Faces/raw/*")
