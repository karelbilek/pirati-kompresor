use strict;
use warnings;
use utf8;
use DateTime;


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

my $dy=7;
my @all = active_topics($dy);


print_head();
print_forums(@all);
print_threads(@all);
print_end();


############# CAST TISKNOUCI

sub date_to_javascript {
	my $dt = shift;
	return "new Date( ".$dt->year.", ".$dt->month."-1, ".$dt->day.", ".$dt->hour.",".$dt->minute.",".$dt->second.", 0)";
}

sub print_head {
 #   my $days = shift;
#    my @all = @_;
    print '<html><head><meta http-equiv="content-type" content="text/html;charset=utf-8">';
	print '<title>Filtering příspěvků</title>';
	print '<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>';
#	print '<script type="text/javascript" src="jquery.countdown.js"></script>';
#	print '<script type="text/javascript" src="jquery.countdown-cs.js"></script>';

	print '<link rel="stylesheet" type="text/css" href="styl_novyky.css">';
	print '</head><body>';
	print "<div id='nadpis'><h2>Filtr nových příspěvků</h2></div>";
	
    print '<script>


        function createShowingDiv(what) {
             res= \'<div class="forum">\';
             res=res+\'<div class="hack">\';
             res=res+what;
             res=res+ \'</div>\';
             res=res+what;
             res=res+ \' | <a href="#" onClick="zobraz(\\\'\';
             res = res + what;
             res = res+\'\\\')">X</a></div>\';
             return res;
        }

        function zobraz(what) {
            zapamatuj(what);
           $("div.thread").each(function() {
                var hack = $(this).find("div.hack").first().text();
                if (what == hack) {
                    $(this).show();
                } else {
                    
                }
           });
           $("#zobrazena div.forum").each(function() {
                var hack = $(this).find("div.hack").first().text();
                if (what == hack) {
                    $(this).show();
                } else {
                    
                }
           });
           $("#skryta div.forum").each(function() {
                var hack = $(this).find("div.hack").first().text();
                if (what == hack) {
                    $(this).hide();
                } else {
                    
                }
           });
        }

        function odpamatuj(what) {
            var jsonpole = localStorage.getItem(\'zobrazena\');
            var pole;
            if (jsonpole) {
                pole = JSON.parse(jsonpole);
            } else {
                pole = new Object();
            }
            pole[what]=0;
            localStorage.setItem(\'zobrazena\', JSON.stringify(pole));
        }
        function zapamatuj(what) {
            var jsonpole = localStorage.getItem(\'zobrazena\');
            var pole;
            if (jsonpole) {
                pole = JSON.parse(jsonpole);
            } else {
                pole = new Object();
            }
            pole[what]=1;
            localStorage.setItem(\'zobrazena\', JSON.stringify(pole));
        }

        function zapamatovane() {
            var jsonpole = localStorage.getItem(\'zobrazena\');
            if (jsonpole) {
                var res = new Array();
                var pole = JSON.parse(jsonpole);
                for (key in pole) {

                    if (pole[key]==1) {
                        res.push(key);
                    }
                }
                return res;
            } else {
                return new Array();
            }
        }

        function skryj(what) {
            odpamatuj(what);
           $("div.thread").each(function() {
                var hack = $(this).find("div.hack").first().text();
                if (what == hack) {
                    $(this).hide();
                } else {
                    
                }
           });
           $("#zobrazena div.forum").each(function() {
                var hack = $(this).find("div.hack").first().text();
                if (what == hack) {
                    $(this).hide();
                } else {
                    
                }
           });
           $("#skryta div.forum").each(function() {
                var hack = $(this).find("div.hack").first().text();
                if (what == hack) {
                    $(this).show();
                } else {
                    
                }
           });
        }
        
        $(document).ready(function(){
            var pole = zapamatovane();
            for (x in pole) {
                zobraz(pole[x]);
            }
        });

    </script>';

	#my $now = DateTime->now(time_zone => "Europe/Prague");
	#my $next = DateTime->now(time_zone => "Europe/Prague");
	#if ($days == 1) {
#		$next->add(hours=>2);
#	} elsif ($days ==7) {
#		$next->add(days=>1);
#	} elsif ($days==20 or $days==30) {
#		$next->add(days=>7);
#	} 

#	print '<script> $(document).ready(function() {
#		$("#timer1").countdown({since: '.date_to_javascript($now).'});
#		$("#timer2").countdown({until: '.date_to_javascript($next).', onExpiry: liftOff});
#
#	});
#	
#	function liftOff() { 	
#		setTimeout(function(){location.reload()},900000);
#		
#	}
#	
#	</script>';
	
	
}

sub print_forum_show {
        my $forum = shift;
        print '<div class="forum" onClick="zobraz(\''.$forum.'\')">';
       print '<div class="hack">';
       print $forum;
       print '</div>';
        print $forum;
        print'</a></div>';
}

sub print_forum_hide {
        my $forum = shift;
        my $display = shift;
        my $css=$display?"":'style="display:none"';
        print '<div class="forum" '.$css.' onClick="skryj(\''.$forum.'\')">';
       print '<div class="hack">';
       print $forum;
       print '</div>';
        print $forum;
        print '</div>';
}

sub print_forums {
    my @all = @_;
    print_forums_skryta(@_);
    print_forums_zobrazena(@_);
}

sub print_forums_skryta {
    my @all = @_;

    print '<div id="skryta" style="clear:both">';
    print '<div>Skrytá fóra:</div>';
    

    my %forums_hash = map {($_->{forum}, 0)} @all;
    
    my @forums_uniq = keys %forums_hash;

    my @forums = sort {$a cmp $b} @forums_uniq;

    
    for my $forum (@forums) {
        print_forum_show($forum);
    }

    print '</div><hr>';
}

sub print_forums_zobrazena {
    my @all = @_;

    print '<div id="zobrazena" style="clear:both">';
    print '<div>Zobrazená fóra:</div>';
    

    my %forums_hash = map {($_->{forum}, 0)} @all;
    
    my @forums_uniq = keys %forums_hash;

    my @forums = sort {$a cmp $b} @forums_uniq;

    
    for my $forum (@forums) {
        print_forum_hide($forum,0);
    }

    print '</div><hr>';
}

sub print_threads {
   my @all=@_;
   
   for my $thread (@all) {
       print '<div class="thread" style="display:none" >';
       print '<div class="hack">';
       print $thread->{forum};
       print '</div>';
       print_forum_hide( $thread->{forum}, 1);
       print '<a href="';
       print url_forum($thread->{number}, $thread->{page});
       print '">';
       print $thread->{name};
       print '</a> ';
       print '</div>';
   }

}
sub print_end{
	print '</html>';
}



sub url_forum {
    my ($thread, $page) = @_;
    
    return 'https://forum.pirati.cz/-t'.$thread."-".$page.".html";
}



############# CAST NAHRAVACI


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

            my $forum =
            ((($row->getElementsByTagName("dl"))[0]->getElementsByTagName("dt"))[0]->getElementsByTagName("a"))[-1]->as_text();
            if (!defined $forum) {
                die "shit";
            }
            
            my %thread_info = (number=> $thread_number, name=> $thread_name,
            page=>$max, forum=>$forum);
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



