#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory>
#include <vector>

struct FILETABLE_HDR
{
	uint32_t Magic1;
	uint32_t Magic2;
	uint32_t HeaderSize;
	uint32_t FileCount;
};

struct FILETABLE_ENTRY
{
	char Name[16];
	uint16_t LengthInSectors;
	uint16_t Padding;
};

size_t CopySingleFile(char* output, size_t outputSize, const char* filename)
{
	FILE* file = fopen(filename, "rb");
	if (!file)
	{
		fprintf(stderr, "Failed to open file %s\n", filename);
		return 0;
	}
	
	size_t length = 0;
	
	for (;;)
	{
		char buf[512];
		memset(buf, 0, 512);
		
		if (0 == fread(buf, 1, 512, file))
		{
			break;
		}
		
		if (outputSize < 512)
		{
			fprintf(stderr, "File overran image\n");
			fclose(file);
			return 0;
		}
		
		memcpy(output, buf, 512);
		output += 512;
		outputSize -= 512;
		length += 512;
	}
	
	fclose(file);
	
	return length;
}

int main(int argc, char** argv)
{
	if (argc <= 1)
	{
		fprintf(stderr, "No output file specified\n");
		return -1;
	}
	
	if (argc <= 2)
	{
		fprintf(stderr, "No stage1 bootloader specified");
		return -1;
	}

	std::unique_ptr<char[]> buf(new char[1440*1024]);
	memset(buf.get(), 0, 1440*1024);
	
	auto outputFile = fopen(argv[1], "wb");
	if (!outputFile)
	{
		fprintf(stderr, "Failed to open output file\n");
		return -1;
	}
	
	// Do the stage 1 bootloader first
	size_t length = CopySingleFile(buf.get(), 1440*1024, argv[2]);
	if (length == 0)
	{
		fprintf(stderr, "Failed to copy bootloader\n");
		return -1;
	}
	
	// The next step is to build a file table for each file
	struct TableEntry
	{
		size_t m_length;
		std::unique_ptr<char[]> m_buf;
		std::string m_name;
		
		TableEntry()
			: m_length(0)
			, m_buf()
			, m_name()
		{ }
	};
	std::vector<TableEntry> entries;
	
	for (int arg = 3; arg < argc; ++arg)
	{
		FILE* thisFile = fopen(argv[arg], "rb");
		if (!thisFile)
		{
			fprintf(stderr, "Failed to open file %s\n", argv[arg]);
			return -1;
		}
		
		TableEntry entry;
		
		fseek(thisFile, 0, SEEK_END);
		auto realLength = ftell(thisFile);
		rewind(thisFile);
		
		entry.m_length = ((realLength + 511) / 512) * 512;
		entry.m_buf.reset(new char[entry.m_length]);
		memset(entry.m_buf.get(), 0, entry.m_length);
		
		if (realLength != fread(entry.m_buf.get(), 1, realLength, thisFile))
		{
			fprintf(stderr, "Failed to read file %s\n", argv[arg]);
			fclose(thisFile);
			return -1;
		}
		
		fclose(thisFile);
		
		auto lastSlashPos = strrchr(argv[arg], '/');
		if (lastSlashPos)
		{
			entry.m_name = lastSlashPos + 1;
		}
		else
		{
			entry.m_name = argv[arg];
		}
		
		entries.push_back(std::move(entry));
	}
	
	auto fileTableSize = sizeof(FILETABLE_HDR) + (entries.size() * sizeof(FILETABLE_ENTRY));
	fileTableSize = ((fileTableSize + 511) / 512) * 512;
	std::unique_ptr<char[]> fileTableBuf(new char[fileTableSize]);
	
	auto fileTableHdr = reinterpret_cast<FILETABLE_HDR*>(fileTableBuf.get());
	fileTableHdr->Magic1 = 0x736f7473;
	fileTableHdr->Magic2 = 0x746f6f62;
	fileTableHdr->HeaderSize = sizeof(*fileTableHdr);
	fileTableHdr->FileCount = entries.size();
	
	auto fileTableOffset = length;
	length += fileTableSize;
	
	auto fileTableEntries = reinterpret_cast<FILETABLE_ENTRY*>(fileTableHdr + 1);
	for (const auto& file : entries)
	{
		memcpy(buf.get() + length, file.m_buf.get(), file.m_length);
		length += file.m_length;
		
		strncpy(fileTableEntries->Name, file.m_name.c_str(), 16);
		fileTableEntries->LengthInSectors = file.m_length / 512;
		++fileTableEntries;
	}
	
	// Put the file table in
	memcpy(buf.get() + fileTableOffset, fileTableBuf.get(), fileTableSize);
	
	// Write the file out
	fwrite(buf.get(), 1440*1024, 1, outputFile);
	fclose(outputFile);

	return 0;
}
