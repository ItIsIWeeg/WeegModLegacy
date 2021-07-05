-- ok so this controls the arrows swapping sides for ditto matches because im stupid

-- this gets called starts when the level loads.
function start(song) -- arguments, the song name
print("Song: " .. song .. " @ " .. bpm .. " downscroll: " .. downscroll)
print("We swappin sides now")
setActorX(defaultStrum0X, 4)
setActorX(defaultStrum1X, 5)
setActorX(defaultStrum2X, 6)
setActorX(defaultStrum3X, 7)
setActorX(defaultStrum4X, 0)
setActorX(defaultStrum5X, 1)
setActorX(defaultStrum6X, 2)
setActorX(defaultStrum7X, 3)
print("All done lol")
end

-- this gets called every frame
function update(elapsed) -- arguments, how long it took to complete a frame

end

-- this gets called every beat
function beatHit(beat) -- arguments, the current beat of the song

end

-- this gets called every step
function stepHit(step) -- arguments, the current step of the song (4 steps are in a beat)

end