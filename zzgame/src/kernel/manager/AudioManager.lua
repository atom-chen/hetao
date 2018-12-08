-------------------------
-- 音频管理器
-------------------------
module("AudioManager", package.seeall)

local InstAudioEngine = cc.SimpleAudioEngine:getInstance()

function GetMusicVolume()
	return InstAudioEngine:getMusicVolume()
end

function SetMusicVolume(volume)
	assert(type(volume)=="number")
	InstAudioEngine:setMusicVolume(volume)
end

function PreloadMusic(filename)
	assert(type(filename)=="string", "invalid filename")
	InstAudioEngine:preloadMusic(filename)
end

function PlayMusic(filename, isLoop)
	assert(type(filename)=="string", "invalid filename")
	if type(isLoop) ~= "boolean" then isLoop = true end

	StopMusic(true)
	InstAudioEngine:playMusic(filename, isLoop)
end

function StopMusic(isReleaseData)
	isReleaseData = checkbool(isReleaseData)
	InstAudioEngine:stopMusic(isReleaseData)
end

function PauseMusic()
	InstAudioEngine:pauseMusic()
end

function ResumeMusic()
	InstAudioEngine:resumeMusic()
end

function RewindMusic()
	InstAudioEngine:rewindMusic()
end

function IsMusicPlaying()
	return InstAudioEngine:isMusicPlaying()
end

function GetSoundsVolume()
	return InstAudioEngine:getEffectsVolume()
end

function SetSoundsVolume(volume)
	assert(type(volume)=="number")
	InstAudioEngine:setEffectsVolume(volume)
end

function PlaySound(filename, isLoop)
	assert(type(filename)=="string", "invalid filename")
	isLoop = isLoop and true or false
	return InstAudioEngine:playEffect(filename, isLoop)
end

function PauseSound(handle)
	if not handle then
		printError("invalid handle")
		return
	end
	InstAudioEngine:pauseEffect(handle)
end

function PauseAllSounds()
	InstAudioEngine:pauseAllEffects()
end

function ResumeSound(handle)
	if not handle then
		printError("invalid handle")
	return
	end
	InstAudioEngine:resumeEffect(handle)
end

function ResumeAllSounds()
	InstAudioEngine:resumeAllEffects()
end

function StopSound(handle)
	if not handle then
		printError("invalid handle")
		return
	end
	InstAudioEngine:stopEffect(handle)
end

function StopAllSounds()
	InstAudioEngine:stopAllEffects()
end

function PreloadSound(filename)
	assert(type(filename)=="string", "invalid filename")
	InstAudioEngine:preloadEffect(filename)
end

function UnloadSound(filename)
	assert(type(filename)=="string", "invalid filename")
	InstAudioEngine:unloadEffect(filename)
end
