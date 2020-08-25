/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0xfbc00daa */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "/home/us1/github/PU-MSP430/bench/verilog/baremetal/ram_sp.sv";
static int ng1[] = {2, 0};
static unsigned int ng2[] = {0U, 0U};
static unsigned int ng3[] = {1U, 0U};
static unsigned int ng4[] = {2U, 0U};



static void NetDecl_64_0(char *t0)
{
    char t5[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    unsigned int t18;
    unsigned int t19;
    char *t20;
    unsigned int t21;
    unsigned int t22;
    char *t23;
    unsigned int t24;
    unsigned int t25;
    char *t26;

LAB0:    t1 = (t0 + 3752U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(64, ng0);
    t2 = (t0 + 2680);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t6 = (t0 + 2680);
    t7 = (t6 + 72U);
    t8 = *((char **)t7);
    t9 = (t0 + 2680);
    t10 = (t9 + 64U);
    t11 = *((char **)t10);
    t12 = (t0 + 1480U);
    t13 = *((char **)t12);
    xsi_vlog_generic_get_array_select_value(t5, 16, t4, t8, t11, 2, 1, t13, 10, 2);
    t12 = (t0 + 4680);
    t14 = (t12 + 56U);
    t15 = *((char **)t14);
    t16 = (t15 + 56U);
    t17 = *((char **)t16);
    memset(t17, 0, 8);
    t18 = 65535U;
    t19 = t18;
    t20 = (t5 + 4);
    t21 = *((unsigned int *)t5);
    t18 = (t18 & t21);
    t22 = *((unsigned int *)t20);
    t19 = (t19 & t22);
    t23 = (t17 + 4);
    t24 = *((unsigned int *)t17);
    *((unsigned int *)t17) = (t24 | t18);
    t25 = *((unsigned int *)t23);
    *((unsigned int *)t23) = (t25 | t19);
    xsi_driver_vfirst_trans(t12, 0, 15U);
    t26 = (t0 + 4568);
    *((int *)t26) = 1;

LAB1:    return;
}

static void Always_66_1(char *t0)
{
    char t4[8];
    char t23[8];
    char t38[8];
    char t39[8];
    char t43[8];
    char t51[8];
    char t91[8];
    char t115[8];
    char t116[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    char *t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    char *t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    char *t30;
    char *t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    char *t35;
    char *t36;
    char *t37;
    char *t40;
    char *t41;
    char *t42;
    char *t44;
    unsigned int t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    char *t50;
    unsigned int t52;
    unsigned int t53;
    unsigned int t54;
    char *t55;
    char *t56;
    char *t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    unsigned int t63;
    unsigned int t64;
    char *t65;
    char *t66;
    unsigned int t67;
    unsigned int t68;
    unsigned int t69;
    unsigned int t70;
    unsigned int t71;
    unsigned int t72;
    unsigned int t73;
    unsigned int t74;
    int t75;
    int t76;
    unsigned int t77;
    unsigned int t78;
    unsigned int t79;
    unsigned int t80;
    unsigned int t81;
    unsigned int t82;
    char *t83;
    unsigned int t84;
    unsigned int t85;
    unsigned int t86;
    unsigned int t87;
    unsigned int t88;
    char *t89;
    char *t90;
    char *t92;
    char *t93;
    unsigned int t94;
    unsigned int t95;
    unsigned int t96;
    unsigned int t97;
    unsigned int t98;
    unsigned int t99;
    unsigned int t100;
    unsigned int t101;
    unsigned int t102;
    unsigned int t103;
    unsigned int t104;
    unsigned int t105;
    char *t106;
    char *t107;
    unsigned int t108;
    unsigned int t109;
    unsigned int t110;
    unsigned int t111;
    unsigned int t112;
    char *t113;
    char *t114;
    char *t117;
    char *t118;
    char *t119;
    char *t120;
    char *t121;
    char *t122;
    char *t123;
    char *t124;
    unsigned int t125;
    int t126;
    char *t127;
    unsigned int t128;
    int t129;
    int t130;
    unsigned int t131;
    unsigned int t132;
    int t133;
    int t134;

LAB0:    t1 = (t0 + 4000U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(66, ng0);
    t2 = (t0 + 4584);
    *((int *)t2) = 1;
    t3 = (t0 + 4032);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(66, ng0);

LAB5:    xsi_set_current_line(67, ng0);
    t5 = (t0 + 1640U);
    t6 = *((char **)t5);
    memset(t4, 0, 8);
    t5 = (t6 + 4);
    t7 = *((unsigned int *)t5);
    t8 = (~(t7));
    t9 = *((unsigned int *)t6);
    t10 = (t9 & t8);
    t11 = (t10 & 1U);
    if (t11 != 0)
        goto LAB9;

LAB7:    if (*((unsigned int *)t5) == 0)
        goto LAB6;

LAB8:    t12 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t12) = 1;

LAB9:    t13 = (t4 + 4);
    t14 = (t6 + 4);
    t15 = *((unsigned int *)t6);
    t16 = (~(t15));
    *((unsigned int *)t4) = t16;
    *((unsigned int *)t13) = 0;
    if (*((unsigned int *)t14) != 0)
        goto LAB11;

LAB10:    t21 = *((unsigned int *)t4);
    *((unsigned int *)t4) = (t21 & 1U);
    t22 = *((unsigned int *)t13);
    *((unsigned int *)t13) = (t22 & 1U);
    memset(t23, 0, 8);
    t24 = (t4 + 4);
    t25 = *((unsigned int *)t24);
    t26 = (~(t25));
    t27 = *((unsigned int *)t4);
    t28 = (t27 & t26);
    t29 = (t28 & 1U);
    if (t29 != 0)
        goto LAB12;

LAB13:    if (*((unsigned int *)t24) != 0)
        goto LAB14;

LAB15:    t31 = (t23 + 4);
    t32 = *((unsigned int *)t23);
    t33 = *((unsigned int *)t31);
    t34 = (t32 || t33);
    if (t34 > 0)
        goto LAB16;

LAB17:    memcpy(t51, t23, 8);

LAB18:    t83 = (t51 + 4);
    t84 = *((unsigned int *)t83);
    t85 = (~(t84));
    t86 = *((unsigned int *)t51);
    t87 = (t86 & t85);
    t88 = (t87 != 0);
    if (t88 > 0)
        goto LAB31;

LAB32:
LAB33:    goto LAB2;

LAB6:    *((unsigned int *)t4) = 1;
    goto LAB9;

LAB11:    t17 = *((unsigned int *)t4);
    t18 = *((unsigned int *)t14);
    *((unsigned int *)t4) = (t17 | t18);
    t19 = *((unsigned int *)t13);
    t20 = *((unsigned int *)t14);
    *((unsigned int *)t13) = (t19 | t20);
    goto LAB10;

LAB12:    *((unsigned int *)t23) = 1;
    goto LAB15;

LAB14:    t30 = (t23 + 4);
    *((unsigned int *)t23) = 1;
    *((unsigned int *)t30) = 1;
    goto LAB15;

LAB16:    t35 = (t0 + 1480U);
    t36 = *((char **)t35);
    t35 = (t0 + 608);
    t37 = *((char **)t35);
    t35 = ((char*)((ng1)));
    memset(t38, 0, 8);
    xsi_vlog_unsigned_divide(t38, 32, t37, 32, t35, 32);
    memset(t39, 0, 8);
    t40 = (t36 + 4);
    if (*((unsigned int *)t40) != 0)
        goto LAB20;

LAB19:    t41 = (t38 + 4);
    if (*((unsigned int *)t41) != 0)
        goto LAB20;

LAB23:    if (*((unsigned int *)t36) < *((unsigned int *)t38))
        goto LAB21;

LAB22:    memset(t43, 0, 8);
    t44 = (t39 + 4);
    t45 = *((unsigned int *)t44);
    t46 = (~(t45));
    t47 = *((unsigned int *)t39);
    t48 = (t47 & t46);
    t49 = (t48 & 1U);
    if (t49 != 0)
        goto LAB24;

LAB25:    if (*((unsigned int *)t44) != 0)
        goto LAB26;

LAB27:    t52 = *((unsigned int *)t23);
    t53 = *((unsigned int *)t43);
    t54 = (t52 & t53);
    *((unsigned int *)t51) = t54;
    t55 = (t23 + 4);
    t56 = (t43 + 4);
    t57 = (t51 + 4);
    t58 = *((unsigned int *)t55);
    t59 = *((unsigned int *)t56);
    t60 = (t58 | t59);
    *((unsigned int *)t57) = t60;
    t61 = *((unsigned int *)t57);
    t62 = (t61 != 0);
    if (t62 == 1)
        goto LAB28;

LAB29:
LAB30:    goto LAB18;

LAB20:    t42 = (t39 + 4);
    *((unsigned int *)t39) = 1;
    *((unsigned int *)t42) = 1;
    goto LAB22;

LAB21:    *((unsigned int *)t39) = 1;
    goto LAB22;

LAB24:    *((unsigned int *)t43) = 1;
    goto LAB27;

LAB26:    t50 = (t43 + 4);
    *((unsigned int *)t43) = 1;
    *((unsigned int *)t50) = 1;
    goto LAB27;

LAB28:    t63 = *((unsigned int *)t51);
    t64 = *((unsigned int *)t57);
    *((unsigned int *)t51) = (t63 | t64);
    t65 = (t23 + 4);
    t66 = (t43 + 4);
    t67 = *((unsigned int *)t23);
    t68 = (~(t67));
    t69 = *((unsigned int *)t65);
    t70 = (~(t69));
    t71 = *((unsigned int *)t43);
    t72 = (~(t71));
    t73 = *((unsigned int *)t66);
    t74 = (~(t73));
    t75 = (t68 & t70);
    t76 = (t72 & t74);
    t77 = (~(t75));
    t78 = (~(t76));
    t79 = *((unsigned int *)t57);
    *((unsigned int *)t57) = (t79 & t77);
    t80 = *((unsigned int *)t57);
    *((unsigned int *)t57) = (t80 & t78);
    t81 = *((unsigned int *)t51);
    *((unsigned int *)t51) = (t81 & t77);
    t82 = *((unsigned int *)t51);
    *((unsigned int *)t51) = (t82 & t78);
    goto LAB30;

LAB31:    xsi_set_current_line(67, ng0);

LAB34:    xsi_set_current_line(68, ng0);
    t89 = (t0 + 2120U);
    t90 = *((char **)t89);
    t89 = ((char*)((ng2)));
    memset(t91, 0, 8);
    t92 = (t90 + 4);
    t93 = (t89 + 4);
    t94 = *((unsigned int *)t90);
    t95 = *((unsigned int *)t89);
    t96 = (t94 ^ t95);
    t97 = *((unsigned int *)t92);
    t98 = *((unsigned int *)t93);
    t99 = (t97 ^ t98);
    t100 = (t96 | t99);
    t101 = *((unsigned int *)t92);
    t102 = *((unsigned int *)t93);
    t103 = (t101 | t102);
    t104 = (~(t103));
    t105 = (t100 & t104);
    if (t105 != 0)
        goto LAB38;

LAB35:    if (t103 != 0)
        goto LAB37;

LAB36:    *((unsigned int *)t91) = 1;

LAB38:    t107 = (t91 + 4);
    t108 = *((unsigned int *)t107);
    t109 = (~(t108));
    t110 = *((unsigned int *)t91);
    t111 = (t110 & t109);
    t112 = (t111 != 0);
    if (t112 > 0)
        goto LAB39;

LAB40:    xsi_set_current_line(69, ng0);
    t2 = (t0 + 2120U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng3)));
    memset(t4, 0, 8);
    t5 = (t3 + 4);
    t6 = (t2 + 4);
    t7 = *((unsigned int *)t3);
    t8 = *((unsigned int *)t2);
    t9 = (t7 ^ t8);
    t10 = *((unsigned int *)t5);
    t11 = *((unsigned int *)t6);
    t15 = (t10 ^ t11);
    t16 = (t9 | t15);
    t17 = *((unsigned int *)t5);
    t18 = *((unsigned int *)t6);
    t19 = (t17 | t18);
    t20 = (~(t19));
    t21 = (t16 & t20);
    if (t21 != 0)
        goto LAB47;

LAB44:    if (t19 != 0)
        goto LAB46;

LAB45:    *((unsigned int *)t4) = 1;

LAB47:    t13 = (t4 + 4);
    t22 = *((unsigned int *)t13);
    t25 = (~(t22));
    t26 = *((unsigned int *)t4);
    t27 = (t26 & t25);
    t28 = (t27 != 0);
    if (t28 > 0)
        goto LAB48;

LAB49:    xsi_set_current_line(70, ng0);
    t2 = (t0 + 2120U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng4)));
    memset(t4, 0, 8);
    t5 = (t3 + 4);
    t6 = (t2 + 4);
    t7 = *((unsigned int *)t3);
    t8 = *((unsigned int *)t2);
    t9 = (t7 ^ t8);
    t10 = *((unsigned int *)t5);
    t11 = *((unsigned int *)t6);
    t15 = (t10 ^ t11);
    t16 = (t9 | t15);
    t17 = *((unsigned int *)t5);
    t18 = *((unsigned int *)t6);
    t19 = (t17 | t18);
    t20 = (~(t19));
    t21 = (t16 & t20);
    if (t21 != 0)
        goto LAB56;

