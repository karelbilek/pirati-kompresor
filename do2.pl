#Copyright (c) 2013, Karel Bílek
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met: 
#
#1. Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer. 
#2. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution. 
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

use strict;
use warnings;
use utf8;
use DateTime;

my %idf;
open my $idfdata, "<:utf8", "../data/vseIDF_sorted_mensi" or die $!;
while (my $line = <$idfdata>) {
	chomp $line;
	$line =~ /^\s*(\d+)\s*(.*)$/ or die "wrong line $line";
	$idf{$2} = $1;
}


my $dy = $ARGV[0];

binmode(STDOUT, ":utf8");

#musi byt spusteno ve stejnem adresari jako password
my $password = `cat password`; chomp($password);

use 5.010;
system "wget --save-cookies ../cookies.txt --no-check-certificate ".
       "--post-data 'username=Kompresorobot&password=$password&".
       "login=P%C5%99ihl%C3%A1sit+se' ".
       "'https://forum.pirati.cz/ucp.php?mode=login' -O /dev/null ".
       ">/dev/null 2>/dev/null";

sub read_string_from_address {
    my $address = shift;
    say STDERR $address;
    open my $inpf, "wget  --load-cookies ../cookies.txt ".
            "'$address' --no-check-certificate  -O - 2>/dev/null |";
    binmode($inpf, ":utf8");
    my @outp = <$inpf>;
    my $outpjoined = join("", @outp);
    return $outpjoined;
}

my %mons = (
    'led' => 1,
    'úno' => 2,
    'bře' => 3,
    'dub' => 4,
    'kvě' => 5,
    'čer' => 6,
    'črc' => 7,
    'srp' => 8,
    'zář' => 9,
    'říj' => 10,
    'lis' => 11,
    'pro' => 12
);

sub to_mon {
    return $mons{$_[0]};    
}

#my $i = 15027;
#my $p = 40;
#my @r = load_articles_before_days($i, $p, 1);

#use Data::Dumper;
#print Dumper(@r);

my @all = get_all_articles($dy);



#use YAML::XS;
#YAML::XS::DumpFile("prispevky", \@all);

#die "end";

#my $all = YAML::XS::LoadFile("prispevky");
#my @all = @$all;


print_head($dy, @all);
print_overview($dy, @all);
print_threads_info($dy, @all);
#print_thready_dist(@all);

print_best_articles(@all);
#print_best_articles_whole(@all);

print_end();


############# CAST TISKNOUCI

sub date_to_javascript {
	my $dt = shift;
	return "new Date( ".$dt->year.", ".$dt->month."-1, ".$dt->day.", ".$dt->hour.",".$dt->minute.",".$dt->second.", 0)";
}

sub print_head {
    my $days = shift;
    my @all = @_;
    print '<html><head><meta http-equiv="content-type" content="text/html;charset=utf-8">';
	print '<title>Kompresor pirátského fóra</title>';
	print '<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>';
	#print '<style type="text/css">@import "jquery.countdown.css";</style> ';
	print '<script type="text/javascript" src="jquery.countdown.js"></script>';
	print '<script type="text/javascript" src="jquery.countdown-cs.js"></script>';

	print '<link rel="stylesheet" type="text/css" href="styl.css">';
	print '</head><body>';
	print "<div id='nadpis'><h2>Kompresor fóra za posledních $days dní</h2></div>";
	print "pozn. : odkazy vedou na první příspěvek v daném úseku. pozn2: z technických důvodů jsou z náhledů smazány citace.";
	
	
	my $now = DateTime->now(time_zone => "Europe/Prague");
	my $next = DateTime->now(time_zone => "Europe/Prague");
	if ($days == 1) {
		$next->add(hours=>2);
	} elsif ($days ==7) {
		$next->add(days=>1);
	} elsif ($days==20 or $days==30) {
		$next->add(days=>7);
	} 

	print '<script> $(document).ready(function() {
		$("#timer1").countdown({since: '.date_to_javascript($now).'});
		$("#timer2").countdown({until: '.date_to_javascript($next).', onExpiry: liftOff});

	});
	
	function liftOff() { 	
		setTimeout(function(){location.reload()},900000);
		
	}
	
	function vymen_zaves(i) {
		$("#dalsi_"+i).hide();
		$("#zaves_"+i).show();
	}
	
	function zavri_zaves(i) {
		$("#dalsi_"+i).show();
		$("#zaves_"+i).hide();
	}
	
	var curr=0;
	function zjevnahled(i) {
		$("#nahled"+curr).hide();
		$("#nahled"+i).show();
		if (curr!=0) { $("#hrefnahled"+curr).html("(náhled)");}
		$("#hrefnahled"+i).html("<span class=\"prohlizim\">prohlížím</span>");
		curr=i;
	}
	
	</script>';
	
	
	print '<div class="outbox">'; #basic info
    
	print '<div class="inbox">'; #příspěvky
	print '<span class="mininadpis">Počet příspěvků:</span> '.(scalar @all);
	print '</div>'; #příspěvky
	
	
	print '<div class="inbox">'; #updatováno
	print '<span class="mininadpis">Naposledy updatováno před:</span> <span id="timer1"></span>';
	print '</div>'; #updatováno
	
	print '<div class="inbox">'; #bude updatováno
	print '<span class="mininadpis">Bude updatováno za cca:</span> <span id="timer2"></span>';
	print '</div>'; #bude updatováno
	
	print '<div class="inbox">'; #verze
	print '<span class="mininadpis">Jiné počty dní:</span> <a href="1.html">1</a> - <a href="7.html">7</a> - <a href="30.html">30</a>';
	print '</div>'; #verze
	
	#my %popis = (
    #    1=>'jednou za 2 hodiny',
    #    7=>'1x denně',
    #    30=>'1x týdně'
    #);
    #print 'updatováno cca '.$popis{$days}.'; naposledy updatováno '.(DateTime->now()->add(hours=>1)).'; bylo celkem '.(scalar @all).' příspěvků. <a href="pirati1.html">1</a>-<a href="pirati7.html">7</a>-<a href="pirati30.html">30</a><br><br>';
	
	
	
	print '<div class="clearing"></div></div>'; #basic info
}


