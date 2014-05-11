#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include "ov680.h"
#include "ov680_debug_fw.h"

int main(int argc, char** argv)
{
	unsigned int i = 0;
	unsigned int cmd_count = 0;
	unsigned int cmd_size = 0;

	char *fw_fname = "./ov680_fw.bin";
	int fw_fd = -1;
	unsigned int written_size = 0;
	unsigned int total_written_size = 0;
	int rtn = 1;

	if (argc > 1)
		fprintf(stderr, "Arguments are unneeded and omitted.\n");

	fw_fd = open(fw_fname, O_WRONLY | O_CREAT | O_TRUNC, 0664);
	if (-1 == fw_fd) {
		fprintf(stderr, "Error creating firwware file: %s(%s)!\n", fw_fname, strerror(errno));
		return rtn;
	}

	cmd_count = sizeof(ov680_debug_fw)/sizeof(ov680_debug_fw[0]);
	cmd_size = sizeof(unsigned char); // now 1 byte

	/* Part 0: total command count (4 bytes) */
	written_size = write(fw_fd, (void *)&cmd_count, sizeof(cmd_count));
	total_written_size = (written_size>0)? (total_written_size+written_size):total_written_size;
	if (written_size != sizeof(cmd_count))
		goto done;

	/* Part 1: the size of each command (1 bytes) */
	written_size = write(fw_fd, (void *)&cmd_size, sizeof(cmd_size));
	total_written_size = (written_size>0)? (total_written_size+written_size):total_written_size;
	if (written_size != sizeof(cmd_size))
		goto done;

	/* Part 2: start address (2 bytes) */
	struct ov680_reg *p = (struct ov680_reg *)&(ov680_debug_fw[0]);
	unsigned short start_addr = p->reg;
	// change to big endian
	unsigned short temp = start_addr;
	start_addr  = ((unsigned short)(temp >> 8) & 0xFF) | (unsigned short)(temp << 8); 
	printf("start addr %x %x\n", temp, start_addr);
	written_size = write(fw_fd, (void *)&start_addr, sizeof(unsigned short));
	total_written_size = (written_size>0)? (total_written_size+written_size):total_written_size;
	if (written_size != sizeof(start_addr))
		goto done;

	/* Part 3: commands one by one (1N bytes) */
	for (i=0; i<cmd_count; ++i) {
		p = (struct ov680_reg *)&(ov680_debug_fw[i]);
		unsigned char val = p->val;
		written_size = write(fw_fd, (void *)&val, sizeof(unsigned char));
		total_written_size = (written_size>0)? (total_written_size+written_size):total_written_size;
		if (written_size != cmd_size)
			goto done;
	}
	rtn = 0; /* No errors when writting */

done:
	if (rtn)
		fprintf(stderr, "Error writting to firwware file: %s(%s)!\n\n", fw_fname, strerror(errno));

	printf("%d item(s) detected totally.\n"
		"%d item(s) written successfully.\n"
		"%d byte(s) written to %s.\n", cmd_count, i, total_written_size, fw_fname);

	close(fw_fd);

	return rtn;
}
