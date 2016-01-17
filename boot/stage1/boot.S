.intel_syntax noprefix

# Define the RM_CALL_CONTEXT_STRUCT
  .struct 0
  .balign 4
RMCALLCTXT_OpCode:
  .struct RMCALLCTXT_OpCode + 4
  .balign 4
RMCALLCTXT_Vector:
  .struct RMCALLCTXT_Vector + 4
  .balign 4
RMCALLCTXT_EAX:
  .struct RMCALLCTXT_EAX + 4
  .balign 4
RMCALLCTXT_EBX:
  .struct RMCALLCTXT_EBX + 4
  .balign 4
RMCALLCTXT_ECX:
  .struct RMCALLCTXT_ECX + 4
  .balign 4
RMCALLCTXT_EDX:
  .struct RMCALLCTXT_EDX + 4
  .balign 4
RMCALLCTXT_ESI:
  .struct RMCALLCTXT_ESI + 4
  .balign 4
RMCALLCTXT_EDI:
  .struct RMCALLCTXT_EDI + 4
  .balign 4
RMCALLCTXT_DS:
  .struct RMCALLCTXT_DS + 4
  .balign 4
RMCALLCTXT_ES:
  .struct RMCALLCTXT_ES + 4
  .balign 4
RMCALLCTXT_EFLAGS:
  .struct RMCALLCTXT_EFLAGS + 4
  .balign 4
RMCALLCTXT_FramePtr:
  .struct RMCALLCTXT_FramePtr + 4
  .balign 4
RMCALLCTXT_FrameSize:
  .struct RMCALLCTXT_FrameSize + 4
  .balign 4
RMCALLCTXT_FuncPtr:
  .struct RMCALLCTXT_FuncPtr + 4
  .balign 4
RMCALLCTXT_ReturnESP:
  .struct RMCALLCTXT_ReturnESP + 4
  .balign 4
RMCALLCTXT_ReturnCR3:
  .struct RMCALLCTXT_ReturnCR3 + 4
  .balign 4
RMCALLCTXT_SIZE:

# STAGE2STARTCTX
  .struct 0
  .balign 4
STAGE2STARTCTX_StructSize:
  .struct STAGE2STARTCTX_StructSize + 4
  .balign 4
STAGE2STARTCTX_Print:
  .struct STAGE2STARTCTX_Print + 4
  .balign 4
STAGE2STARTCTX_CallRealMode:
  .struct STAGE2STARTCTX_CallRealMode + 4
  .balign 4
STAGE2STARTCTX_SIZE:
  
# FILETABLE_HDR
  .struct 0
  .balign 4
FILETABLE_HDR_Magic1:
  .struct FILETABLE_HDR_Magic1 + 4
  .balign 4
FILETABLE_HDR_Magic2:
  .struct FILETABLE_HDR_Magic2 + 4
  .balign 4
FILETABLE_HDR_HeaderSize:
  .struct FILETABLE_HDR_HeaderSize + 4
  .balign 4
FILETABLE_HDR_FileCount:
  .struct FILETABLE_HDR_FileCount + 4
  .balign 4
FILETABLE_HDR_SIZE:

# FILETABLE_ENTRY
  .struct 0
  .balign 1
FILETABLE_ENTRY_Name:
  .struct FILETABLE_ENTRY_Name + 16
  .balign 2
FILETABLE_ENTRY_LengthInSectors:
  .struct FILETABLE_ENTRY_LengthInSectors + 2
  .balign 2
FILETABLE_ENTRY_Padding:
  .struct FILETABLE_ENTRY_Padding + 2
  .balign 2
FILETABLE_ENTRY_SIZE:

.text
.code16
.org 0x0                                        

NULL_SELECTOR     = 0x00
LM_CODE_SELECTOR  = 0x08
LM_DATA_SELECTOR  = 0x10
TSS_SELECTOR      = 0x18
TSS_SELECTOR_HIGH = 0x20
RM_CODE_SELECTOR  = 0x28
RM_DATA_SELECTOR  = 0x30
PM_CODE_SELECTOR  = 0x38
PM_DATA_SELECTOR  = 0x40