sub print_end{
	print '</html>';
}

sub print_overview {
	my $dy = shift;
	my @articles = @_;
	print '<div class="outbox">';
	
	print_kecalci(@articles);
	print_keywords($dy, @articles);


	print '<div class="clearing"></div></div>';
	
}

sub print_threads_info {
	my $dy = shift;
	my @articles = @_;
	print '<div class="outbox">';
	
	print_thready(@articles);
	print_thready_dist(@articles);
	print_thready_likes(@articles);

	print '<div class="clearing"></div></div>';

}

sub print_thready {
    my @articles = @_;
    my %thready;
    my %thread_ids;
    for (@articles) {
        $thready{$_->{threadname}}++;
        $thread_ids{$_->{threadname}} = $_->{thread};
    }
    my @thready_a = sort {$thready{$b} <=> $thready{$a}} keys %thready;
	
	print '<div class="inbox widthbox">'; 
	print '<div class="innadpis">Nejaktivnější thready</div>';
	
	my $s_b;
	$s_b = sub {
		my $i = shift;
		return sub {
			print "<ol start='".($i*10+1)."'>";
			for (@thready_a[$i*10..$i*10+9]) {
				print '<li>'."<a href='".url_forum_oldest($thread_ids{$_}, @articles)."'>".$_."</a> - ".($thready{$_})."</li>";
			}
			print "</ol>";
			if ($i<=5) {
				print_zaves($s_b->($i+1), $i);
			}
		};
	};
	
	$s_b->(0)->();
	
    print "</div>";
}

sub print_thready_likes {
    my @articles = @_;
    my %thready_likes;
    my %thread_ids;
    for (@articles) {
        $thready_likes{$_->{threadname}}+=$_->{thanks};
        $thread_ids{$_->{threadname}} = $_->{thread};
    }
    my @thready_a = sort {$thready_likes{$b} <=> $thready_likes{$a}} keys %thready_likes;
	
	print '<div class="inbox widthbox">'; 
	print '<div class="innadpis">Thready s nejvíce palci</div>';
	
	my $s_b;
	$s_b = sub {
		my $i = shift;
		return sub {
			print "<ol start='".($i*10+1)."'>";
			for (@thready_a[$i*10..$i*10+9]) {
				print '<li>'."<a href='".url_forum_oldest($thread_ids{$_}, @articles)."'>".$_."</a> - ".($thready_likes{$_})."</li>";
			}
			print "</ol>";
			if ($i<=5) {
				print_zaves($s_b->($i+1), $i);
			}
		};
	};
	
	$s_b->(0)->();
	
    print "</div>";
}

