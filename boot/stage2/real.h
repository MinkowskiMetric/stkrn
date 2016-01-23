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

#define EFLAG_CF     0x00000001
#define EFLAG_PF     0x00000004
#define EFLAG_AF     0x00000010
#define EFLAG_ZF     0x00000040
#define EFLAG_SF     0x00000080
#define EFLAG_TF     0x00000100
#define EFLAG_IF     0x00000200
#define EFLAG_DF     0x00000400
#define EFLAG_OF     0x00000800
#define EFLAG_IOPL   0x00003000
#define EFLAG_NT     0x00004000
#define EFLAG_RF     0x00010000
#define EFLAG_VM     0x00020000
#define EFLAG_AC     0x00040000
#define EFLAG_VIF    0x00080000
#define EFLAG_VIP    0x00100000
#define EFLAG_ID     0x00200000

void RlPrint(const char* text);
void RlCallRealMode(RMCallContext* context);

#ifdef __cplusplus
}
#endif