CR0_PE              = 0x00000001
CR0_NE              = 0x00000020
CR0_PG              = 0x80000000

CR4_PSE             = 0x00000010
CR4_PAE             = 0x00000020
CR4_PCE             = 0x00000100
CR4_OSFXSR          = 0x00000200

PM_STACK_TOP        = 0x00021c00

KERNEL_FT_BUFFER    = 0x00021c00
SECTOR_BUFFER       = 0x00021e00
STAGE2_LOAD_BUFFER  = 0x00030000
STAGE2_BASE_ADDRESS = 0xc0030000
STAGE2_LIMIT_ADDR   = 0xc0100000
STAGE2_MAX_SECTORS  = (STAGE2_LIMIT_ADDR - STAGE2_BASE_ADDRESS) / 0x200

FT_MAGIC1           = 0x736f7473
FT_MAGIC2           = 0x746f6f62

PM_PML4_ADDRESS     = 0x00022000
PM_PDPT_ADDRESS     = 0x00023000
PM_PDT0_ADDRESS     = 0x00024000
PM_PDT1_ADDRESS     = 0x00025000
PM_PDT2_ADDRESS     = 0x00026000
PM_PDT3_ADDRESS     = 0x00027000

KERNEL_FILE_TABLE_SECTOR = 5
STAGE2_START_SECTOR      = 6

PTE_PRESENT         = 0x00000001
PTE_WRITEABLE       = 0x00000002 
PTE_ACCESSED        = 0x00000020
PTE_2MB             = 0x00000080

RM_LCOP_PRINT       = 0x00
RM_LCOP_INTXX       = 0x01

.global _start
 
_start:
  jmp short bootloader               # jump to beginning of code
  nop
 
bootsector:
 iOEM:          .ascii "DevOS   "    # OEM String
 iSectSize:     .word  0x200         # bytes per sector
 iClustSize:    .byte  1             # sectors per cluster
 iResSect:      .word  1             # #of reserved sectors
 iFatCnt:       .byte  2             # #of FAT copies
 iRootSize:     .word  224           # size of root directory
 iTotalSect:    .word  2880          # total # of sectors if over 32 MB
 iMedia:        .byte  0xF0          # media Descriptor
 iFatSize:      .word  9             # size of each FAT
 iTrackSect:    .word  9             # sectors per track
 iHeadCnt:      .word  2             # number of read-write heads
 iHiddenSect:   .int   0             # number of hidden sectors
 iSect32:       .int   0             # # sectors for over 32 MB
 iBootDrive:    .byte  0             # holds drive that the boot sector came from
 iReserved:     .byte  0             # reserved, empty
 iBootSign:     .byte  0x29          # extended boot sector signature
 iVolID:        .ascii "seri"        # disk serial
 acVolumeLabel: .ascii "MYVOLUME   " # volume label
 acFSType:      .ascii "FAT16   "    # file system type
 
bootloader:
  jmp 0x7c0,stage1                   # far jump into the main bootloader code to get cs:ip to 07c0:0000

stage1:
  cli
  mov cx, cs			     # copy cs into ss, ds, ss, es and set the stack to 07c0:0400
  mov ss, cx
  mov sp, 0x400
  mov es, cx
  mov ds, cx
  mov bp, sp
  sti

  mov [iBootDrive], dl               # save the boot drive for later

  mov ax, 0x02
  int 0x10                           # clear the screen

  lea si, [LoadingMsg]
  call Print

reset_floppy:
  mov ah, 0
  mov dl, [iBootDrive]
  int 0x13
  jc reset_floppy

  mov ax, 0x800                      # load everything that comes after us
  mov es, ax
  xor bx, bx

  mov al, 5                          # read 5 sectors (four for the rest of the code and one for the file list)
  mov ch, 0                          # we are reading the second sector past us so its still on track 1
  mov cl, 3                          # sector to read (third sector - skip the stack)
  mov dh, 0
  call ReadSector

  cmpw [Tag2], 0xaa55
  jne InvalidBootMedium
  lea bx, [Tag3]
  cmpw [bx], 0xaa55
  jne InvalidBootMedium

  jmp Stage15Entry