sub print_thready_dist {
    my @articles = @_;
    my %thready;
    my %thread_ids;
    for (@articles) {
        $thready{$_->{threadname}}{$_->{author}}=1;
        $thread_ids{$_->{threadname}} = $_->{thread};
    }
    my @thready_a = sort {scalar keys %{$thready{$b}} <=> scalar keys %{$thready{$a}}} keys %thready;

	print '<div class="inbox widthbox">'; 
	print '<div class="innadpis">Thready s nejvíce členy</div>';
	my $s_b;
	$s_b = sub {
		my $i = shift;
		return sub {
			print "<ol start='".($i*10+1)."'>";
			for (@thready_a[$i*10..$i*10+9]) {
				print '<li>'."<a href='".url_forum_oldest($thread_ids{$_}, @articles)."'>".$_."</a> - ".(scalar keys %{$thready{$_}})."</li>";
			}
			print "</ol>";
			if ($i<=5) {
				print_zaves($s_b->($i+1),$i);
			}
		};
	};

	$s_b->(0)->();
	
    print "</div>";
}


my $zavesy = 0;
sub print_zaves {
	my $subr = shift;
	my $do_prev = shift;
	my $prev_id = $zavesy;
	$zavesy++;
	print '<div class="dalsi" id="dalsi_'.$zavesy.'">';
	if ($do_prev) {
		print '<a href="javascript:zavri_zaves('.$prev_id.')">zmenši</a> | ';
	}
	print '<a href="javascript:vymen_zaves('.$zavesy.')">další...</a></div>';
	print '<div class="zaves" id="zaves_'.$zavesy.'">';
	$subr->();
	print '</div>';
}

sub print_kecalci {
    my @articles = @_;
    my %kecalci;
    for (@articles) {
        $kecalci{$_->{author}}++
    }
    my @authors = sort {$kecalci{$b} <=> $kecalci{$a}} keys %kecalci;
    #my @best = @authors[0..9];
	
	print '<div class="inbox">'; 
	print '<div class="innadpis">Nejaktivnější členové</div>';
	
	my $s_b;
	$s_b = sub {
		my $i = shift;
		return sub {
			print "<ol start='".($i*10+1)."'>";
			for (@authors[$i*10..$i*10+9]) {
				print '<li>'.$_." - ".($kecalci{$_})."</li>";
			}
			print "</ol>";
			if ($i<=5) {
				print_zaves($s_b->($i+1),$i);
			}
		};
	};
	
	$s_b->(0)->();
    print "</div>";
}



sub sm_idf {
	my $w = shift;
	if (! defined $idf{$w}) {
		return 1;
	}
	return $idf{$w};
}

sub print_keywords {

	my $dy=shift;
	my @articles = @_;
	my $text = "";
	for my $article (@articles) {
		$text.= $article->{text};
	}
	
	open my $tmpf,  ">:utf8" , "/tmp/keyw_".$dy or die $!;
	print $tmpf $text;
	close $tmpf;
	
	my %words;
	open my $inp, q(cat /tmp/keyw_).$dy.q( |  sed -r 's/viewtopic\.php\?\S+(\s|$)//g' | sed -r)
        .q( 's/[[:punct:]]+/\n/g' | sed -r 's/\s+/\n/g' | grep -v '^$'|grep )
        .q(-v '^[0-9]\+$' | sed -e 's/./\L\0/g' |) or die $!;
	binmode($inp, ":utf8");
    while (my $word = <$inp>) {
		chomp($word);
        $words{$word}++;
    }
	
	my $tfidf = sub{
		my $w = shift;
		return $words{$w} * log(1000/sm_idf($w));
	};
	
	my @best = sort {$tfidf->($b) <=> $tfidf->($a)} keys %words;
	
	print '<div class="inbox">'; 
	print '<div class="innadpis">Klíčová slova (beta)</div>';
	
	my $s_b;
	$s_b = sub {
		my $i = shift;
		return sub {
			print "<ol start='".($i*10+1)."'>";
			for (@best[$i*10..$i*10+9]) {
				print '<li>'.$_."</li>";
			}
			print "</ol>";
			if ($i<=5) {
				print_zaves($s_b->($i+1), $i);
			}
		};
	};
	
	$s_b->(0)->();
    print "</div>";
}

