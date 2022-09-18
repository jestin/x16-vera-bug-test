.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"


.segment "CODE"

	jmp main

.include "x16.inc"
.include "vera.inc"

default_irq			= $8000
zp_vsync_trig		= $30

zp_mode				= $22
zp_loaded			= $23

exetbpp_tile_file: .literal "8X82BPPT.BIN"
end_exetbpp_tile_file:

exetbpp_map_file: .literal "8X82BPPM.BIN"
end_exetbpp_map_file:

exetbpp_pal_file: .literal "8X82BPP.PAL"
end_exetbpp_pal_file:


sxetbpp_tile_file: .literal "16X82BPPT.BIN"
end_sxetbpp_tile_file:

sxetbpp_map_file: .literal "16X82BPPM.BIN"
end_sxetbpp_map_file:

sxetbpp_pal_file: .literal "16X82BPP.PAL"
end_sxetbpp_pal_file:


exstbpp_tile_file: .literal "8X162BPPT.BIN"
end_exstbpp_tile_file:

exstbpp_map_file: .literal "8X162BPPM.BIN"
end_exstbpp_map_file:

exstbpp_pal_file: .literal "8X162BPP.PAL"
end_exstbpp_pal_file:


sxstbpp_tile_file: .literal "16X162BPPT.BIN"
end_sxstbpp_tile_file:

sxstbpp_map_file: .literal "16X162BPPM.BIN"
end_sxstbpp_map_file:

sxstbpp_pal_file: .literal "16X162BPP.PAL"
end_sxstbpp_pal_file:


exefbpp_tile_file: .literal "8X84BPPT.BIN"
end_exefbpp_tile_file:

exefbpp_map_file: .literal "8X84BPPM.BIN"
end_exefbpp_map_file:

exefbpp_pal_file: .literal "8X84BPP.PAL"
end_exefbpp_pal_file:


sxefbpp_tile_file: .literal "16X84BPPT.BIN"
end_sxefbpp_tile_file:

sxefbpp_map_file: .literal "16X84BPPM.BIN"
end_sxefbpp_map_file:

sxefbpp_pal_file: .literal "16X84BPP.PAL"
end_sxefbpp_pal_file:


exsfbpp_tile_file: .literal "8X164BPPT.BIN"
end_exsfbpp_tile_file:

exsfbpp_map_file: .literal "8X164BPPM.BIN"
end_exsfbpp_map_file:

exsfbpp_pal_file: .literal "8X164BPP.PAL"
end_exsfbpp_pal_file:


sxsfbpp_tile_file: .literal "16X164BPPT.BIN"
end_sxsfbpp_tile_file:

sxsfbpp_map_file: .literal "16X164BPPM.BIN"
end_sxsfbpp_map_file:

sxsfbpp_pal_file: .literal "16X164BPP.PAL"
end_sxsfbpp_pal_file:


exeebpp_tile_file: .literal "8X88BPPT.BIN"
end_exeebpp_tile_file:

exeebpp_map_file: .literal "8X88BPPM.BIN"
end_exeebpp_map_file:

exeebpp_pal_file: .literal "8X88BPP.PAL"
end_exeebpp_pal_file:


sxeebpp_tile_file: .literal "16X88BPPT.BIN"
end_sxeebpp_tile_file:

sxeebpp_map_file: .literal "16X88BPPM.BIN"
end_sxeebpp_map_file:

sxeebpp_pal_file: .literal "16X88BPP.PAL"
end_sxeebpp_pal_file:


exsebpp_tile_file: .literal "8X168BPPT.BIN"
end_exsebpp_tile_file:

exsebpp_map_file: .literal "8X168BPPM.BIN"
end_exsebpp_map_file:

exsebpp_pal_file: .literal "8X168BPP.PAL"
end_exsebpp_pal_file:


sxsebpp_tile_file: .literal "16X168BPPT.BIN"
end_sxsebpp_tile_file:

sxsebpp_map_file: .literal "16X168BPPM.BIN"
end_sxsebpp_map_file:

sxsebpp_pal_file: .literal "16X168BPP.PAL"
end_sxsebpp_pal_file:


vram_tiles = $00000
vram_l0_map = $10000
vram_pal = $1fa00

main:

	lda #0
	sta zp_mode

	stz zp_loaded

	jsr init_irq

;==================================================
; mainloop
;==================================================
mainloop:
	wai
	jsr check_vsync
	jmp mainloop  ; loop forever

	rts

;==================================================
; init_irq
; Initializes interrupt vector
;==================================================
init_irq:
	lda IRQVec
	sta default_irq
	lda IRQVec+1
	sta default_irq+1
	lda #<handle_irq
	sta IRQVec
	lda #>handle_irq
	sta IRQVec+1
	rts

;==================================================
; handle_irq
; Handles VERA IRQ
;==================================================
handle_irq:
	; check for VSYNC
	lda veraisr
	and #$01
	beq @end
	sta zp_vsync_trig
	; clear vera irq flag
	sta veraisr