.func Print
Print:
  lodsb                              # load the next character
  or al, al                          # compare for zero
  jz 1f			             # if it is zero we're done
  mov ah, 0x0e		             # load print character command
  mov bx, 0x09                       # load character attributes
  int 0x10                           # print
  jmp Print                          # keep going
1:
  ret
.endfunc
	
.func InvalidBootMedium
InvalidBootMedium:
  lea si, InvalidBootMessage
  jmp PrintErrorAndHalt
.endfunc

.func PrintErrorAndHalt
PrintErrorAndHalt:
  call Print
1:
  cli
  hlt
  jmp 1b
.endfunc

.func ReadSector
ReadSector:
1:
  mov ah, 2
  mov dl, [iBootDrive]
  int 0x13
  jc 1b
  ret
.endfunc

LoadingMsg:          .asciz "Loading STOS...\r\n"
InvalidBootMessage:  .asciz "Invalid Boot Medium\r\n"
EnteringProtectedModeMsg: .asciz "Entering protected mode...\r\n"

# GDT
.align 16
GDTStart:
  .quad 0x0000000000000000          # 00: NULL segment
  .quad 0x0020980000000000          # 08: LM code segment
  .quad 0x0000930000000000          # 10: LM data segment
  .quad 0x0000000000000000          # 18: TSS segment
  .quad 0x0000000000000000          # 20: TSS segment
  .quad 0x00009B007C00FFFF          # 28: 00007C00[0000ffff] Code
  .quad 0x000093007C00FFFF          # 30: 00007C00[0000ffff] Data
  .quad 0x00CF9B000000FFFF          # 38: PM code segment
  .quad 0x00CF93000000FFFF          # 40: PM data segment

GDTLimit:

.align 16
  .word 0                           # Padding to align GDTS
  .word 0
  .word 0
GDTS_Limit:
  .word GDTLimit - GDTStart
GDTS_Address:
  .word 0x7c00 + offset GDTStart
  .word 0
  .int 0
 
.fill (0x1fe-(.-_start)), 1, 0  # Pad with nulls up to 510 bytes (excl. boot magic)
BootMagic:  .word 0xAA55     # magic word for BIOS

SpaceForStack: .fill (0x200), 1, 0

.func Stage15Entry
Stage15Entry:
  mov si, offset EnteringProtectedModeMsg
  call Print

  cli					# interrupts disabled before we start messing with the mode. Can't enable until IDT is good.

  mov di, offset GDTS_Limit
  lgdt ds:[di]				# load the GDT pointer

  xor ax, ax				# zero out the real mode segment registers
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov fs, ax
  mov gs, ax

  mov eax, cr0				# enable protected mode
  or eax, CR0_PE | CR0_NE
  mov cr0, eax

  jmp PM_CODE_SELECTOR, 0x7c00 + offset Stage15Entry32
.endfunc

.align 16
.func ReturnToRealMode
ReturnToRealMode:

  # We're called in 16-bit protected mode with ecx pointing to the start of
  # the context structure and top of the stack
  sub ecx, 0x7c00

  # Disable protected mode
  mov eax, cr0
  and eax, ~(CR0_PE | CR0_NE)
  mov cr0, eax

  # return to real mode
  jmp 0x07c0, OFFSET ProcessRealModeRequest

.endfunc

.func ProcessRealModeRequest
ProcessRealModeRequest:

  # Set up the remaining segments
  mov ax, cs
  mov ds, ax
  mov ss, ax
  mov es, ax

  # cx points to the start of the context and the top of the stack
  movzx esp, cx
  mov bx, cx

  # save the context pointer on the stack
  push cx

  # Get the op code
  mov eax, dword ptr [bx + RMCALLCTXT_OpCode]

  cmp eax, RM_LCOP_PRINT
  jne 1f

  mov ax, word ptr [bx + RMCALLCTXT_FramePtr]
  sub ax, 0x7c00
  mov si, ax
  call Print
  jmp ProcessRealModeRequest_Exit

1:
  cmp eax, RM_LCOP_INTXX
  jne 2f

  call ProcessIntXX
  jmp ProcessRealModeRequest_Exit

