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

	lda #1
	sta zp_loaded

@check_joy:
	; check joystick

	jsr GETIN
	beq @return
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