@end:
	jmp (default_irq)

;==================================================
; check_vsync
;==================================================
check_vsync:
	lda zp_vsync_trig
	beq @end

	; VSYNC has occurred, handle

	jsr tick

@end:
	stz zp_vsync_trig
	rts

;==================================================
; tick
;==================================================
tick:
	lda zp_loaded
	bne @check_joy

	lda zp_mode
	cmp #0
	bne :+
	jsr load_8x8_2bpp
:
	lda zp_mode
	cmp #1
	bne :+
	jsr load_16x8_2bpp
:
	lda zp_mode
	cmp #2
	bne :+
	jsr load_8x16_2bpp
:
	lda zp_mode
	cmp #3
	bne :+
	jsr load_16x16_2bpp
:
	lda zp_mode
	cmp #4
	bne :+
	jsr load_8x8_4bpp
:
	lda zp_mode
	cmp #5
	bne :+
	jsr load_16x8_4bpp
:
	lda zp_mode
	cmp #6
	bne :+
	jsr load_8x16_4bpp
:
	lda zp_mode
	cmp #7
	bne :+
	jsr load_16x16_4bpp
:
	lda zp_mode
	cmp #8
	bne :+
	jsr load_8x8_8bpp
:
	lda zp_mode
	cmp #9
	bne :+
	jsr load_16x8_8bpp
:
	lda zp_mode
	cmp #10
	bne :+
	jsr load_8x16_8bpp
:
	lda zp_mode
	cmp #11
	bne :+
	jsr load_16x16_8bpp
:
	lda zp_mode
	cmp #12
	bne :+
	stz zp_mode
	stz zp_loaded
	jmp @return
:

	lda #1
	sta zp_loaded

@check_joy:
	; check joystick

	jsr GETIN
	; beq @return

	cmp #$30
	bne :+
	lda #0
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$31
	bne :+
	lda #1
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$32
	bne :+
	lda #2
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$33
	bne :+
	lda #3
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$34
	bne :+
	lda #4
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$35
	bne :+
	lda #5
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$36
	bne :+
	lda #6
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$37
	bne :+
	lda #7
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$38
	bne :+
	lda #8
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$39
	bne :+
	lda #9
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$41
	bne :+
	lda #10
	sta zp_mode
	stz zp_loaded
	jmp @return
:
	cmp #$42
	bne :+
	lda #11
	sta zp_mode
	stz zp_loaded
	jmp @return
:

	cmp #$20
	bne @return
	inc zp_mode
	stz zp_loaded

@return:
	rts

;==================================================
; load_8x8_2bpp
;==================================================
load_8x8_2bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000001 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 1 (2bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (0 << 1) | 0)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exetbpp_tile_file-exetbpp_tile_file)
	ldx #<exetbpp_tile_file
	ldy #>exetbpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exetbpp_map_file-exetbpp_map_file)
	ldx #<exetbpp_map_file
	ldy #>exetbpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exetbpp_pal_file-exetbpp_pal_file)
	ldx #<exetbpp_pal_file
	ldy #>exetbpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_16x8_2bpp
;==================================================
load_16x8_2bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000001 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 1 (2bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (0 << 1) | 1)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxetbpp_tile_file-sxetbpp_tile_file)
	ldx #<sxetbpp_tile_file
	ldy #>sxetbpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxetbpp_map_file-sxetbpp_map_file)
	ldx #<sxetbpp_map_file
	ldy #>sxetbpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxetbpp_pal_file-sxetbpp_pal_file)
	ldx #<sxetbpp_pal_file
	ldy #>sxetbpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_8x16_2bpp
;==================================================
load_8x16_2bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000001 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 1 (2bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (1 << 1) | 0)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exstbpp_tile_file-exstbpp_tile_file)
	ldx #<exstbpp_tile_file
	ldy #>exstbpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exstbpp_map_file-exstbpp_map_file)
	ldx #<exstbpp_map_file
	ldy #>exstbpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exstbpp_pal_file-exstbpp_pal_file)
	ldx #<exstbpp_pal_file
	ldy #>exstbpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_16x16_2bpp
;==================================================
load_16x16_2bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000001 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 1 (2bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (1 << 1) | 1)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxstbpp_tile_file-sxstbpp_tile_file)
	ldx #<sxstbpp_tile_file
	ldy #>sxstbpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxstbpp_map_file-sxstbpp_map_file)
	ldx #<sxstbpp_map_file
	ldy #>sxstbpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxstbpp_pal_file-sxstbpp_pal_file)
	ldx #<sxstbpp_pal_file
	ldy #>sxstbpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_8x8_4bpp
;==================================================
load_8x8_4bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000010 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 2 (4bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (0 << 1) | 0)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exefbpp_tile_file-exefbpp_tile_file)
	ldx #<exefbpp_tile_file
	ldy #>exefbpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exefbpp_map_file-exefbpp_map_file)
	ldx #<exefbpp_map_file
	ldy #>exefbpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exefbpp_pal_file-exefbpp_pal_file)
	ldx #<exefbpp_pal_file
	ldy #>exefbpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_16x8_4bpp
