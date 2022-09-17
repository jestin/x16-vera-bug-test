NAME = MYPROG
ASSEMBLER6502 = cl65
ASFLAGS = -t cx16 -l $(NAME).list

PROG = $(NAME).PRG
LIST = $(NAME).list
MAIN = main.asm
SOURCES = $(MAIN) \
		  x16.inc \
		  vera.inc

RESOURCES = 16X162BPPT.BIN \
			16X162BPP.PAL \
			16X162BPPM.BIN \
			8X82BPPT.BIN \
			8X82BPP.PAL \
			8X82BPPM.BIN \
			16X82BPPT.BIN \
			16X82BPP.PAL \
			16X82BPPM.BIN \
			8X162BPPT.BIN \
			8X162BPP.PAL \
			8X162BPPM.BIN

resources: $(RESOURCES)

8X82BPPT.BIN: 8x82bpp.xcf
	gimp -i -d -f -b '(export-vera "8x82bpp.xcf" "8X82BPPT.BIN" 0 2 8 8 1 1 1)' -b '(gimp-quit 0)'

8X82BPPM.BIN: 8x82bpp.tmx
	tmx2vera 8x82bpp.tmx -l l0 8X82BPPM.BIN

8X82BPP.PAL: 8X82BPPT.BIN
	cp 8X82BPPT.BIN.PAL 8X82BPP.PAL


16X82BPPT.BIN: 16x82bpp.xcf
	gimp -i -d -f -b '(export-vera "16x82bpp.xcf" "16X82BPPT.BIN" 0 2 16 8 1 1 1)' -b '(gimp-quit 0)'

16X82BPPM.BIN: 16x82bpp.tmx
	tmx2vera 16x82bpp.tmx -l l0 16X82BPPM.BIN

16X82BPP.PAL: 16X82BPPT.BIN
	cp 16X82BPPT.BIN.PAL 16X82BPP.PAL


8X162BPPT.BIN: 8x162bpp.xcf
	gimp -i -d -f -b '(export-vera "8x162bpp.xcf" "8X162BPPT.BIN" 0 2 8 16 1 1 1)' -b '(gimp-quit 0)'

8X162BPPM.BIN: 8x162bpp.tmx
	tmx2vera 8x162bpp.tmx -l l0 8X162BPPM.BIN

8X162BPP.PAL: 8X162BPPT.BIN
	cp 8X162BPPT.BIN.PAL 8X162BPP.PAL


16X162BPPT.BIN: 16x162bpp.xcf
	gimp -i -d -f -b '(export-vera "16x162bpp.xcf" "16X162BPPT.BIN" 0 2 16 16 1 1 1)' -b '(gimp-quit 0)'

16X162BPPM.BIN: 16x162bpp.tmx
	tmx2vera 16x162bpp.tmx -l l0 16X162BPPM.BIN

16X162BPP.PAL: 16X162BPPT.BIN
	cp 16X162BPPT.BIN.PAL 16X162BPP.PAL


all: $(PROG)

$(PROG): $(SOURCES)
	$(ASSEMBLER6502) $(ASFLAGS) -o $(PROG) $(MAIN)

run: all resources
	x16emu -prg $(PROG) -run -scale 2 -debug

clean:
	rm -f $(PROG) $(LIST)
	
clean_resources:
	rm -f $(RESOURCES)

cleanall: clean clean_resources
