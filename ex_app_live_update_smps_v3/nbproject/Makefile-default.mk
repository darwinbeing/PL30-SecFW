#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=mkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=elf
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/ex_app_live_update_smps_v3.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/ex_app_live_update_smps_v3.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

ifeq ($(COMPARE_BUILD), true)
COMPARISON_BUILD=-mafrlcsj
else
COMPARISON_BUILD=
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=./src/init.c ./src/isr.c ./src/lcd.c src/smps_3p3z_dspic.s src/init_Alt_W_Registers.S ezbl_uart_dual_partition.c i2c.c main.c src/compensator_isr.S

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/src/init.o ${OBJECTDIR}/src/isr.o ${OBJECTDIR}/src/lcd.o ${OBJECTDIR}/src/smps_3p3z_dspic.o ${OBJECTDIR}/src/init_Alt_W_Registers.o ${OBJECTDIR}/ezbl_uart_dual_partition.o ${OBJECTDIR}/i2c.o ${OBJECTDIR}/main.o ${OBJECTDIR}/src/compensator_isr.o
POSSIBLE_DEPFILES=${OBJECTDIR}/src/init.o.d ${OBJECTDIR}/src/isr.o.d ${OBJECTDIR}/src/lcd.o.d ${OBJECTDIR}/src/smps_3p3z_dspic.o.d ${OBJECTDIR}/src/init_Alt_W_Registers.o.d ${OBJECTDIR}/ezbl_uart_dual_partition.o.d ${OBJECTDIR}/i2c.o.d ${OBJECTDIR}/main.o.d ${OBJECTDIR}/src/compensator_isr.o.d

# Object Files
OBJECTFILES=${OBJECTDIR}/src/init.o ${OBJECTDIR}/src/isr.o ${OBJECTDIR}/src/lcd.o ${OBJECTDIR}/src/smps_3p3z_dspic.o ${OBJECTDIR}/src/init_Alt_W_Registers.o ${OBJECTDIR}/ezbl_uart_dual_partition.o ${OBJECTDIR}/i2c.o ${OBJECTDIR}/main.o ${OBJECTDIR}/src/compensator_isr.o

# Source Files
SOURCEFILES=./src/init.c ./src/isr.c ./src/lcd.c src/smps_3p3z_dspic.s src/init_Alt_W_Registers.S ezbl_uart_dual_partition.c i2c.c main.c src/compensator_isr.S



CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
ifneq ($(INFORMATION_MESSAGE), )
	@echo $(INFORMATION_MESSAGE)
endif
	${MAKE}  -f nbproject/Makefile-default.mk ${DISTDIR}/ex_app_live_update_smps_v3.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=33FJ64GS606
MP_LINKER_FILE_OPTION=,--script=p33FJ64GS606.gld
# ------------------------------------------------------------------------------------
# Rules for buildStep: compile
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/src/init.o: ./src/init.c  .generated_files/flags/default/7c3f0188c0e05e12588987fb29c88f7cd8c793d3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/init.o.d 
	@${RM} ${OBJECTDIR}/src/init.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ./src/init.c  -o ${OBJECTDIR}/src/init.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/src/init.o.d"      -g -D__DEBUG     -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/src/isr.o: ./src/isr.c  .generated_files/flags/default/e6dde7ff5e29a1c7c435e5acc9eb252851daf782 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/isr.o.d 
	@${RM} ${OBJECTDIR}/src/isr.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ./src/isr.c  -o ${OBJECTDIR}/src/isr.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/src/isr.o.d"      -g -D__DEBUG     -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/src/lcd.o: ./src/lcd.c  .generated_files/flags/default/488bf457b853a7349d80fa254fe27e8a8fa871db .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/lcd.o.d 
	@${RM} ${OBJECTDIR}/src/lcd.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ./src/lcd.c  -o ${OBJECTDIR}/src/lcd.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/src/lcd.o.d"      -g -D__DEBUG     -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/ezbl_uart_dual_partition.o: ezbl_uart_dual_partition.c  .generated_files/flags/default/68e271e48c96b0259bfe9178ad2c7d354a277401 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/ezbl_uart_dual_partition.o.d 
	@${RM} ${OBJECTDIR}/ezbl_uart_dual_partition.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ezbl_uart_dual_partition.c  -o ${OBJECTDIR}/ezbl_uart_dual_partition.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/ezbl_uart_dual_partition.o.d"      -g -D__DEBUG     -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/i2c.o: i2c.c  .generated_files/flags/default/ffb75f8885d0e8f0aa47225d3f06a2663ac1fca .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/i2c.o.d 
	@${RM} ${OBJECTDIR}/i2c.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  i2c.c  -o ${OBJECTDIR}/i2c.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/i2c.o.d"      -g -D__DEBUG     -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/main.o: main.c  .generated_files/flags/default/85fa8b198782d64a1cfb9cc039b0108ff5c61160 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/main.o.d 
	@${RM} ${OBJECTDIR}/main.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  main.c  -o ${OBJECTDIR}/main.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/main.o.d"      -g -D__DEBUG     -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
