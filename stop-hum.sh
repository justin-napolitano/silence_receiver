#!/bin/bash
# Wait a second, then play silent tone when AirPlay disconnects
sleep 2
aplay -q ~/Music/tones/silence.wav &