2:
ProcessRealModeRequest_Exit:

  # tidy the stack
  pop cx

  # restore the gdt
  mov di, offset GDTS_Limit
  lgdt ds:[di]

  # clear the real mode segment registers
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov fs, ax
  mov gs, ax
  
  # Enable ptotected mode
  mov eax, cr0
  or eax, CR0_PE | CR0_NE
  mov cr0, eax

  # jump back to protected mode
  jmp PM_CODE_SELECTOR, 0x7c00 + offset ReturnToProtectedMode

.endfunc

.macro SAVE_CONTEXT_TO_STACK
  push eax
  push ebx
  push ecx
  push edx
  push esi
  push edi
  push ds
  push es
  pushfd
.endm

.macro RESTORE_CONTEXT_FROM_STACK
  popfd
  pop es
  pop ds
  pop edi
  pop esi
  pop edx
  pop ecx
  pop ebx
  pop eax
.endm

.macro SAVE_CALL_CONTEXT_TO_STACK
  mov ax, ds
  mov word ptr [CallContextSeg], ax
  mov word ptr [CallContextOff], bx
  
  push dword ptr [bx + RMCALLCTXT_EAX]
  push dword ptr [bx + RMCALLCTXT_EBX]
  push dword ptr [bx + RMCALLCTXT_ECX]
  push dword ptr [bx + RMCALLCTXT_EDX]
  push dword ptr [bx + RMCALLCTXT_ESI]
  push dword ptr [bx + RMCALLCTXT_EDI]
  push word ptr [bx + RMCALLCTXT_DS]
  push word ptr [bx + RMCALLCTXT_ES]
  pushfd
.endm

.macro RESTORE_CALL_CONTEXT_FROM_STACK
  # need to recover the data segment which should be the same as the code segment
  mov ax, cs
  mov ds, ax
  
  mov ax, word ptr [CallContextSeg]
  mov es, ax
  mov si, word ptr [CallContextOff]

  pop dword ptr es:[si + RMCALLCTXT_EFLAGS]
  pop word ptr es:[si + RMCALLCTXT_ES]
  pop word ptr es:[si + RMCALLCTXT_DS]
  pop dword ptr es:[si + RMCALLCTXT_EDI]
  pop dword ptr es:[si + RMCALLCTXT_ESI]
  pop dword ptr es:[si + RMCALLCTXT_EDX]
  pop dword ptr es:[si + RMCALLCTXT_ECX]
  pop dword ptr es:[si + RMCALLCTXT_EBX]
  pop dword ptr es:[si + RMCALLCTXT_EAX]
.endm

.func ProcessIntXX
ProcessIntXX:

  mov cl, byte ptr [bx + RMCALLCTXT_Vector]
  mov byte ptr [IntVectorCode], cl

  SAVE_CONTEXT_TO_STACK
  SAVE_CALL_CONTEXT_TO_STACK
  RESTORE_CONTEXT_FROM_STACK

  .byte 0xcd
IntVectorCode:
  .byte 0x00

  SAVE_CONTEXT_TO_STACK
  RESTORE_CALL_CONTEXT_FROM_STACK
  RESTORE_CONTEXT_FROM_STACK

  ret

.endfunc

# Switch to 32 bit code for the rest of the file
.code32

