function WatchedStatusTracker()
	instance = CreateObject("roAssociativeArray")

	instance.saveProgress = function(title as String, currentPosition as Integer)
		if(currentPosition < 30)
			return false
		end if

		RegWrite(title, currentPosition.toStr())
		return true
	end function

	instance.getProgress = function(title as String)
		savedProgress = RegRead(title)
		if savedProgress = invalid
			return 0
		end if
		
		return savedProgress.toInt()
	end function

	instance.hasProgress = function(title as String)
		savedProgress = RegRead(title)
		return savedProgress <> invalid
	end function

	instance.removeProgress = function(title as String)
		RegDelete(title)
	end function

	return instance
end function