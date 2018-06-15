# Krolik

#### Created by Colin Russell ([colin-russell](https://github.com/colin-russell)), Mike Cameron ([MNJCMagic](https://github.com/MNJCMagic)) and Michael Stoltman ([irawrmike](https://github.com/irawrmike))

### Project Summary
Krolik is a multi-player multi-device tag/assassination game with a Soviet-era spy theme. Scaled for 2-100+ players, each player (krolik) begins the game by taking a selfie. Players are assigned a target which is kept secret from the rest of the players, and can "tag" players by finding them in real space and taking their picture, which is then run through a facial recognition algorithm checking it against that player's selfie to confirm their identity. They are then assigned a new target, and the game continues until there is one player left!

### Tech Stack

* Written in Swift
* Firebase Realtime DB enforces data/game state concurrency between players
* Firebase Cloud Storage stores user photos and interacts with the Kairos Facial Recognition API lessening data-load on player devices
* Firebase Cloud Functions (Javascript) triggered by database changes scrape for player data and form and send custom push notifications
* Kairos API checks submitted photos for facial presence upon enrolment and identity during gameplay

### Screenshots
<a href="url"><img src="https://github.com/irawrmike/Krolik/blob/master/Krolik/Screenshots/Screenshot-01.png" align="left" heignt="441.6" width="248.4"></a>