else
${OBJECTDIR}/src/init.o: ./src/init.c  .generated_files/flags/default/697b6618015a0db40d3e295e074457a4860b8115 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/init.o.d 
	@${RM} ${OBJECTDIR}/src/init.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ./src/init.c  -o ${OBJECTDIR}/src/init.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/src/init.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/src/isr.o: ./src/isr.c  .generated_files/flags/default/c0258ec8b9f7da511e569e71cc1516922199c659 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/isr.o.d 
	@${RM} ${OBJECTDIR}/src/isr.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ./src/isr.c  -o ${OBJECTDIR}/src/isr.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/src/isr.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/src/lcd.o: ./src/lcd.c  .generated_files/flags/default/da2c2a51eed4d24545cec5a9ff6c82c45b441328 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/lcd.o.d 
	@${RM} ${OBJECTDIR}/src/lcd.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ./src/lcd.c  -o ${OBJECTDIR}/src/lcd.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/src/lcd.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/ezbl_uart_dual_partition.o: ezbl_uart_dual_partition.c  .generated_files/flags/default/8b2bba2eb028f97308a537d787be8dea5646b1f5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/ezbl_uart_dual_partition.o.d 
	@${RM} ${OBJECTDIR}/ezbl_uart_dual_partition.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ezbl_uart_dual_partition.c  -o ${OBJECTDIR}/ezbl_uart_dual_partition.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/ezbl_uart_dual_partition.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/i2c.o: i2c.c  .generated_files/flags/default/446f96fc61aa61b8090046d944952a22b5eb40b8 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/i2c.o.d 
	@${RM} ${OBJECTDIR}/i2c.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  i2c.c  -o ${OBJECTDIR}/i2c.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/i2c.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/main.o: main.c  .generated_files/flags/default/fd9310823444bcf1e1e7e6cf9a4c2a4dae8577ba .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/main.o.d 
	@${RM} ${OBJECTDIR}/main.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  main.c  -o ${OBJECTDIR}/main.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/main.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  --partition 1 -ffunction-sections -fdata-sections -O1 -I"h" -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/src/smps_3p3z_dspic.o: src/smps_3p3z_dspic.s  .generated_files/flags/default/c4d4112b3f6297bf11b3844ef91d7d274df7e0b3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/smps_3p3z_dspic.o.d 
	@${RM} ${OBJECTDIR}/src/smps_3p3z_dspic.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  src/smps_3p3z_dspic.s  -o ${OBJECTDIR}/src/smps_3p3z_dspic.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -D__DEBUG   -omf=elf -DXPRJ_default=$(CND_CONF)    --partition 1 -Wa,-MD,"${OBJECTDIR}/src/smps_3p3z_dspic.o.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,,-g,--no-relax$(MP_EXTRA_AS_POST)  -mdfp="${DFP_DIR}/xc16"
	
else
${OBJECTDIR}/src/smps_3p3z_dspic.o: src/smps_3p3z_dspic.s  .generated_files/flags/default/b5fa75382c97a612cebf193840e64add6048c344 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/smps_3p3z_dspic.o.d 
	@${RM} ${OBJECTDIR}/src/smps_3p3z_dspic.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  src/smps_3p3z_dspic.s  -o ${OBJECTDIR}/src/smps_3p3z_dspic.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -omf=elf -DXPRJ_default=$(CND_CONF)    --partition 1 -Wa,-MD,"${OBJECTDIR}/src/smps_3p3z_dspic.o.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax$(MP_EXTRA_AS_POST)  -mdfp="${DFP_DIR}/xc16"
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assemblePreproc
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/src/init_Alt_W_Registers.o: src/init_Alt_W_Registers.S  .generated_files/flags/default/59da91ff3865a04d35401ef76937efcc37e0480a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/init_Alt_W_Registers.o.d 
	@${RM} ${OBJECTDIR}/src/init_Alt_W_Registers.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  src/init_Alt_W_Registers.S  -o ${OBJECTDIR}/src/init_Alt_W_Registers.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/src/init_Alt_W_Registers.o.d"  -D__DEBUG   -omf=elf -DXPRJ_default=$(CND_CONF)    --partition 1 -Wa,-MD,"${OBJECTDIR}/src/init_Alt_W_Registers.o.asm.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,,-g,--no-relax$(MP_EXTRA_AS_POST)  -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/src/compensator_isr.o: src/compensator_isr.S  .generated_files/flags/default/841d3af889b6b324cf600c0c6e9848c921c9b165 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/compensator_isr.o.d 
	@${RM} ${OBJECTDIR}/src/compensator_isr.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  src/compensator_isr.S  -o ${OBJECTDIR}/src/compensator_isr.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/src/compensator_isr.o.d"  -D__DEBUG   -omf=elf -DXPRJ_default=$(CND_CONF)    --partition 1 -Wa,-MD,"${OBJECTDIR}/src/compensator_isr.o.asm.d",--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,,-g,--no-relax$(MP_EXTRA_AS_POST)  -mdfp="${DFP_DIR}/xc16"
	
