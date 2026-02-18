* = $0810
BasicUpstart2(start)
sid_name:   .text "acrouzet music collection"
            .byte 0
sid_author:   .text "acrouzet (code by d/v)"
                .byte 0
sid_copyright:   .text "2026 newline"
                    .byte 0
.var songnum = 0
.var frame_lo = $fb
.var frame_hi = $fc
.var music_on = $fd
// sid_player:   .text "created using irq player thing v2"
                    // .byte 0
.const CIA1_PRA = $dc00
.const CIA1_TA_LO = $dc04
.const CIA1_TA_HI = $dc05
.const CIA1_ICR = $dc0d
.const CIA1_CRA = $dc0e
.const IRQ_VECTOR = $0314
cur_vol: .byte $0f
timer: .byte $ff
fadeactive: .byte 1
fadecounter: .byte 15

start:
    ldx #0
start2:
    jsr $e544
    lda #$00
    sta $d020
    sta $d021
    sei
    jsr done
    lda songnum
    cmp #0
    beq tune1_init1
    cmp #1
    beq tune2_init2
    ldx #0
loop:
    lda sid_name,x
    beq author
    sta $0400,x
    inx
    jmp loop

author:
    ldx #0
authorloop:
    lda sid_author,x
    beq copyright
    sta $0400+40*1,x
    inx
    jmp authorloop

copyright:
    ldx #0
copyrightloop:
    lda sid_copyright,x
    beq done
    sta $0400+40*2,x
    inx
    jmp copyrightloop
clearloop:
    sei
    lda #$1f
    sta $d400,x
    dex
    bpl clearloop
done:
    lda #0
    sta frame_lo
    sta frame_hi

    lda #1
    sta music_on
    rts
play:
    lda music_on
    beq done_play
    ldx songnum
    cmp #0
    beq tune1_play1
    cmp #1
    beq tune2_play2
    inc frame_lo
    bne check_time
    inc frame_hi

check_time:
    lda frame_hi
    cmp #$29
    bcc done_play
    bne stop_music

    lda frame_lo
    cmp #$04
    bcc done_play

stop_music:
    lda #0
    sta music_on

done_play:

    rts

tune1_init1:
    jsr $1000
    rts

tune2_init2:
    jsr $3000
    rts

tune1_play1:

    jsr $1003

    rts

tune2_play2:

    jsr $3003

    rts    

* = $1000
tune1:
    .import binary "Incircle.bin"
.var tune1_init = tune1
.var tune1_play = tune1+3
    
* = $3000
tune2:
    .import binary "Casual_Talk_at_the_Town_Shop.bin"
.var tune2_init = tune2
.var tune2_play = tune2+3