LAB53:    if (t19 != 0)
        goto LAB55;

LAB54:    *((unsigned int *)t4) = 1;

LAB56:    t13 = (t4 + 4);
    t22 = *((unsigned int *)t13);
    t25 = (~(t22));
    t26 = *((unsigned int *)t4);
    t27 = (t26 & t25);
    t28 = (t27 != 0);
    if (t28 > 0)
        goto LAB57;

LAB58:
LAB59:
LAB50:
LAB41:    xsi_set_current_line(71, ng0);
    t2 = (t0 + 1480U);
    t3 = *((char **)t2);
    t2 = (t0 + 2840);
    xsi_vlogvar_wait_assign_value(t2, t3, 0, 0, 10, 0LL);
    goto LAB33;

LAB37:    t106 = (t91 + 4);
    *((unsigned int *)t91) = 1;
    *((unsigned int *)t106) = 1;
    goto LAB38;

LAB39:    xsi_set_current_line(68, ng0);
    t113 = (t0 + 1960U);
    t114 = *((char **)t113);
    t113 = (t0 + 2680);
    t117 = (t0 + 2680);
    t118 = (t117 + 72U);
    t119 = *((char **)t118);
    t120 = (t0 + 2680);
    t121 = (t120 + 64U);
    t122 = *((char **)t121);
    t123 = (t0 + 1480U);
    t124 = *((char **)t123);
    xsi_vlog_generic_convert_array_indices(t115, t116, t119, t122, 2, 1, t124, 10, 2);
    t123 = (t115 + 4);
    t125 = *((unsigned int *)t123);
    t126 = (!(t125));
    t127 = (t116 + 4);
    t128 = *((unsigned int *)t127);
    t129 = (!(t128));
    t130 = (t126 && t129);
    if (t130 == 1)
        goto LAB42;

