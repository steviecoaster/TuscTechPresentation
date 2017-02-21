Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.SelectVoice('Microsoft David Desktop')

$speak.Speak('Good afternoon, Tusc Technology Association!')
$speak.Dispose()