sub print_best_articles {
    my @articles = @_;
	
	print '<div class="outbox downout">';
	
	
	print '<div class="inbox downin downleft">'; 
	print '<div class="innadpis">Nejlépe hodnocené příspěvky</div>';
	
     
    my @best = sort {$b->{thanks} <=> $a->{thanks}} @articles;

	my $l=0;
	my $s_b;
	$s_b = sub {
		my $i = shift;
		return sub {
			print "<ol start='".($i*10+1)."'>";
			for my $article (@best[$i*10..$i*10+9]) {
				print '<li>'."<a href='".url_forum_article($article)."'>".$article->{threadname}." (".$article->{author}.")</a> [".$article->{thanks}."]".
					" <a href='javascript:zjevnahled(\"".$article->{id}."\")' id='hrefnahled".$article->{id}."'>(náhled)</a></li>";
			}
			$l=$i*10+9;
			print "</ol>";
			if ($i<=5) {
				print_zaves($s_b->($i+1),$i);
			}
		};
	};

	$s_b->(0)->();
	
	

    #print "<br style='clear:both'><br><a name='nahore'></a><b>Nejlépe hodnocené příspěvky (rychle)</b><br>";
    #for my $article (@best) {
    #    print "<a href='#".$article->{thread}."'>".$article->{threadname}." (".$article->{author}.")</a> - ".$article->{thanks}." (náhled)<br>";
    # }
	print '</div>';
	
	print '<div class="inbox downin">'; 
	print '<div class="innadpis">Náhled</div>';
	print '<div id="nahled0">Po kliknutí na "(náhled)" vlevo se zobrazí náhled zde. Náhled nemusí 100% fungovat.</div>';
	
	for my $article (@best[0..$l]) {
		print '<div id="nahled'.$article->{id}.'" class="hiddendiv">';
		my$c= $article->{contents};
		$c =~ s|images/local/offtopic.png|https://forum.pirati.cz/images/local/offtopic.png|g;
		print $c;
		
		print "<br><br> <a href='".url_forum_article($article)."'>Odkaz na fórum na příspěvek</a>";
		print '</div>';
	}
	
	
    print '</div>';
	
	print '<div class="clearing"></div></div>';

}

#sub print_best_articles_whole{
#    my @articles = @_;
#     
#    my @best = sort {$b->{thanks} <=> $a->{thanks}} @articles;
#    @best = @best[0..20];
#    print "<h3>Nejlépe hodnocené příspěvky (celé)</h3>";
#    
#    for my $article (@best) {
#        print "<a name='".$article->{thread}."'></a><a href='".url_forum_article($article)."'><b>".$article->{threadname}."</b> (".$article->{author}.")</a> [".$article->{thanks}."] <a href='#nahore'>(zpet)</a><br>";
#        print $article->{contents};
#        print "<br><hr>";
#    }
#}

sub url_forum_article {
    my $article = shift;
    
    return url_forum($article->{thread}, $article->{page}, $article->{id});
}

sub url_forum {
    my ($thread, $page, $post) = @_;
    
    my $ending = (defined $post) ? "#".$post : "";
    return 'https://forum.pirati.cz/-t'.$thread."-".$page.".html".$ending;
}


my %oldest_id;
my %oldest_page;
#hack
#smi se spoustet pouze na jedno pole, protoze pouzivam globalni hash
sub url_forum_oldest {
	my $inthread = shift;
	my @articles = @_;
	if (scalar keys %oldest_id==0) {
		for my $article (@articles) {
			my $thread = $article->{thread};
			my $id = $article->{id};
			$id =~ /p(\d+)/ or die "bad id";
			my $real_id = $1;
			if (!defined $oldest_id{$thread} or $real_id <= $oldest_id{$thread}) {
				$oldest_id{$thread} = $real_id;
				$oldest_page{$thread} = $article->{page};
			}
		}
	}
	return url_forum($inthread, $oldest_page{$inthread}, "p".$oldest_id{$inthread});
}


############# CAST NAHRAVACI
sub load_articles {
    my ($thread, $paging) = @_;
    my @res = load_articles_from_HTML(read_string_from_address("https://forum.pirati.cz/-t$thread-$paging.html"));
    
    return @res;
}

sub load_articles_before_days {
    my ($thread, $start_paging, $days) = @_;
    
    my $dt_before = DateTime->now(time_zone => "Europe/Prague")->subtract(days=>$days);
    
    
    my @res;
    my $stop = 0;
    while (!$stop) {
        my @art = load_articles($thread, $start_paging);
        
        
        if (DateTime->compare($art[0]->{dt}, $dt_before) < 0 ){
            $stop = 1;
    
        }
        
        @art = grep {DateTime->compare($_->{dt}, $dt_before) >=0 } @art; 

        @art = grep {$_->{thanks} >= 0 } @art;
        for (@art) {$_->{page}=$start_paging}
        push (@res, reverse @art);
        
        
    } continue {
        $start_paging -= 10;
        if ($start_paging < 0) {
            $stop = 1;
        }
    }
    
    return @res;
}

sub get_all_articles {
    my $days = shift;
    my @topics = active_topics($days);
    
    my @all;
    
    for my $topic(@topics) {
        my @articles = load_articles_before_days($topic->{number}, $topic->{page}, $days);
        for (@articles) {
            $_->{thread}=$topic->{number};
            $_->{threadname}=$topic->{name};
        }
        push (@all, @articles);
    }
    
    return @all;
}