.func Stage15Entry32
Stage15Entry32:
  mov ax, PM_DATA_SELECTOR		# Setup the rest of the segment registers
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov esp, PM_STACK_TOP			# Setup the protected mode stack. Not the same as the real mode stack

  mov ax, NULL_SELECTOR			# Clear fs and gs for now
  mov fs, ax
  mov gs, ax

  call SetupPageTables 			# Setup paging

  mov eax, cr4				# Enable PSE, PAE, performance counters and floating point support
  or eax, CR4_PSE | CR4_PAE | CR4_PCE | CR4_OSFXSR
  mov cr4, eax

  mov eax, PM_PDPT_ADDRESS		# Set the page table
  mov cr3, eax

  mov eax, cr0				# Enable paging
  or eax, CR0_PG
  mov cr0, eax

  # Load the next sector from the disk
  mov edx, KERNEL_FT_BUFFER
  mov ecx, KERNEL_FILE_TABLE_SECTOR
  call PMLoadLinearSector
  
  # verify the header magic number
  mov ebx, KERNEL_FT_BUFFER
  mov eax, dword ptr [ebx + FILETABLE_HDR_Magic1]
  cmp eax, FT_MAGIC1
  jne InvalidBootLoaderFileTable
  
  mov eax, dword ptr [ebx + FILETABLE_HDR_Magic2]
  cmp eax, FT_MAGIC2
  jne InvalidBootLoaderFileTable

  # Then check there is at least one entry in the file table
  mov eax, dword ptr [ebx + FILETABLE_HDR_FileCount]
  cmp eax, 1
  jl InvalidBootLoaderFileTable

  # and check that the whole file table fit into a single sector
  mov ecx, FILETABLE_ENTRY_SIZE
  mul ecx
  add eax, dword ptr [ebx + FILETABLE_HDR_HeaderSize]
  cmp eax, 0x200
  jg InvalidBootLoaderFileTable

  # Check it will fit into the memory region we have
  mov eax, dword ptr [ebx + FILETABLE_HDR_SIZE + 16]
  cmp eax, STAGE2_MAX_SECTORS
  jg Stage2TooBig

  # Load the stage 2 loader into memory. It is a raw executable
  # so it is easy to load here
  mov esi, STAGE2_START_SECTOR
  mov edi, STAGE2_LOAD_BUFFER
1:
  mov ecx, 0x7c00 + OFFSET LoadingNextSector
  call PMPrint
  
  mov ecx, esi
  mov edx, edi
  call PMLoadLinearSector

  mov eax, dword ptr [ebx + FILETABLE_HDR_SIZE + 16]
  add eax, STAGE2_START_SECTOR - 1
  cmp eax, esi
  jle 2f
  inc esi
  add edi, 0x200
  jmp 1b
  
2:
  # allocate some space on the stack for the handover function
  sub esp, STAGE2STARTCTX_SIZE
  mov ecx, esp
  
  mov dword ptr [ecx + STAGE2STARTCTX_StructSize], 0x7c00 + offset STAGE2STARTCTX_SIZE
  mov dword ptr [ecx + STAGE2STARTCTX_Print], 0x7c00 + offset PMPrint
  mov dword ptr [ecx + STAGE2STARTCTX_CallRealMode], 0x7c00 + offset LeaveProtectedMode
  
  # Then call into the stage 2 loader
  mov eax, STAGE2_BASE_ADDRESS
  jmp eax

InvalidBootLoaderFileTable:
  mov ecx, 0x7c00 + offset InvalidKernelFileTable
  jmp PMPrintAndHalt
Stage2TooBig:
  mov ecx, 0x7c00 + offset Stage2TooBigMessage
  jmp PMPrintAndHalt

.endfunc

TestString: .asciz "TEST STRING\r\n"

.func PMPrintAndHalt
PMPrintAndHalt:
  call PMPrint

  cli
  hlt
1:
  jmp 1b
.endfunc

.func PMPrint
PMPrint:

  push ebx
  push edi
  push ebp
  mov ebp, esp

  # ecx points to the string to print

  sub esp, RMCALLCTXT_SIZE
  mov ebx, esp		# Allocate a RMCALLCTXT struct on the stack and place the pointer in EBX

  mov eax, RM_LCOP_PRINT
  mov dword ptr [ebx + RMCALLCTXT_OpCode], eax
  xor eax, eax
  mov dword ptr [ebx + RMCALLCTXT_Vector], eax
  mov dword ptr [ebx + RMCALLCTXT_EAX], eax
  mov dword ptr [ebx + RMCALLCTXT_EBX], eax
  mov dword ptr [ebx + RMCALLCTXT_ECX], eax
  mov dword ptr [ebx + RMCALLCTXT_EDX], eax
  mov dword ptr [ebx + RMCALLCTXT_ESI], eax
  mov dword ptr [ebx + RMCALLCTXT_EDI], eax
  mov dword ptr [ebx + RMCALLCTXT_DS], eax
  mov dword ptr [ebx + RMCALLCTXT_ES], eax
  mov dword ptr [ebx + RMCALLCTXT_EFLAGS], eax
  mov dword ptr [ebx + RMCALLCTXT_FuncPtr], eax

  mov dword ptr [ebx + RMCALLCTXT_FramePtr], ecx	# Store the string pointer here
	
  mov edi, ecx
  repne scasb
  mov ecx, dword ptr [ebx + RMCALLCTXT_FramePtr]
  sub edi, ecx
  mov dword ptr [ebx + RMCALLCTXT_FrameSize], edi

  mov ecx, ebx
  call LeaveProtectedMode

  mov esp, ebp
  pop ebp
  pop edi
  pop ebx
  ret

