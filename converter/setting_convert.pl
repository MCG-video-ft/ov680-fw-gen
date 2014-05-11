#!/usr/bin/perl
if (($cmd_ = @ARGV) != 1) {
	print STDOUT ("usage: ./setting_convert.pl <file_name>\n");
	exit;
}

$machine_file = @ARGV[0];
unless (open (INFILE, "$machine_file")) {
	die ("cannot open input file $machine_file\n");
}
print STDOUT ("read file: $machine_file\n");

$c_header_file = "ov680_setting.h";
print STDOUT ("wirting to file: $c_header_file\n");
unless (open (OUTFILE, "> $c_header_file")) {
	die ("cannot open input file $c_header_file\n");
}

$array_name = "static struct ov680_reg const ov680_720p_2s_embedded_line[] = {\n";
$array_start = 0;
$comment = 0;
$num_line = 0; #debug
$missed = 0;
while (<INFILE>) {
	chomp($_);
	if ($array_start == 0) {
		$array_start = 1;
		print OUTFILE ($array_name);
	}
	#remove the extra blanks
	s/(\s*)$//;

	if (/^6a/i) {
		@array = split(/\s+/, $_);
		printf OUTFILE ("\t{OV680_8BIT, 0x@array[1], 0x@array[2]},");
		$size = @array;
		if ($size > 3) {
			$index = 3;
			print OUTFILE (" /*");
			while ($index < $size) {
				if (@array[$index] =~ m/^;$/) {
					$index++;
					next;
				} 

				if (@array[$index] =~ m/^;(.*)/s) {
					print OUTFILE (" /* $1");
				} else {
					print OUTFILE (" @array[$index]");
				}
				$index++;
			}
			print OUTFILE (" */");
		}
		print OUTFILE ("\n");
		goto next_line;
	}

	if (/^$/) {
		if ($comment == 1) {
			print OUTFILE ("*/\n");
			$comment = 0;
		}
		print OUTFILE ("\n");
		goto next_line;
	}

	if (m/^;+(.*)/s) {
		print OUTFILE ("\t/* $1 */\n");
		goto next_line;
	}

	if (m/^sl.+/s) {
		@array = split(/\s+/, $_);
		if ((@array[1] =~ m/^(\d+)$/) && 
			@array[1] == @array[2]) {
			printf OUTFILE ("\t{OV680_TOK_DELAY, 0x0, 0x%x},", $1);
		} else {
			$missed++;
		} 

		print OUTFILE (" /* $_ */\n");
		goto next_line;
	}
#missed line
	$missed++;
next_line:
	$num_line++;
}

if ($comment == 1) {
	print OUTFILE ("*/\n");
	$comment = 0;
}

#file ending
print OUTFILE ("\t{OV680_TOK_TERM, 0, 0}\n");
print OUTFILE ("};\n");
close INFILE;
close OUTFILE;

select STDOUT;
print("Total handled lines: $num_line\n");
if ($missed != 0) {
	print("missed $missed convert FAILED!\n\n")
} else {
	print("convert PASS\n\n");
}

