; File: Sounds.pbi

EnableExplicit

DataSection
  ;- sine wave test tone
  sine_wave_test_tone_file:
  IncludeBinary "sounds\sine_test.wav"
  sine_wave_test_tone_file_end:   ; needed so that length can be calculated
  
  ;- pink noise test tone
  pink_noise_test_tone_file:
  IncludeBinary "sounds\pink_test.wav"
  pink_noise_test_tone_file_end:   ; needed so that length can be calculated
  
EndDataSection

; EOF