.endfunc

.func PMLoadLinearSector
PMLoadLinearSector:

  # ecx contains the sector index, edx contains the pointer to the buffer to copy to which
  # must be below 1MB
  
  push ebx
  push edi
  push ebp
  mov ebp, esp

  # allocate a call context
  sub esp, RMCALLCTXT_SIZE
  mov ebx, esp

  # zero the context
  push ecx
  mov edi, ebx
  mov ecx, RMCALLCTXT_SIZE
  xor eax, eax
  rep stosb
  pop ecx

  # Setup the call to int 0x13
  mov eax, RM_LCOP_INTXX
  mov dword ptr [ebx + RMCALLCTXT_OpCode], eax
  mov eax, 0x13
  mov dword ptr [ebx + RMCALLCTXT_Vector], eax

  # Setup the output buffer
  mov eax, edx
  and eax, 0x0f
  mov dword ptr [ebx + RMCALLCTXT_EBX], eax
  shr edx, 4
  mov dword ptr [ebx + RMCALLCTXT_ES], edx

  # Work out the track index which goes in ch and the sector which goes in cl
  # head in dl and drive in dh
  mov eax, ecx
  xor edx, edx
  div dword ptr [FFloppySectorsPerTrack + 0x7c00]
  # puts sector index - 1 in edx and track index in eax. Store just the sector
  inc edx
  mov dword ptr [ebx + RMCALLCTXT_ECX], edx
  xor edx, edx
  div dword ptr [FFloppyHeads + 0x7c00]
  # puts head in edx and cylinder in eax
  shl eax, 8
  add eax, dword ptr [ebx + RMCALLCTXT_ECX]
  mov dword ptr [ebx + RMCALLCTXT_ECX], eax
  shl edx, 8
  mov dword ptr [ebx + RMCALLCTXT_EDX], edx

  # We always read a single sector
  mov eax, 0x201
  mov dword ptr [ebx + RMCALLCTXT_EAX], eax

  mov ecx, ebx
  call LeaveProtectedMode

  mov esp, ebp
  pop ebp
  pop edi
  pop ebx
  ret

.endfunc

.func LeaveProtectedMode
LeaveProtectedMode:

  # The caller passes a pointer to an RMCALLCTXT in ECX
  push edi
  push esi
  push ebp
  push ebx

  # keep the argument safe
  mov ebx, ecx

  # push pointer to the original context so we can get it back
  push ebx

  # we're going to use the real mode stack as our scratch area here. Start by
  # copying any frame onto the stack
  mov ecx, dword ptr [ebx + RMCALLCTXT_FrameSize]
  mov edi, 0x8000
  sub edi, ecx
  mov esi, dword ptr [ebx + RMCALLCTXT_FramePtr]
  rep movsb

  # next copy the rest of the context
  mov ecx, dword ptr [ebx + RMCALLCTXT_FrameSize]
  mov edi, 0x8000 - RMCALLCTXT_SIZE
  sub edi, ecx
  mov esi, ebx
  mov ecx, RMCALLCTXT_SIZE
  rep movsb

  # now modify some additional state
  mov ecx, 0x8000 - RMCALLCTXT_SIZE
  sub ecx, dword ptr [ebx + RMCALLCTXT_FrameSize]
  mov dword ptr [ecx + RMCALLCTXT_ReturnESP], esp
  mov eax, cr3
  mov dword ptr [ecx + RMCALLCTXT_ReturnCR3], eax
  lea eax, dword ptr [ecx + RMCALLCTXT_SIZE]
  mov dword ptr [ecx + RMCALLCTXT_FramePtr], eax

  # disable paging
  mov eax, cr0
  and eax, ~CR0_PG
  mov cr0, eax

  xor eax, eax
  mov cr3, eax
  mov cr4, eax

  jmp 1f

  .align 16
