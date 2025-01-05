// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
// Developed by: Muhammad Hammad Bashir

// This test belongs to the test plan for RISC-V Privilege Arch Compliance developed by 10xEngineers
// which can be found here: https://docs.google.com/spreadsheets/d/153Wz5VKrDijXPHT43IVn3JHPxuA-cEeNcigTDqamnY8/edit?gid=0#gid=0

//This test verifies the basic working of big endianness using:
//1. BASIC Instructions             =   lb, lh, lw and sb, sh, sw
//2. Compressed Instructions        =   c.lw, c.sw


#include "model_test.h"
#include "arch_test.h"
RVTEST_ISA("RV32IC_Zicsr")
# Test code region
.section .text.init
.globl rvtest_entry_point
rvtest_entry_point:
RVMODEL_BOOT
RVTEST_CODE_BEGIN

#ifdef TEST_CASE_1
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*C.*Zicsr.*); def rvtest_mtrap_routine=True; def rvtest_strap_routine=True; def TEST_CASE_1=True",mstatus_mbe_basic)
RVTEST_SIGBASE( x3,signature_x3_1)

	.attribute unaligned_access, 0
	.attribute stack_align, 16
  	.align	2   

#define TEST_DATA   0x12345678
#define TEST_DATA1  0xFF345678
#define REV_DATA    0x78563412

main:
    csrw satp, zero
    jal TEST_MMODE_MBE

TEST_MMODE_MBE:
    jal enable_mstatush_mbe                                                 //Enable mstatush.MBE
    jal basic_instructions_enabled
    jal disable_mstatush_mbe                                                //Disable mstatush.MBE
    jal basic_instructions_disabled
    jal enable_mstatush_mbe                                                 //Enable mstatush.MBE
    jal compressed_instructions_enabled
    jal disable_mstatush_mbe                                                //Disable mstatush.MBE
    jal compressed_instructions_disabled
    RVTEST_GOTO_MMODE

TEST_SMODE_SBE:
    jal enable_mstatush_sbe
    RVTEST_GOTO_LOWER_MODE Smode
    jal basic_instructions_enabled
    RVTEST_GOTO_MMODE
    jal disable_mstatush_sbe                                                //Disable mstatush.MBE
    RVTEST_GOTO_LOWER_MODE Smode
    jal basic_instructions_disabled
    RVTEST_GOTO_MMODE
    jal enable_mstatush_sbe
    RVTEST_GOTO_LOWER_MODE Smode
    jal compressed_instructions_enabled
    RVTEST_GOTO_MMODE
    jal disable_mstatush_sbe                                                //Disable mstatush.MBE
    RVTEST_GOTO_LOWER_MODE Smode
    jal compressed_instructions_disabled
    RVTEST_GOTO_MMODE

TEST_SMODE_UBE:
    jal enable_mstatus_ube
    RVTEST_GOTO_LOWER_MODE Umode
    jal basic_instructions_enabled
    RVTEST_GOTO_MMODE
    jal disable_mstatus_ube                                                //Disable mstatush.MBE
    RVTEST_GOTO_LOWER_MODE Umode
    jal basic_instructions_disabled
    RVTEST_GOTO_MMODE
    jal enable_mstatus_ube
    RVTEST_GOTO_LOWER_MODE Umode
    jal compressed_instructions_enabled
    RVTEST_GOTO_MMODE
    jal disable_mstatus_ube                                                //Disable mstatush.MBE
    RVTEST_GOTO_LOWER_MODE Umode
    jal compressed_instructions_disabled
    RVTEST_GOTO_MMODE

    j exit

enable_mstatush_mbe:
    // Enable mstatush MBE bit to verify loads and stores in M-Mode.
    li t0, MSTATUSH_MBE
    csrs mstatush, t0
    csrr t1, mstatush                                                            //read back to make sure it has written the correct value.
    RVTEST_SIGUPD(x3, t1)
    ret

enable_mstatush_sbe:
    li t0, MSTATUSH_SBE
    csrs mstatush, t0
    csrr t1, mstatush                                                            //read back to make sure it has written the correct value.
    RVTEST_SIGUPD(x3, t1)
    ret

disable_mstatush_sbe:
    li t0, MSTATUSH_SBE
    csrc mstatush, t0
    csrr t1, mstatush                                                            //read back to make sure it has written the correct value.
    RVTEST_SIGUPD(x3, t1)
    ret

enable_mstatus_ube:
    li t0, MSTATUS_UBE
    csrs mstatus, t0
    csrr t1, mstatus                                                             //read back to make sure it has written the correct value.
    RVTEST_SIGUPD(x3, t1)
    ret

disable_mstatus_ube:
    li t0, MSTATUS_UBE
    csrc mstatus, t0
    csrr t1, mstatus                                                             //read back to make sure it has written the correct value.
    RVTEST_SIGUPD(x3, t1)
    ret

disable_mstatush_mbe:
    // Disable mstatush MBE bit to verify loads and stores in M-Mode.
    li t0, MSTATUSH_MBE
    csrc mstatush, t0
    csrr t1, mstatush                                                            //read back to make sure it has written the correct value.
    RVTEST_SIGUPD(x3, t1)
    ret


