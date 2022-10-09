;wie dieses eine Immensity spiel, im gang hin und her rennen, rätsel lösen á Project Firestart?

;SHOW_DEBUG_VALUES

!src <c64.asm>

SCREEN_CHAR             = $c000
SPRITE_LOCATION         = $d000
SCREEN_COLOR            = $d800
CHARSET_PANEL_LOCATION  = $f000
CHARSET_LOCATION        = $f800

NUM_SPRITES             = 64

JOY_BUTTON  = $10
JOY_RIGHT   = $08
JOY_LEFT    = $04
JOY_DOWN    = $02
JOY_UP      = $01

SPRITE_POINTER_BASE     = SCREEN_CHAR + 1016

ZEROPAGE_POINTER_1      = $57
ZEROPAGE_POINTER_2      = $59
ZEROPAGE_POINTER_3      = $5b
ZEROPAGE_POINTER_4      = $08
ZEROPAGE_POINTER_5      = $0a
ZEROPAGE_POINTER_6      = $0c
ZEROPAGE_POINTER_7      = $0e
ZEROPAGE_POINTER_8      = $10

LOCAL1                  = $64
LOCAL2                  = $65
LOCAL3                  = $66

PARAM1                  = $5d
PARAM2                  = $5e
PARAM3                  = $5f
PARAM4                  = $60
PARAM5                  = $61
PARAM6                  = $62
PARAM7                  = $63
PARAM8                  = $67
PARAM9                  = $68
PARAM10                 = $69
PARAM11                 = $6a
PARAM12                 = $6b

CURRENT_INDEX           = $fb
CURRENT_SUB_INDEX       = $fc



* = $0801

!basic
          lda #15
          sta VIC.CHARSET_MULTICOLOR_1
          lda #0
          sta VIC.CHARSET_MULTICOLOR_2

          lda #0
          sta VIC.SPRITE_MULTICOLOR_1
          sta VIC.BORDER_COLOR
          lda #10
          sta VIC.SPRITE_MULTICOLOR_2

          ;bank 3
          lda CIA2.DATA_PORT_A
          and #$fc
          sta CIA2.DATA_PORT_A

          lda #( ( SCREEN_CHAR % 16384 ) / 1024 ) | ( ( CHARSET_LOCATION % 16384 ) / 1024 )
          sta VIC.MEMORY_CONTROL

          lda #$18
          sta VIC.CONTROL_2

          sei
          lda #$34
          sta PROCESSOR_PORT

          ;sprites
          ldx #0
          ldy #0
-
.ReadSprPos = * + 1
          lda SPRITES,x
.WriteSprPos = * + 1
          sta SPRITE_LOCATION,x

          inx
          bne -

          inc .ReadSprPos + 1
          inc .WriteSprPos + 1

          iny
          cpy #( ( NUM_SPRITES + 3 ) * 64 ) / 256
          bne -

          ;charset
          ldx #0
          ldy #0
-
.ReadChrPos = * + 1
          lda CHARSET_PANEL,x
.WriteChrPos = * + 1
          sta CHARSET_PANEL_LOCATION,x

          inx
          bne -

          inc .ReadChrPos + 1
          inc .WriteChrPos + 1

          iny
          cpy #( 256 * 8 * 2 ) / 256
          bne -


          lda #$37
          sta PROCESSOR_PORT
          cli

          jsr InitIrq

          jmp StartGame


!src "game.asm"
!src "util.asm"
!src "irq.asm"
!src "objects.asm"
!src "inventory.asm"


          !mediasrc "outpost.mapproject",MAP_,MAPVERTICALTILE

PANEL_SCREEN
          !media "panel.charscreen",CHARCOLOR

SPRITES
          !media "outpost.spriteproject",SPRITE,0,NUM_SPRITES

CHARSET_PANEL
          !media "items.mapproject",CHAR

;CHARSET
          !media "outpost.mapproject",CHAR

          !mediasrc "items.mapproject",ITEMS,TILEDATA