LAB43:    goto LAB41;

LAB42:    t131 = *((unsigned int *)t115);
    t132 = *((unsigned int *)t116);
    t133 = (t131 - t132);
    t134 = (t133 + 1);
    xsi_vlogvar_wait_assign_value(t113, t114, 0, *((unsigned int *)t116), t134, 0LL);
    goto LAB43;

LAB46:    t12 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t12) = 1;
    goto LAB47;

LAB48:    xsi_set_current_line(69, ng0);
    t14 = (t0 + 2280U);
    t24 = *((char **)t14);
    memset(t38, 0, 8);
    t14 = (t38 + 4);
    t30 = (t24 + 4);
    t29 = *((unsigned int *)t24);
    t32 = (t29 >> 0);
    *((unsigned int *)t38) = t32;
    t33 = *((unsigned int *)t30);
    t34 = (t33 >> 0);
    *((unsigned int *)t14) = t34;
    t45 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t45 & 255U);
    t46 = *((unsigned int *)t14);
    *((unsigned int *)t14) = (t46 & 255U);
    t31 = (t0 + 1960U);
    t35 = *((char **)t31);
    memset(t39, 0, 8);
    t31 = (t39 + 4);
    t36 = (t35 + 4);
    t47 = *((unsigned int *)t35);
    t48 = (t47 >> 8);
    *((unsigned int *)t39) = t48;
    t49 = *((unsigned int *)t36);
    t52 = (t49 >> 8);
    *((unsigned int *)t31) = t52;
    t53 = *((unsigned int *)t39);
    *((unsigned int *)t39) = (t53 & 255U);
    t54 = *((unsigned int *)t31);
    *((unsigned int *)t31) = (t54 & 255U);
    xsi_vlogtype_concat(t23, 16, 16, 2U, t39, 8, t38, 8);
    t37 = (t0 + 2680);
    t40 = (t0 + 2680);
    t41 = (t40 + 72U);
    t42 = *((char **)t41);
    t44 = (t0 + 2680);
    t50 = (t44 + 64U);
    t55 = *((char **)t50);
    t56 = (t0 + 1480U);
    t57 = *((char **)t56);
    xsi_vlog_generic_convert_array_indices(t43, t51, t42, t55, 2, 1, t57, 10, 2);
    t56 = (t43 + 4);
    t58 = *((unsigned int *)t56);
    t75 = (!(t58));
    t65 = (t51 + 4);
    t59 = *((unsigned int *)t65);
    t76 = (!(t59));
    t126 = (t75 && t76);
    if (t126 == 1)
        goto LAB51;

