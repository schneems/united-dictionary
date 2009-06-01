
    function updateHTML(elmId, value) {
      document.getElementById(elmId).innerHTML = value;
    }

    function setytplayerState(newState) {
      updateHTML("playerstate", newState);
    }

    function onYouTubePlayerReady(playerId) {
      ytplayer = document.getElementById("myytplayer");
      setInterval(updateytplayerInfo, 250);
      updateytplayerInfo();
      ytplayer.addEventListener("onStateChange", "onytplayerStateChange");
    }

    function onytplayerStateChange(newState) {
      setytplayerState(newState);
    }

    function updateytplayerInfo() {
      updateHTML("bytesloaded", getBytesLoaded());
      updateHTML("bytestotal", getBytesTotal());
      updateHTML("videoduration", getDuration());
      updateHTML("videotime", getCurrentTime());
      updateHTML("startbytes", getStartBytes());
      updateHTML("volume", getVolume());
    }

    // functions for the api calls
    function loadNewVideo(id, startSeconds) {
      if (ytplayer) {
        ytplayer.loadVideoById(id, parseInt(startSeconds));
      }
    }

    function cueNewVideo(id, startSeconds) {
      if (ytplayer) {
        ytplayer.cueVideoById(id, startSeconds);
      }
    }

    function play() {
      if (ytplayer) {
        ytplayer.playVideo();
      }
    }

    function pause() {
      if (ytplayer) {
        ytplayer.pauseVideo();
      }
    }

    function stop() {
      if (ytplayer) {
        ytplayer.stopVideo();
      }
    }

    function getPlayerState() {
      if (ytplayer) {
        return ytplayer.getPlayerState();
      }
    }

    function seekTo(seconds) {
      if (ytplayer) {
        ytplayer.seekTo(seconds, true);
      }
    }

    function getBytesLoaded() {
      if (ytplayer) {
        return ytplayer.getVideoBytesLoaded();
      }
    }

    function getBytesTotal() {
      if (ytplayer) {
        return ytplayer.getVideoBytesTotal();
      }
    }

    function getCurrentTime() {
      if (ytplayer) {
        return ytplayer.getCurrentTime();
      }
    }

    function getDuration() {
      if (ytplayer) {
        return ytplayer.getDuration();
      }
    }

    function getStartBytes() {
      if (ytplayer) {
        return ytplayer.getVideoStartBytes();
      }
    }

    function mute() {
      if (ytplayer) {
        ytplayer.mute();
      }
    }

    function unMute() {
      if (ytplayer) {
        ytplayer.unMute();
      }
    }
    
    function getEmbedCode() {
      alert(ytplayer.getVideoEmbedCode());
    }

    function getVideoUrl() {
      alert(ytplayer.getVideoUrl());
    }
    
    function setVolume(newVolume) {
      if (ytplayer) {
        ytplayer.setVolume(newVolume);
      }
    }

    function getVolume() {
      if (ytplayer) {
        return ytplayer.getVolume();
      }
    }

	function funkystuff()
	{
		loadNewVideo('1ginKVtVRIU',0);	
		setVolume(100);
		var time = getCurrentTime()	;
	//	alert(''+time+'');
		
	//	whileTime();
	setInterval(check, 1000 );
	
	}
	
	function check() {
		time = getCurrentTime()	;
	//	alert(''+time + '');
		
		if (time>=22.5) 
		{
		//	alert(''+time + '');
			setTimeout("showGoogle()", 500);
			
		}
	}
	
	function showGoogle() {
		var search = document.getElementById('phrase_word');
		search = search.value;
		search =  search.split(' ').join('+');
		site_search = 'http://www.google.com/search?q=' + search + '';
		
		Element.hide('flashy')		
		
		window.location = site_search;
	}

	function load()
	{
		
	//	alert('amoor'); 
	
	
	
		setTimeout("funkystuff()", 2500);
		
	}
		// alert('' + time + '');
	//	setTimeout("funkystuff()", 2000);
	//	waitForEnd();
	//	showGoogle();
	
