namespace bl
{

struct RMCallContext
{
	unsigned int OpCode;
	unsigned int Vector;
	unsigned int EAX;
	unsigned int EBX;
	unsigned int ECX;
	unsigned int EDX;
	unsigned int ESI;
	unsigned int EDI;
	unsigned int DS;
	unsigned int ES;
	unsigned int EFLAGS;
	unsigned int FramePtr;
	unsigned int FrameSize;
	unsigned int FuncPtr;
	unsigned int ReturnESP;
	unsigned int ReturnCR3;
};

void Print(const char* text);
void CallRealMode(RMCallContext* context);

}
