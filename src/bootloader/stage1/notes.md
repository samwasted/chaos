#0x01
🔹 The problem it solves

When the BIOS loads the boot sector, it copies 512 bytes into memory at physical address 0x7C00.

But BIOSes disagree on how they set CS:IP:

Some set CS = 0x0000, IP = 0x7C00 → linear address = 0x0000 * 16 + 0x7C00 = 0x7C00 

Others set CS = 0x07C0, IP = 0x0000 → linear address = 0x07C0 * 16 + 0x0000 = 0x7C00 

Both point to the same place in memory, but your code’s segment assumptions matter later.

If you assume CS = 0x0000 but BIOS set 0x07C0, your far jumps/calls may land in the wrong place.
So we need to normalize CS to a known value.

#0x02
int 13h (or INT 13h) is an x86 BIOS interrupt used for disk services.

When you call int 13h in real mode, you’re telling the BIOS: “Hey, I want to read/write sectors on a disk.”

What it does

It provides low-level access to disks (floppy, hard disk) before any OS or filesystem drivers take over.

It works with CHS (Cylinder-Head-Sector) or LBA (Logical Block Addressing) depending on function.

Example uses (via AH register function codes):

AH = 00h → Reset disk system

AH = 02h → Read sectors from disk

AH = 03h → Write sectors to disk

AH = 08h → Get drive parameters (heads, cylinders, sectors per track)

#0x03
Part 1 – Extracting sectors per track and heads
and cl, 0x3F                 ; remove top 2 bits of CL
xor ch, ch

mov [bdb_sectors_per_track], cx ; store sector count

inc dh
mov [bdb_heads], dh           ; store head count

BIOS returns drive geometry via INT 13h/AH=08h (get drive parameters).
CX contains cylinder + sector info:

lower 6 bits of CL = sector number (1–63).

upper 2 bits of CL = high bits of cylinder.

and cl, 0x3F → mask out upper 2 bits, leaving only the sector count.

ch=0 clears high bits, so cx now = sectors per track.

DH = max head number (0-based). inc dh makes it head count.

So now you’ve got:

bdb_sectors_per_track = number of sectors in one track.

bdb_heads = number of heads.

Part 2 – Compute LBA of root directory
mov ax, [bdb_sectors_per_fat]
mov bl, [bdb_fat_count]
xor bh, bh
mul bx                            ; ax = fats * sectors_per_fat
add ax, [bdb_reserved_sectors]    ; ax = reserved + (fats * spf)
push ax                           ; save LBA of root dir
FAT filesystem layout:
[Reserved sectors] + [FAT area] + [Root Directory] + [Data area]
Root directory starts after reserved sectors and FATs.

Formula:
root_dir_lba = reserved + (fats * sectors_per_fat)

That’s exactly what’s happening here.

Part 3 – Compute size of root directory

mov ax, [bdb_dir_entries_count] ; number of root entries (from BPB)
shl ax, 5                       ; * 32 (since each entry is 32 bytes)
xor dx, dx
div word [bdb_bytes_per_sector] ; ax = sectors needed, dx = remainder

Each root directory entry = 32 bytes.

dir_entries_count * 32 = total size of root directory in bytes.

Divide by bytes_per_sector to get how many sectors are needed.

dx = remainder:

if dx = 0, exact fit.

if dx ≠ 0, we need one extra sector for the leftover entries.

Part 4 – Adjust if remainder exists

test dx, dx
jz .root_dir_after
inc ax                          ; add 1 sector if remainder exists

f the division left a remainder, we inc ax to allocate an extra sector.

So now AX = total number of sectors in the root directory.


#0x04
push ax              ; save AX (will hold LBA before conversion)
push dx              ; save DX (because DIV will overwrite DX)

xor dx, dx           ; clear DX → DX:AX = LBA (we want a 32-bit dividend)
div word [bdb_sectors_per_track] 
                     ; divide LBA by sectors_per_track
                     ; → quotient in AX = cylinder*heads (CH)
                     ; → remainder in DX = sector-1
DX:AX = dx*(2^16) + ax, in 16 bit mode