else
${OBJECTDIR}/src/init_Alt_W_Registers.o: src/init_Alt_W_Registers.S  .generated_files/flags/default/bfc06ecc444b45c6f4ba43b15d2d69a283a6c409 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/init_Alt_W_Registers.o.d 
	@${RM} ${OBJECTDIR}/src/init_Alt_W_Registers.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  src/init_Alt_W_Registers.S  -o ${OBJECTDIR}/src/init_Alt_W_Registers.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/src/init_Alt_W_Registers.o.d"  -omf=elf -DXPRJ_default=$(CND_CONF)    --partition 1 -Wa,-MD,"${OBJECTDIR}/src/init_Alt_W_Registers.o.asm.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax$(MP_EXTRA_AS_POST)  -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/src/compensator_isr.o: src/compensator_isr.S  .generated_files/flags/default/f4eb7faa357ff3fb2830ce25669ccc1ae60dd42e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src" 
	@${RM} ${OBJECTDIR}/src/compensator_isr.o.d 
	@${RM} ${OBJECTDIR}/src/compensator_isr.o 
	${MP_CC} $(MP_EXTRA_AS_PRE)  src/compensator_isr.S  -o ${OBJECTDIR}/src/compensator_isr.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/src/compensator_isr.o.d"  -omf=elf -DXPRJ_default=$(CND_CONF)    --partition 1 -Wa,-MD,"${OBJECTDIR}/src/compensator_isr.o.asm.d",--defsym=__MPLAB_BUILD=1,-g,--no-relax$(MP_EXTRA_AS_POST)  -mdfp="${DFP_DIR}/xc16"
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${DISTDIR}/ex_app_live_update_smps_v3.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk  ezbl_integration/ezbl_lib.a  
	@${MKDIR} ${DISTDIR} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -o ${DISTDIR}/ex_app_live_update_smps_v3.${IMAGE_TYPE}.${OUTPUT_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}    ezbl_integration/ezbl_lib.a  -mcpu=$(MP_PROCESSOR_OPTION)        -D__DEBUG=__DEBUG   -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)      -Wl,,--partition,1,,--defsym=__MPLAB_BUILD=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,-D__DEBUG=__DEBUG,,$(MP_LINKER_FILE_OPTION),--stack=16,--check-sections,--data-init,--pack-data,--handles,--isr,--gc-sections,--stackguard=16,--no-force-link,--smart-io,-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--report-mem,--memorysummary,${DISTDIR}/memoryfile.xml$(MP_EXTRA_LD_POST)  -mdfp="${DFP_DIR}/xc16" 
	
else
${DISTDIR}/ex_app_live_update_smps_v3.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk  ezbl_integration/ezbl_lib.a 
	@${MKDIR} ${DISTDIR} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -o ${DISTDIR}/ex_app_live_update_smps_v3.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}    ezbl_integration/ezbl_lib.a  -mcpu=$(MP_PROCESSOR_OPTION)        -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wl,,--partition,1,,--defsym=__MPLAB_BUILD=1,$(MP_LINKER_FILE_OPTION),--stack=16,--check-sections,--data-init,--pack-data,--handles,--isr,--gc-sections,--stackguard=16,--no-force-link,--smart-io,-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--report-mem,--memorysummary,${DISTDIR}/memoryfile.xml$(MP_EXTRA_LD_POST)  -mdfp="${DFP_DIR}/xc16" 
	${MP_CC_DIR}/xc16-bin2hex ${DISTDIR}/ex_app_live_update_smps_v3.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX} -a  -omf=elf   -mdfp="${DFP_DIR}/xc16" 
	
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r ${OBJECTDIR}
	${RM} -r ${DISTDIR}

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(wildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
