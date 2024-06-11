# Twenty-Eight: A Card Game
#### Video Demo: *coming soon...*
#### Game Demo (web): [https://torquemcfearson.itch.io/twenty-eight](https://torquemcfearson.itch.io/twenty-eight?secret=IxK4IViKLl2EkFyLXBng4XUVKbY)
#### Game Demo (Windows): [https://torquemcfearson.itch.io/twenty-eight?#download](https://torquemcfearson.itch.io/twenty-eight?secret=IxK4IViKLl2EkFyLXBng4XUVKbY#download)

---
### || Description
Twenty-Eight is a 4-person trick-taking card game from India, similar to the american card game Spades, yet very different in key ways.
I was inspired to try my hand at it's digital recreation when a friend was complaining there were no good versions of it on his mobile app store. His frustration made me realize it was a missing need that I could actually help fulfill. So, I began my journey into the world of game design and have come out of it with the following game, which I submit to you as my final project here at CS50.

### || Platforms & Tools
I created the bulk of my project through the open-source game engine, **Godot 4**, a program I've never used before but read that it had a scripting language similar to **python** (a language I've become comfortable with thanks to CS50). This repo contains the source code for it's current stable version, which can be exported and played on **windows and web**. I've uploaded the current version to the indie game hosting platform **[itch.io](https://www.itch.io)** as a private project, which can be played on browser or downloaded using the link in the header.

Here's a breakdown of the structures used in Godot 4:
* Nodes - A thing. Defined by classes/node-types. Could be a sprite, an audio source, a button, text, slider.
* Scenes - A collection of things. A package of nodes organized into a single idea. Could be a small enemy and his health/weapon/sight or even an entire massive level.
* Scripts - Coding things. These decide the functionality of objects. Scripts are done at node level, so they also double as classes. 
* Assets - Outside things. Things you bring in to enhance could be images, sounds, music, fonts, icons, designs, etc.

### || Development
My overall principal approaching this was to do what I know and learn better techniques and apply them as I went. To stay productive, I decided to never go back and rebuild if I didn't have to. So, while I started out prototyping by only leveraging the most basic of techniques... arrays (what is a deck of cards if not just an array), I was soon learning about constructors, inheritance, OOP, and other structuring techniques that not only made me more .

One of the unique things about twenty-eight is nobody seems to agree on *exactly* what the rules are. When researching and learning to play I had to constantly adjust my understanding. This led to the creation of a customize rules menu, allowing players to discard unfamiliar or undesirable rule sets. Furthermore, since the game was difficult for me to pick up I decided to create different helpful contextual highlighting and other UX guides for those still learning the game.

Development went quite smoothly and I was learning things at a feverish rate. Sonn I was tweening cards between hands, constucting AI logic patterns, designing menus to modify global variables. Before I knew it, the game was functional and after a week of light polish, I had a build I was happy with. 


### || Conclusion
I started development around May 13, 2024 and was able to have a stable build I was happy with just under the month mark, June 11th, 2024. I'm quite happy with the current build, but never satisfied (which is a good thing). There is always going to be more I want to add.. like better AI, smoother UX, more options, better graphics, but that just comes from a place of passion, not because the game is lacking. So, I am submitting this version and will continue to improve and develop the mobile version on my own time. I am also currently working with a friend to build the next iteration of the game: **"Twenty-Eight with Friends"**, an online multiplayer version which will likely be for mobile and web hopefully. Still lots of learning for that, but my hopes are high.

So, how do I feel, all said and done. Well, let me start by saying, for almost the whole duration of this project, I was obssessive. I spent nearly every hour of my free-time dedicated to it. I've watching dozens of hours of game design videos, I've READ THE DOCS for Godot front and back, I've and I've reseached algerba that is way beyond my current understanding and I've concluded... This was fun as heck. I put something out into the world that wasn't there before. If I can have even one person play it and experience some amount of joy, I think it was worth it.

Thank you for reading my words, I've pasted the instructions to the game below, but they are also on the [itch.io page](https://torquemcfearson.itch.io/twenty-eight?secret=IxK4IViKLl2EkFyLXBng4XUVKbY).


---
---
<h1> Game Instructions </h1>


<h3>How to play</h3>
<p>There is...&nbsp;<strong>a lot..&nbsp;</strong>of variations on how this game is played. Below is our current ruleset and take on the game. &nbsp;It should become much more customizable as the game gets closer to it's launch stage.&nbsp;I recommended checking the&nbsp;<a href="https://en.wikipedia.org/wiki/Twenty-eight_(card_game)" target="_blank">wikipedia page</a> for full reference</p>
<p><br></p>
<h3>Things you need to know</h3>
<ul><li>You play on a team, with&nbsp;teammates sitting across from each other.</li><li>Game only uses 32-cards, from 7 to Ace-high,&nbsp;all suits.</li><li>Traditional rules ranks cards low-to-high in order of: 7, 8, Q, K, 10, A, 9, J.</li><li>Most cards are worth 0 points, except Ten=1, Ace=1, Nine=2, Jack=3.</li><li>You play 8 tricks per round&mdash;A trick is all players playing cards and highest rank card wins, collecting the points of all cards in play.</li><li><strong>TRUMP</strong> - Secret suit that can override the current suit in play.</li><li><strong>PIPS -&nbsp;</strong>Match points. A team wins or loses if they have +6 or -6 respectively.</li></ul>
<p><br></p>
<h3>Betting Phase</h3>
<p>Four cards are first dealt to each player, in clockwise order.&nbsp;Based on these four cards, players pass or bid in an&nbsp;auction-style round for the right to choose the&nbsp;<strong>TRUMP&nbsp;</strong>suit&mdash;<em>a secret&nbsp;suit that can override the suit in play (more on that later)</em>. However, your bid decides how many point you think you can win by, so bid accordingly.&nbsp;&nbsp;Bid starts at a minimum of 14 and reaches a max of 28.&nbsp; Higher bids change&nbsp;the amount of <strong>PIPs </strong>you risk to win or lose.&nbsp;A player wins the bid for their team if all others pass or they bet the max 28.</p>
<p><br></p>
<h3>Trump Picking Phase</h3>
<p>The bid winner chooses a secret suit&mdash;<em>usually </em><em>one they are holding the most of&mdash;</em>and this is kept secret until revealed. Players will call for it's reveal when they can't play any cards.</p>
<p><br></p>
<h3>Phase 1 - Trick</h3>
<p>More card are dealt&nbsp;until everyone has 8 cards.&nbsp; Starting with whoever won the bid, players will play cards into the center with the highest ranking card winning the trick. The catch is, players MUST follow suit of the first card laid down. The card with the highest rank wins and gains all the points of the cards in play.</p>
<p><br></p>
<h3>Phase 2 - Trump</h3>
<p>Eventually a player won't have a matching suit card to play, so they can&nbsp;call for the trump to be revealed to all.&nbsp;The playing a trump suit will beat cards all other suits, <strong>BUT..</strong> you can only play it if you can't match the suit in play. If you don't have a suit in play or a trump, you can play a trash card that won't win anyways.</p>
<p><em>Note: Currently, our game automatically reveals the trump when needed, but we will likely add the ability to have the choice as we develop it.</em></p>
<p><br></p>
<h3>Scoring</h3>
<p>When all eight tricks have been played, the bidding team adds up their points. If they met or exceed their original bid, they win.. otherwise they lose. Current rules give +1 pip (match point) for a win and -1 for a lose.</p>
<p>If either team reaches +6 or -6, they win or lose the match respectively.</p>
<h4>--Credits & Thanks--</h4>
<blockquote>"Vibing Over Venus" Kevin MacLeod (incompetech.com)<br>Licensed under Creative Commons: By Attribution 4.0 License<br><a href="http://creativecommons.org/licenses/by/4.0/">http://creativecommons.org/licenses/by/4.0/</a></blockquote>