;==================================================
load_16x8_4bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000010 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 2 (4bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (0 << 1) | 1)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxefbpp_tile_file-sxefbpp_tile_file)
	ldx #<sxefbpp_tile_file
	ldy #>sxefbpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxefbpp_map_file-sxefbpp_map_file)
	ldx #<sxefbpp_map_file
	ldy #>sxefbpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxefbpp_pal_file-sxefbpp_pal_file)
	ldx #<sxefbpp_pal_file
	ldy #>sxefbpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_8x16_4bpp
;==================================================
load_8x16_4bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000010 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 2 (4bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (1 << 1) | 0)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exsfbpp_tile_file-exsfbpp_tile_file)
	ldx #<exsfbpp_tile_file
	ldy #>exsfbpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exsfbpp_map_file-exsfbpp_map_file)
	ldx #<exsfbpp_map_file
	ldy #>exsfbpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exsfbpp_pal_file-exsfbpp_pal_file)
	ldx #<exsfbpp_pal_file
	ldy #>exsfbpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_16x16_4bpp
;==================================================
load_16x16_4bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000010 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 2 (4bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (1 << 1) | 1)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxsfbpp_tile_file-sxsfbpp_tile_file)
	ldx #<sxsfbpp_tile_file
	ldy #>sxsfbpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxsfbpp_map_file-sxsfbpp_map_file)
	ldx #<sxsfbpp_map_file
	ldy #>sxsfbpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxsfbpp_pal_file-sxsfbpp_pal_file)
	ldx #<sxsfbpp_pal_file
	ldy #>sxsfbpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_8x8_8bpp
;==================================================
load_8x8_8bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000011 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (0 << 1) | 0)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exeebpp_tile_file-exeebpp_tile_file)
	ldx #<exeebpp_tile_file
	ldy #>exeebpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exeebpp_map_file-exeebpp_map_file)
	ldx #<exeebpp_map_file
	ldy #>exeebpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exeebpp_pal_file-exeebpp_pal_file)
	ldx #<exeebpp_pal_file
	ldy #>exeebpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_16x8_8bpp
;==================================================
load_16x8_8bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000011 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (0 << 1) | 1)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxeebpp_tile_file-sxeebpp_tile_file)
	ldx #<sxeebpp_tile_file
	ldy #>sxeebpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxeebpp_map_file-sxeebpp_map_file)
	ldx #<sxeebpp_map_file
	ldy #>sxeebpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxeebpp_pal_file-sxeebpp_pal_file)
	ldx #<sxeebpp_pal_file
	ldy #>sxeebpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_8x16_8bpp
;==================================================
load_8x16_8bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000011 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (1 << 1) | 0)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exsebpp_tile_file-exsebpp_tile_file)
	ldx #<exsebpp_tile_file
	ldy #>exsebpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exsebpp_map_file-exsebpp_map_file)
	ldx #<exsebpp_map_file
	ldy #>exsebpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_exsebpp_pal_file-exsebpp_pal_file)
	ldx #<exsebpp_pal_file
	ldy #>exsebpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

;==================================================
; load_16x16_8bpp
;==================================================
load_16x16_8bpp:
	; set video mode
	lda #%00010001		; l0 enabled
	sta veradcvideo

	; set the l0 tile mode	
	lda #%00000011 	; height (2-bits) - 0 (32 tiles)
					; width (2-bits) - 0 (32 tiles
					; T256C - 0
					; bitmap mode - 0
					; color depth (2-bits) - 3 (8bpp)
	sta veral0config

	lda #(<(vram_tiles >> 9) | (1 << 1) | 1)
								;  height    |  width
	sta veral0tilebase
	
	; set the tile map base address
	lda #<(vram_l0_map >> 9)
	sta veral0mapbase

	; set video scale to 2x
	lda #64
	sta veradchscale
	sta veradcvscale

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxsebpp_tile_file-sxsebpp_tile_file)
	ldx #<sxsebpp_tile_file
	ldy #>sxsebpp_tile_file
	jsr SETNAM
	lda #(^vram_tiles + 2)
	ldx #<vram_tiles
	ldy #>vram_tiles
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxsebpp_map_file-sxsebpp_map_file)
	ldx #<sxsebpp_map_file
	ldy #>sxsebpp_map_file
	jsr SETNAM
	lda #(^vram_l0_map + 2)
	ldx #<vram_l0_map
	ldy #>vram_l0_map
	jsr LOAD

	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_sxsebpp_pal_file-sxsebpp_pal_file)
	ldx #<sxsebpp_pal_file
	ldy #>sxsebpp_pal_file
	jsr SETNAM
	lda #(^vram_pal + 2)
	ldx #<vram_pal
	ldy #>vram_pal
	jsr LOAD

	rts

