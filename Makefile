ov680_debug_fw: ov680_debug_fw.c
	gcc -o ov680_debug_fw ov680_debug_fw.c
clean:
	rm -rf ov680_debug_fw *.o
