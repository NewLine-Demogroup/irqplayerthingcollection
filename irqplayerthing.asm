* = $0801
BasicUpstart2(start)
.var sid1 = LoadSid("64_Forever.sid")
sid_name:   .text sid1.name.toLowerCase()
            .byte 0
sid_author:   .text sid1.author.toLowerCase()
                .byte 0
sid_copyright:   .text sid1.copyright.toLowerCase()
                    .byte 0
sid_player:   .text "created using irq player thing v1"
                    .byte 0
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
    jsr $e544
    lda #$00
    sta fadeactive
    sei
    jsr sid1.init
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
    beq player
    sta $0400+40*2,x
    inx
    jmp copyrightloop
player:
    ldx #0
playerloop:
    lda sid_player,x
    beq done
    sta $0400+40*3,x
    inx
    jmp playerloop
clearloop:
    sei
    lda #$1f
    sta $d400,x
    dex
    bpl clearloop
    rts
done:
    sei
    lda #%10000001
    sta CIA1_ICR 

    lda #$c8
    sta CIA1_TA_LO
    lda #$4c
    sta CIA1_TA_HI

    lda #%00000001
    sta CIA1_CRA

    lda #<irq
    sta $0314
    lda #>irq
    sta $0315
    cli
    jmp *     
irq:
    pha 
    txa
    pha
    tya
    pha

    inc $d020
    jsr sid1.play
    dec $d020

    pla
    tay
    pla
    tax
    pla
    jmp $ea31

fade:

    lda $d418
    and #$f0
    beq fadestop
    sec
fadeloop:
    sbc #$01
    sta $d418
    lda $d418
    ora cur_vol
    cmp #$00
    beq fadestop
fadestop:
    ldx #$00
    jsr clearloop
    jmp $ea31

* = sid1.location "SID1"
    .fill sid1.size, sid1.getData(i)