sub active_topics {
    my $days = shift;
    my @threads;
    
    my $url = 'https://forum.pirati.cz/active-topics.html?st='.$days;
    use HTML::DOM;
    my $dom_tree = new HTML::DOM;
    $dom_tree->write(read_string_from_address($url));
    $dom_tree->close;
    
    my $actions = ($dom_tree->getElementsByClassName('topic-actions'))[0];
    my $pagination_t = ($actions -> getElementsByClassName('pagination'))[0];
    
    #hack, ale nevim, jak na to
    my $pagination_html = $pagination_t->as_HTML();

    my $max_pages;
    if ($pagination_html =~ /Str&aacute;nka <strong>1<\/strong> z <strong>(\d+)<\/strong>/) {
        $max_pages = $1;
    } else {
        $max_pages = 1;
    }
    my $current_page=1;
    my $continue=1;
    while ($continue) {
        my $topics_table = ($dom_tree->getElementsByClassName('topics'))[0];
        for my $row ($topics_table->getElementsByClassName('row')) {
            my $topictitle = ($row->getElementsByClassName('topictitle'))[0];
            my $a = $topictitle->as_HTML;
            $a =~ /(t|topic)(\d+)\.html">(.*)<\/a>/ or die "wrong link format $a";
            
            my $thread_number = $2;
            my $thread_name = $3;
            
            my @pagination = $row->getElementsByClassName('pagination');
            my $max;
            if (scalar @pagination) {
                my $last_a = ($pagination[0]->getElementsByTagName('a'))[-1]->as_HTML;
                $last_a =~ /-(\d+)\.html/ or die "wrong pagination format";
                $max = $1;
            } else {
                $max = 0;
            }
            
            my %thread_info = (number=> $thread_number, name=> $thread_name, page=>$max);
            push @threads, \%thread_info;
        }
        
        
        if ($max_pages == 1) {
            $continue = 0;
        } else {
            $current_page++;
            
            if ($current_page <= $max_pages) {
                $url = 'https://forum.pirati.cz/active-topics-'.($current_page-1).'00.html?st='.$days;

                $dom_tree = new HTML::DOM;
                $dom_tree -> write(read_string_from_address($url));
                $dom_tree -> close;
            } else {            
                $continue = 0;
            }
        }
     
     } 
     
     
     return @threads;
     
}


sub load_articles_from_HTML{
    my $input = shift;
                     
    use HTML::DOM;
    my $dom_tree = new HTML::DOM;
    $dom_tree->write($input);
    $dom_tree->close;

    my @res;
    
    #mazu vsechny citace, aby neotravovaly
    for my $el ($dom_tree->getElementsByTagName('blockquote')) {
        $el->parentNode->removeChild($el);
    }
    
    POST:
    for my $el ($dom_tree->getElementsByClassName('post')) {
       my $author_bigger = ($el->getElementsByClassName('author'))[0];
       if (!defined $author_bigger) {
          next POST;
       }
       
       my $id = $el->id();
       
       my $author_smaller =  ($author_bigger->getElementsByTagName('strong'))[0];
       my $author_text = $author_smaller->as_text();
       
       my $author_bigger_all = $author_bigger->as_text();
       #musim z toho pitome vytahnout datum
       
       my ($day, $mon_t, $yea, $hou, $min) = $author_bigger_all=~/(..) (...) 20(..), (..):(..) $/;
       my $mon = to_mon($mon_t);
       
       
       my $dt = DateTime->new(
            year       => 2000+$yea,
            month      => $mon,
            day        => $day,
            hour       => $hou,
            minute     => $min,
			time_zone => "Europe/Prague");
       
      
       my $thanks;
       my $content_real; 
       my @contents = $el->getElementsByClassName('content');
       #kdyz je to 1, nema to palce. Kdyz je to 3, ma to palce.
       #(docela pitome, ale tak to holt ten phpbb mod dela)
       $content_real = $contents[0]->innerHTML();
	   my $content_text = $contents[0]->as_text();
       if (scalar @contents==3) {

           
           my $thanks_text = $contents[1]->as_text();
           if ($thanks_text =~ /(\d+) poděkování/) {
              $thanks = $1;
           } else {
              $thanks = 1;
           }
           
       } else {
           $thanks = 0;
       }
       my %post = (author=>$author_text, dt=>$dt, contents=>$content_real, text=>$content_text, thanks=>$thanks, id=>$id);
       push(@res, \%post);
    }
    return @res;

}
