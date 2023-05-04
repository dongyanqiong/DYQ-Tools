#!/usr/bin/env perl
 
# mnodeSdb.h
@table_id = ("cluster",
    "dnode",
    "mnode",
    "account",
    "user",
    "db",
    "vgroup",
    "stable",
    "ctable");
 
@action = ("insert", "delete", "update");
     
binmode STDIN;
my $data;
my $offset = 0;
 
my %table_hash = {};
 
while (read(STDIN, $data, 24)) {
    my ($msgType, $sver, $reserved0, $reserved1, $len, $version, $signature, $cksum)
    = unpack('cccclQLL', $data);
 
    die "Not a WAL record" unless $signature == 0xfafbfdfe;
    printf("\n%x", $offset);
    $table_id_val = $msgType / 10;
    $action_val = $msgType % 10;
    print "\t$msgType\tversion: $version\t$table_id[$table_id_val]\t$action[$action_val]\t($len bytes) ";
     
    my $read_bytes = read(STDIN, $data, $len);
 
    if ($table_id_val == 8 || $table_id_val == 7) {
    if ($table_id_val == 8) {
     ($table_name, $table_type, undef, undef, $nextColId, $sversion,
        $uid, $suid, $createTime, $numOfColumns, $tid, $vgId, $sqlLen)
        = unpack('Z*ccQxxsxxlxxxxQQqllll', $data);
    } else {
     ($table_name, $table_type, undef, undef, $nextColId, $sversion,
        $uid, $createTime, $tversion, $numOfColumns, $numOfTags)
        = unpack('Z*ccQxxsxxlxxxxQqlll', $data);
    }
    use POSIX qw(strftime);
 
    
    my $a=strftime "%Y-%m-%d %H:%M:%S", localtime($createTime/1000);

    print "\ttable: $table_name [$a]";

    if ($action_val == 0) {
        if (exists($table_hash{"$table_name"})) {
        $table_hash{"$table_name"} += 1;
        my $tmp = $table_hash{"$table_name"};
        my $tmp_uid = sprintf("%x", $uid);
        print "\tERROR: zombie table $table_name $table_type $tmp $uid $createTime($a)";
        } else {
        $table_hash{"$table_name"} = 1;
        }
    }
    if ($action_val == 1) {
        if (!exists($table_hash{"$table_name"})) {
        print "\tERROR: delete does not exist $table_name\n";
        }
        delete $table_hash{"$table_name"};
    }
    	#print "\ttable: $table_name $createTime($a)\n";
		

    }
     
    $offset += $len + 24;
}
 
print "\n\n";
@keys = keys %table_hash;
$size = @keys;
print "# tables: $size\n";
@values = values %table_hash;
$size = @values;
print "# tables: $size\n";
print "keys[0]: $keys[0]\n";
print "$keys[1]\n";
print "values[0]: $values[0]\n";
print "$values[1]\n";
