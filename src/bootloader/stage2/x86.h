#pragma once //tells compare to include header only once, even if it tries to include multiple times
#include "stdint.h"


#ifndef _cdecl
#define _cdecl
#endif
#define u8 uint8_t 
#define u16 uint16_t


void _cdecl x86_div64_32(uint64_t dividend, uint32_t divisor, uint64_t* quotientOut, uint32_t* remainderOut);

void _cdecl x86_Video_WriteCharTeletype(char c, uint8_t page);

bool _cdecl x86_Disk_Reset(uint8_t drive);

bool _cdecl x86_Disk_Read(uint8_t drive,
                          uint16_t cylinder,
                          uint16_t sector,
                          uint16_t head,
                          uint8_t count,
                          void far * dataOut);

bool _cdecl x86_Disk_GetDriveParams(uint8_t drive,
                                    uint8_t* driveTypeOut,
                                    uint16_t* cylindersOut,
                                    uint16_t* sectorsOut,
                                    uint16_t* headsOut);
