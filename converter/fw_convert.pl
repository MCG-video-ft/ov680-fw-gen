#!/usr/bin/perl
#$var = $ARGV[1];
if (($cmd_ = @ARGV) != 1) {
	print STDOUT ("usage: ./fw_convert.pl <file_name>\n");
	exit;
}

$machine_file = @ARGV[0];
unless (open (INFILE, "$machine_file")) {
	die ("cannot open input file $machine_file\n");
}
print STDOUT ("read file: $machine_file\n");

$c_header_file = "ov680_debug_fw.h";
print STDOUT ("wirting to file: $c_header_file\n");
unless (open (OUTFILE, "> $c_header_file")) {
	die ("cannot open input file $c_header_file\n");
}

$array_start = 0;
$comment = 0;
$num_line = 0; #debug
$missed = 0;
$array_name = "static struct ov680_reg const ov680_debug_fw[] = {\n";

while (<INFILE>) {
	chomp($_);
	#remove the extra blanks
	s/(\s*)$//;

	if (/^;end/) {
		#print OUTFILE ("\t{OV680_TOK_TERM, 0, 0}\n");
		print OUTFILE ("};\n");
		chomp;
		print OUTFILE ("/* $_ */");
		goto next_line;
	}

	if (/^;/ && ($comment == 0)) {
		print OUTFILE ("/*\n");
		$comment = 1;
		print OUTFILE ("$_\n");
		goto next_line;
	}

	if (/^;/) {
		print OUTFILE ("$_\n");
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

	if (/^6A/i) {
		if ($comment == 1) {
			print OUTFILE ("*/\n");
			$comment = 0;
		}
		if ($array_start == 0) {
			$array_start = 1;
			print OUTFILE ($array_name);
		}
		chomp;
		@array = split(/ /, $_);
		printf OUTFILE ("\t{OV680_8BIT, 0x@array[1], 0x@array[2]},\n");
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
close INFILE;
close OUTFILE;

select STDOUT;
print("Total handled lines: $num_line\n");
if ($missed != 0) {
	print("missed $missed convert FAILED!\n\n")
} else {
	print("convert PASS\n\n");
}

