from zlib import crc32
import os
import sys

def getCrc32(filename):
	with open(filename, 'rb') as f:
		return crc32(f.read())&0xffffffff
checksum=getCrc32(sys.argv[1])
print ('crc:',(hex(checksum)))