basic_instructions_enabled:
    LI(t0, TEST_DATA)
    LA(t1, rvtest_data)

    //Stores
    sb t0, 0(t1)
    sh t0, 4(t1)
    sw t0, 8(t1)

    //Loads with mstatus.MBE enabled
    lb t0, 8(t1)                                                            //Load a byte from where a complete word is stored
    RVTEST_SIGUPD(x3, t0)
    lh t0, 8(t1)
    RVTEST_SIGUPD(x3, t0)
    lw t0, 8(t1)
    RVTEST_SIGUPD(x3, t0)
    lbu t0, 8(t1)                                                            //Load a byte from where a complete word is stored
    RVTEST_SIGUPD(x3, t0)
    lhu t0, 8(t1)
    RVTEST_SIGUPD(x3, t0)

    //Verification of signed loads

    LI(t0, TEST_DATA1)
    LA(t2, rvtest_data1)

    //Stores
    sb t0, 0(t2)
    sh t0, 4(t2)
    sw t0, 8(t2)

    //Loads with mstatus.MBE enabled
    lb t0, 8(t2)                                                            //Load a byte from where a complete word is stored
    RVTEST_SIGUPD(x3, t0)
    lh t0, 8(t2)
    RVTEST_SIGUPD(x3, t0)
    lw t0, 8(t2)
    RVTEST_SIGUPD(x3, t0)
    lbu t0, 8(t2)                                                            //Load a byte from where a complete word is stored
    RVTEST_SIGUPD(x3, t0)
    lhu t0, 8(t2)
    RVTEST_SIGUPD(x3, t0)

    ret

basic_instructions_disabled:
    LA(t1, rvtest_data)
    LA(t2, rvtest_data1)

    //Loads with mstatus.MBE disabled
    lb t0, 8(t1)
    RVTEST_SIGUPD(x3, t0)
    lh t0, 8(t1)
    RVTEST_SIGUPD(x3, t0)
    lw t0, 8(t1)
    RVTEST_SIGUPD(x3, t0)
    lbu t0, 8(t1)                                                            //Load a byte from where a complete word is stored
    RVTEST_SIGUPD(x3, t0)
    lhu t0, 8(t1)
    RVTEST_SIGUPD(x3, t0)

    //Verification of signed loads.

    //Loads with mstatus.MBE disabled
    lb t0, 8(t2)
    RVTEST_SIGUPD(x3, t0)
    lh t0, 8(t2)
    RVTEST_SIGUPD(x3, t0)
    lw t0, 8(t2)
    RVTEST_SIGUPD(x3, t0)
    lbu t0, 8(t2)                                                            //Load a byte from where a complete word is stored
    RVTEST_SIGUPD(x3, t0)
    lhu t0, 8(t2)
    RVTEST_SIGUPD(x3, t0)

    ret

compressed_instructions_enabled:
    LI(x9, TEST_DATA)
    LA(x8, rvtest_data)
    //Stores
    c.sw x9, 0(x8)
    //Loads with mstatus.MBE enabled
    c.lw x9, 0(x8)
    RVTEST_SIGUPD(x3, t0)

    //verification of signed loads.
    LI(x9, TEST_DATA)
    LA(x8, rvtest_data)

    //Stores
    c.sw x9, 0(x8)
    //Loads with mstatus.MBE enabled
    c.lw x9, 0(x8)
    RVTEST_SIGUPD(x3, t0)
    ret

compressed_instructions_disabled:
    LA(x8, rvtest_data)
    //Loads with mstatus.MBE disabled
    c.lw x9, 8(x8)
    RVTEST_SIGUPD(x3, t0)

    LA(x8, rvtest_data1)
    //Loads with mstatus.MBE disabled
    c.lw x9, 8(x8)
    RVTEST_SIGUPD(x3, t0)

    ret


fail:
end:
exit:
    nop
#endif
 # ---------------------------------------------------------------------------------------------
    # HALT
RVTEST_CODE_END
RVMODEL_HALT

RVTEST_DATA_BEGIN
.align 4

rvtest_data:
.word 0x00000000
.word 0x00000000
.word 0x00000000
rvtest_data1:
.word 0x00000000
.word 0x00000000
.word 0x00000000
RVTEST_DATA_END


RVMODEL_DATA_BEGIN
rvtest_sig_begin:
sig_begin_canary:
CANARY;
signature_x3_1:
    .fill 128*(XLEN/32),4,0xdeadbeef

#ifdef rvtest_mtrap_routine

tsig_begin_canary:
CANARY;
mtrap_sigptr:
    .fill 64*(XLEN/32),4,0xdeadbeef
tsig_end_canary:
CANARY;

#endif

#ifdef rvtest_gpr_save

gpr_save:
    .fill 32*(XLEN/32),4,0xdeadbeef

#endif

sig_end_canary:
CANARY;
rvtest_sig_end:
RVMODEL_DATA_END