1:
  jmp RM_CODE_SELECTOR, OFFSET ReturnToRealMode

.endfunc

.func ReturnToProtectedMode
ReturnToProtectedMode:

  # Setup the rest of the segments and the stack. Don't reuse the real mode stack
  mov ax, PM_DATA_SELECTOR
  mov ds, ax
  mov es, ax
  mov ss, ax

  mov ax, NULL_SELECTOR
  mov fs, ax
  mov gs, ax

  # Recover the pointer to the context structure
  movzx eax, cx
  add eax, 0x7c00
  mov ecx, eax

  # Enable PSE, PAE, performance and floating point
  mov eax, cr4
  or eax, CR4_PSE | CR4_PAE | CR4_PCE | CR4_OSFXSR
  mov cr4, eax

  # Enable paging
  mov eax, dword ptr [ecx + RMCALLCTXT_ReturnCR3]
  mov cr3, eax
  
  mov eax, cr0
  or eax, CR0_PG
  mov cr0, eax

  # Put the stack pointer back
  mov esp, dword ptr [ecx + RMCALLCTXT_ReturnESP]
  
  jmp 1f

.align 16
1:
  # At this point ecx points to the real context so pop the pointer to the protected context
  pop edi
  mov esi, ecx
  mov ecx, RMCALLCTXT_SIZE
  rep movsb

  # restore the stack
  pop ebx
  pop ebp
  pop esi
  pop edi

  ret

.endfunc

.func SetupPageTables
SetupPageTables:

  xor eax, eax				# clear PML4
  mov edi, PM_PML4_ADDRESS
  mov ecx, 0x400
  rep stosd

  mov edi, PM_PDPT_ADDRESS		# clear PDPT
  mov ecx, 0x400
  rep stosd

  mov edi, PM_PDT0_ADDRESS		# clear PDTs
  mov ecx, 0x1000
  rep stosd

  mov eax, PM_PDPT_ADDRESS | PTE_PRESENT
					# setup the PML4 to map the PDPT at the start of user space and kernel space
  mov edi, PM_PML4_ADDRESS
  mov [edi], eax
  add edi, 0x800
  mov [edi], eax

  mov eax, PM_PDT0_ADDRESS | PTE_PRESENT
 					# setup the PDPT to map a single PDT into four locations in the map
  mov edi, PM_PDPT_ADDRESS
  mov esi, 512
1:
  mov [edi], eax
  add edi, 8
  dec esi
  test esi, esi
  jz 3f
  mov ebx, edi				# work out which of the four tables we're writing next
  and ebx, 3
  test ebx, ebx
  jz 2f
  add eax, PM_PDT1_ADDRESS - PM_PDT0_ADDRESS
  jmp 1b
2:
  mov eax, PM_PDT0_ADDRESS | PTE_PRESENT
  jmp 1b
3:

  mov eax, 0 | PTE_PRESENT | PTE_WRITEABLE | PTE_ACCESSED | PTE_2MB
  mov edi, PM_PDT0_ADDRESS
  mov esi, 2048

4:
  mov [edi], eax
  add eax, 2 * 1024 * 1024
  add edi, 8
  dec esi
  test esi, esi
  jz 5f
  jmp 4b

5:
  ret
.endfunc

CallContextSeg:
  .word 0
CallContextOff:
  .word 0
RealModeIdtr:
  .word 0x1000
  .int 0
ProtModeIdtr:
  .word 0x1000
  .int 0
InvalidKernelFileTable:
  .asciz "KFT Invalid"
Stage2TooBigMessage:
  .asciz "Stage2 too big"
LoadingNextSector:
  .asciz "Loading sector\r\n"
InvalidStage2Image:
  .asciz "Invalid stage 2 image\r\n"
FFloppySectorsPerTrack:
  .int 18
FFloppyHeads:
  .short 2

.fill (0x9fe-(.-_start)), 1, 0 # Pad with nulls to to 5 sectors
Tag2:
Tag3: .word 0xaa55



