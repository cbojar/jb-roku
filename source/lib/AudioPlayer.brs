Function CreateAudioPlayer( port As Object ) As Object
	audioPlayer = CreateObject("roAssociativeArray")
	audioPlayer.player = CreateObject("roAudioPlayer")
	audioPlayer.playing = false
	
	audioPlayer.IsPlaying = AudioPlayer_IsPlaying
	audioPlayer.Stop = AudioPlayer_Stop
	audioPlayer.Play = AudioPlayer_Play
	audioPlayer.SetStream = AudioPlayer_SetStream
	
	return audioPlayer
end Function

Function AudioPlayer_IsPlaying()
	return m.playing
end Function

Function AudioPlayer_Stop()
	m.player.Stop()
	m.playing = false
end Function

Function AudioPlayer_Play()
	m.player.Play()
	m.playing = true
end Function

Function AudioPlayer_SetStream( audioStream As Object )
	m.player.AddContent( audioStream )
	m.player.SetLoop( false )
end Function