LAB52:    goto LAB50;

LAB51:    t60 = *((unsigned int *)t43);
    t61 = *((unsigned int *)t51);
    t129 = (t60 - t61);
    t130 = (t129 + 1);
    xsi_vlogvar_wait_assign_value(t37, t23, 0, *((unsigned int *)t51), t130, 0LL);
    goto LAB52;

LAB55:    t12 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t12) = 1;
    goto LAB56;

LAB57:    xsi_set_current_line(70, ng0);
    t14 = (t0 + 1960U);
    t24 = *((char **)t14);
    memset(t38, 0, 8);
    t14 = (t38 + 4);
    t30 = (t24 + 4);
    t29 = *((unsigned int *)t24);
    t32 = (t29 >> 0);
    *((unsigned int *)t38) = t32;
    t33 = *((unsigned int *)t30);
    t34 = (t33 >> 0);
    *((unsigned int *)t14) = t34;
    t45 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t45 & 255U);
    t46 = *((unsigned int *)t14);
    *((unsigned int *)t14) = (t46 & 255U);
    t31 = (t0 + 2280U);
    t35 = *((char **)t31);
    memset(t39, 0, 8);
    t31 = (t39 + 4);
    t36 = (t35 + 4);
    t47 = *((unsigned int *)t35);
    t48 = (t47 >> 8);
    *((unsigned int *)t39) = t48;
    t49 = *((unsigned int *)t36);
    t52 = (t49 >> 8);
    *((unsigned int *)t31) = t52;
    t53 = *((unsigned int *)t39);
    *((unsigned int *)t39) = (t53 & 255U);
    t54 = *((unsigned int *)t31);
    *((unsigned int *)t31) = (t54 & 255U);
    xsi_vlogtype_concat(t23, 16, 16, 2U, t39, 8, t38, 8);
    t37 = (t0 + 2680);
    t40 = (t0 + 2680);
    t41 = (t40 + 72U);
    t42 = *((char **)t41);
    t44 = (t0 + 2680);
    t50 = (t44 + 64U);
    t55 = *((char **)t50);
    t56 = (t0 + 1480U);
    t57 = *((char **)t56);
    xsi_vlog_generic_convert_array_indices(t43, t51, t42, t55, 2, 1, t57, 10, 2);
    t56 = (t43 + 4);
    t58 = *((unsigned int *)t56);
    t75 = (!(t58));
    t65 = (t51 + 4);
    t59 = *((unsigned int *)t65);
    t76 = (!(t59));
    t126 = (t75 && t76);
    if (t126 == 1)
        goto LAB60;

