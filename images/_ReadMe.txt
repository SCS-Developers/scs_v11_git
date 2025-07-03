Transport Control Button Images for Cue Panels
==============================================

These images are 16x16 GIF's, and are named tr16...

The enabled 'play' image is tr16play.gif, and the disabled 'play' image is tr16playg.gif.

The disabled image is created from the enabled image using Icofx.
Open tr16play.gif
Select menu item Image -> Brightness/Contrast and set Brightness to 60. Leave Contrast at 0.
Export image as tr16playg.gif

In VB6, select the Play button and set the 'Picture' property to tr16play.gif, and the 'DisabledPicture' property to tr16playg.gif.

For color images, such as "cut 24.ico":
Select menu item Effect -> Color -> Grayscale
Select menu item Image -> Brightness/Contrast and set Brightness to 10 or 20 (depending on how dark the image is). Leave Contrast at 0.
Export image as cut24g.gif
