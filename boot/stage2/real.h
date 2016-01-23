#include <types.h>

#ifdef __cplusplus
extern "C"
{
#endif
	
struct Stage2StartCtx
{
	uint32_t Size;
	uint32_t PrintFn;
	uint32_t CallRealModeFn;
	uint32_t BootDiskNumber;
};

const Stage2StartCtx* RlGetStartCtx(void);

struct RMCallContext
{
	uint32_t OpCode;
	uint32_t Vector;
	uint32_t EAX;
	uint32_t EBX;
	uint32_t ECX;
	uint32_t EDX;
	uint32_t ESI;
	uint32_t EDI;
	uint32_t DS;
	uint32_t ES;
	uint32_t EFLAGS;
	uint32_t FramePtr;
	uint32_t FrameSize;
	uint32_t FuncPtr;
	uint32_t ReturnESP;
	uint32_t ReturnCR3;
};

void RlPrint(const char* text);
void RlCallRealMode(RMCallContext* context);

#ifdef __cplusplus
}
#endif