LAB61:    goto LAB59;

LAB60:    t60 = *((unsigned int *)t43);
    t61 = *((unsigned int *)t51);
    t129 = (t60 - t61);
    t130 = (t129 + 1);
    xsi_vlogvar_wait_assign_value(t37, t23, 0, *((unsigned int *)t51), t130, 0LL);
    goto LAB61;

}

static void Cont_75_2(char *t0)
{
    char t5[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    unsigned int t20;
    unsigned int t21;
    char *t22;
    unsigned int t23;
    unsigned int t24;
    char *t25;
    unsigned int t26;
    unsigned int t27;
    char *t28;

LAB0:    t1 = (t0 + 4248U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(75, ng0);
    t2 = (t0 + 2680);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t6 = (t0 + 2680);
    t7 = (t6 + 72U);
    t8 = *((char **)t7);
    t9 = (t0 + 2680);
    t10 = (t9 + 64U);
    t11 = *((char **)t10);
    t12 = (t0 + 2840);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    xsi_vlog_generic_get_array_select_value(t5, 16, t4, t8, t11, 2, 1, t14, 10, 2);
    t15 = (t0 + 4744);
    t16 = (t15 + 56U);
    t17 = *((char **)t16);
    t18 = (t17 + 56U);
    t19 = *((char **)t18);
    memset(t19, 0, 8);
    t20 = 65535U;
    t21 = t20;
    t22 = (t5 + 4);
    t23 = *((unsigned int *)t5);
    t20 = (t20 & t23);
    t24 = *((unsigned int *)t22);
    t21 = (t21 & t24);
    t25 = (t19 + 4);
    t26 = *((unsigned int *)t19);
    *((unsigned int *)t19) = (t26 | t20);
    t27 = *((unsigned int *)t25);
    *((unsigned int *)t25) = (t27 | t21);
    xsi_driver_vfirst_trans(t15, 0, 15);
    t28 = (t0 + 4600);
    *((int *)t28) = 1;

LAB1:    return;
}


extern void work_m_06664925723333534785_3530608706_init()
{
	static char *pe[] = {(void *)NetDecl_64_0,(void *)Always_66_1,(void *)Cont_75_2};
	xsi_register_didat("work_m_06664925723333534785_3530608706", "isim/isim.exe.sim/work/m_06664925723333534785_3530608706.didat");
	xsi_register_executes(pe);
}
