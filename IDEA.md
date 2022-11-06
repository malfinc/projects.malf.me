# Idea

## Session 1

> tl;dr Each adopted plant has a digital version with a given name, character art, and some stats. So each would have a player card. Then chat can use channel points to upgrade stats and such. Then, each week I load up a BR simulator that I have with updated stats for each plant champion, run the simulation, and then update stats based on winners and update the leaderboard on the website. It'd basically be like a sports season and at the end of the season, so many will qualify for the playoffs and at the end we have one winning plant champion
>
> I can do most of this stuff via Google Docs, but it's a lot more manual and limiting and I was needing to get the website going anyways, so I figured it might not be that crazy to combine the two. The previous person helping had a very rough MVP a while back but I don't have it anymore and they're MIA.
>
> Anyways, not sure how complex this sort of thing actually is or not, so be real with me if it's feasible or something you'd have any interest in

Notes:

  - https://dev.twitch.tv/docs/eventsub/manage-subscriptions
  - https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#channelchannel_points_custom_reward_redemptionadd

## Session 2

> Alright, the very basic idea is that the website would connect to the Twitch API and pull information about channel points, channel point reward redemptions, and sub, resub, gift sub, and bits a user has contributed. Channel points subs and such would all have a conversion happen on the site that we'll call tokens for now.

> There would be a page on the site where a person would be able to go and digitally adopt from a list of plants if they have the necessary amount of tokens. When they adop, a basic player card is created for that plant, which I'm calling Plant Champions for now. It would look sort of like the one I posted above a little while back with a few changes since that's a rough draft.

> That card would then site in that user's library where other cards they have are. They will then have the option to use a certain amount of tokens to increase an individual stat by one point (strength, speed, intelligence, endurance, and luck) or they can use tokens to increase the card's rarity (common, uncommon, rare, epic, legendary, and mythical). Increasing rarity will apply a blanket stat multiplier to all five stats -- will have to tweak values, but imagine that common = 1.0, uncommon = 1.2, rare = 1.4, epic = 1.6, legendary = 1.8, and mythical = 2.0).

> Once a week, I'd open up the BR simulator game I have, manually update stats for each plant champion, and run the simulation on stream. A certain amount of points would be allotted based on finishing position of the top three. There would be a leaderboard on the site that lists each champion, how many points they have, who their parent (adopter) is, and link to the plant card. Eventually we'd have a playoffs where only so many make it in and then finally a winner.

> So that's the "basic" idea and I have much more ideas that would make things nice and complicated for potential future seasons malfLUL

> But if I've learned anything from you is it's all about the MVP

Okay so every time someone does a twitch event of the type listed we need to create for them a player in our database. Players start off with an empty "deck of plants".

Events generate tokens for that player.

The user that triggered the twitch event can then come to our website, confirm that they are the source of the event somehow, and then do actions.

One action is that they can pay for a plant to be copied to their deck as a "plant champion" from a plant base.

Another action is that they can pay to modify one of their plant champions in their deck.

A site operator can then simulate a game between multiple plant champions, awarding points to players, generating a leaderboard, and leading to future games.

> So right now I have an actual [simulation game on Steam](https://store.steampowered.com/app/385240/Ultimate_Arena/?curator_clanid=32939416) that I would run. For the future I would love if we could run simulations on the site, but there wouldn't really need to be a visual component, just a simple text feed that could display results and such

> Alright, I'm just gonna lay out the other ideas for you now then which would be like a season 2 or 3 or 4 type of thing, but I don't know where they fit on the feasibility scale. Fighting simulation is done on the website, with text output of events as a baseline and perhaps more visual stuff if we get additional help
>   - People can trade plants
>   - People can auction off plants
>   - People can spend tokens to buy items to assign to plant champions
>   - People can trade items
>   - People can auction off items
>   - Plant types come with certain move types
>   - Users can assign only a certain number of moves available to their plant (2? 3?)
>   - Users can spend tokens to train their champion in various fighting techniques
>   - Each fighting technique comes with special moves and perhaps boost to certain stats
>   - Plant types have strengths and weaknesses to certain move types
>   - There is an auction house to buy rare items or plants
> That's a VERY rough list of stuff, but I think it would mostly rely on existing stuff. Like, just more stuff to buy/upgrade with tokens. Though, not sure how hard it would be to allow users to assign and remove items/moves.
> And the idea of an item shop and auction house in general seem really cool to me but I have no idea what that entails in the backend
