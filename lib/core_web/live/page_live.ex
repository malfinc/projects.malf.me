defmodule CoreWeb.PageLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :home, _params) do
    socket
    |> assign(:page_title, "Plotgenerator")
  end

  defp as(socket, :pricing, _params) do
    socket
    |> assign(:page_title, "Pricing")
  end

  defp as(socket, :about_us, _params) do
    socket
    |> assign(:page_title, "About Us")
  end

  defp as(socket, :faq, _params) do
    socket
    |> assign(:page_title, "Frequently Asked Questions")
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :home} = assigns) do
    ~H"""
    <img
      src={~p"/images/creation.jpg"}
      class="block--thick float-end m-5"
      alt="World Building"
      width="500px"
      height="286px"
    />
    <h1>Welcome to Dun-Genesis</h1>
    <p><em>Dun-Genesis puts the power of creation in your hands.</em></p>
    <h3 id="upping-your-game">Upping Your Game</h3>
    <p>
      Dun-Genesis is building a completely integrated, system-agnostic proceedural world-builder for fantasy settings.
    </p>
    <p>
      With our system, you can create multiple worlds with the click of a button.
      Each world comes complete with:
    </p>
    <ul>
      <li>
        Cultures, religions, deities and all the traditions, languages and people
        they represent,
      </li>
      <li>Nations, Kingdoms, Domains and the people within them,</li>
      <li>
        Cities and settlements, from rural villages to capital cities, from pirate ports to
        trading outposts, all with districts, locations, shops and story hooks.
      </li>
      <li>
        The people who populate the world, each person with a unique background, motivation and archetype, along with and story hooks and relationships with other people.
      </li>
    </ul>

    <p>
      No two worlds, nations, adventures, people or any other element are copies or identical. Each is uniquely generated for you.
    </p>
    <h3 id="but-theres-more">But There's More...</h3>
    <p>
      To tie the world together, Dun-Genesis also generates Tabletop RPG style
      narrative adventures, drawing on the Locations, People, Cultures, Nations and
      Gods that you have created. Each adventure includes villains, their goals and
      desires, as well as their henchman, the servitors, traps and monsters at their
      command and all other details required to make your adventure memorable.
    </p>
    <h3 id="example-adventure-elements">Example Adventure Elements</h3>
    <h5 id="example-the-hook">The Hook - 'The Spring Breaking Point'</h5>
    <img
      src={~p"/images/adeld.jpg"}
      title="Dashing Villians!"
      class="block--thick float-end m-5"
      width="200px"
      height="356px"
    />
    <p>
      Lord Adéld Libomíli threatens the realm with his drive to gain political
      domination. He is trying to destroy the last free holding in the Skiretir
      Islands - Mayor Nabee Lulon's home port of N'Dharnobleoia.
    </p>
    <p>
      In a lightning strike, a hoard of Human Nobles, hired by Lord Adéld Libomíli,
      have overrun the peaceful, tropical island town of N'Dharnobleoia. Refugees
      are streaming out of N'Dharnobleoia, and unless the Nobles can be removed,
      Lord Adéld Libomíli's victory is assured as the town collapses under the
      entitled weight of expectant nobility.
    </p>
    <p>
      Erwiliut Wigtrank, Mayor Nabee Lulon's right hand man, hires your group to
      find a way to drive the nobles out before they completely destroy the town.
    </p>
    <img
      src={~p"/images/nabee.jpg"}
      class="block--thick float-start m-5"
      title="Don't mess with her."
      width="200px"
      height="400px"
    />
    <h5 id="example-npc">Non-Player Character - Mayor Nabee Lulon</h5>
    <p>
      <em>Overview:</em> Nabee Lulon is a young adult human, of the Rema-chati
      culture. They present as female. They are a follower of the Furious Trinity
      religion.
    </p>
    <p>
      <em>Appearance:</em> Nabee Lulon has wide heart face with a dimpled smile and
      bronze eyes. Nabee Lulon has a lithe frame and deep khaki skin.
    </p>
    <p>
      <em>Background Information:</em> Trained as a sailor, Nabee Lulon speaks
      Common, Old Rema-Chati and North-Eastern Rema-Chati and is skilled in
      Athletics and Perception.
    </p>
    <p>
      <em>Personal Information:</em> "Sailing has been in my blood for generations,
      passing a ship down from parent to child. Unfortunately, the ship was lost in
      a squall a few years back and I've been ashore since. People say I like a job
      well done, especially if I can convince someone else to do it for me. What
      matters most to me in the world is freedom. Not being tied down or forced into
      a path. The sea is freedom — the freedom to go anywhere and do anything. That
      said, I'm loyal to my crew, everything else comes after. I'm not proud of it,
      but I drink more than I should."
    </p>
    <p>
      My first love... was everything you hear about in bardsong. I was a sailor,
      and he, a noblemans son. Everything was perfect, until his older brother died
      and he became heir to the Barony of Libomí, on the other side of the island.
      He broke my heart when he told me I wasn't good enough for him anymore. One
      day, I will show Lord Adéld Libomíli just how good I really am."
    </p>
    <h5 id="example - location">Encounter Location - 'The Sea-Cave's Secrets'</h5>
    <img
      src={~p"/images/sea_cave.jpg"}
      class="block--thick float-end m-5"
      title="sea caves are fun!"
      width="400px"
      height="318px"
    />
    <p>
      This room appears to be a sea-cave, huge and irregularly shaped, roughly 50
      feet by 40 feet.
    </p>
    <p>
      The main passage is a sea-worn tunnel of basalt some ten feet wide. The
      sea-cave has a rough-hewn natural stone-and-sand floor.
    </p>
    <p>
      The walls of this room are extremely smooth, polished to a sheen by the flow
      of water. The shattered remains of a small boat sit to one side, a testament
      to a voyage that ended poorly. A statue of <em>Alashm the Romantic</em>, the
      Orkish goddess of love, stands in the center of the room, one hand up and
      pointing at the passage you came in from. The statue is made from bits of
      broken timber and flotsom, held together with rope and seaweed.
    </p>
    <p>
      The only other exit from this room is a corroded metal door set in the far
      wall, with a rusty wheel set into the center. It is locked.
    </p>
    <p>
      <em>Traps:</em> There is a mundane trap set in the room. It is designed to
      inconvenience or delay the party. If the players approach the statue of
      Alashm, an adhesive spray will splatter, doing no damage but taking several
      minutes to remove.
    </p>
    """
  end

  @impl true
  def render(%{live_action: :pricing} = assigns) do
    ~H"""
    <h1>Pricing</h1>

    <p><em>Pricing plans that suit your gaming needs.</em></p>
    <p>
      Dun-Genesis provides several subscription plans that don't break the bank and
      are tailored to you. All packages come with access to our Discord server.
    </p>
    <table class="table table-striped block--thick">
      <thead>
        <tr>
          <th>Subscription Package</th>
          <th>Worlds</th>
          <th>Adventures</th>
          <th>NPCs</th>
          <th>Encounters</th>
          <th>Cost</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>The Explorer</td>
          <td>One</td>
          <td>Three</td>
          <td>Fifty</td>
          <td>Thirty</td>
          <td>$1 Per Month</td>
        </tr>
        <tr>
          <td>The Adventurer</td>
          <td>Three</td>
          <td>Fifteen</td>
          <td>Two Hundred and Fifty</td>
          <td>One Hundred and Fifty</td>
          <td>$10 Per Month</td>
        </tr>
        <tr>
          <td>The Dungeon Master</td>
          <td>Unlimited</td>
          <td>Unlimited</td>
          <td>Unlimited</td>
          <td>Unlimited</td>
          <td>$15 Per Month</td>
        </tr>
      </tbody>
    </table>
    <h3 id="theres-more">But there's more...</h3>
    <p>
      For the Storyteller in a bind, or one who just loves what we do, we offer <strong><em>The Bardic Package</em></strong>. This package is as the Dungeon Master Package above, but has two key
      features in addition.
    </p>
    <ul>
      <li>Access to the Test Server, previewing upcoming features.</li>

      <li>
        The 1 hour consult on discord per $time-period with a Storyteller to help
        flesh out your world or story.
      </li>
    </ul>
    <p><em>The Bardic Package costs $50 per month.</em></p>
    """
  end

  @impl true
  def render(%{live_action: :about_us} = assigns) do
    ~H"""
    <h1>About Dun-Genesis</h1>
    <h3 id="what-we-do">What we do</h3>
    <img
      src={~p"/images/worldbuilding.png"}
      class="block--thick"
      alt="An overly complicated method of world building...."
      width="500px"
      height="300px"
      style="float:right"
    />
    <p class="indented">
      Dun-Genesis focuses on providing Dungeon Masters, Storytellers and Worldbuilders with a set of tools that allow for the creation not only only of quality non-player characters, but the world and context - the cultures they come from, the religions they practice, the nations thye live in and the adventure hooks they provide, all in the blink of an eye and the click of a button.
    </p>
    <h3 id="why-we-do-it">Why we do it</h3>
    <p class="indented">
      There's a storyteller in all of us - someone who wants to engage with thier friends and family, crafting a story, a narrative experience that is both enjoyed and remembered. Sadly, not all of us have the time, confidence or resources to detail the world, or figure out the structure of that adventure, or come up with the myriad side plots, non-player characters, treasures or whole cities that players might want to explore. So we made Dun-Genesis to empower you to face any challenge your players throw at you - and look good doing it.
    </p>
    <h3 id="who-we-are">Who we are</h3>
    <p>Dun-Genesis is a two-person team.</p>
    <p>
      Kurtis Rainbolt-Greeneis a senior software developer, specializing in Ruby, Ruby on Rails and Elixir. He's also a gamer, with decades of experience in tabletop RPGs.
    </p>
    <p>
      James Ryan is a writer, roleplayer and, as of this project, a software developer. He has worked in the TTRPG industry as an editor, researcher and writer, working with several companies.
    </p>
    <p>
      Together, they identified a need within the surging popularity of Tabletop RPGs, and set out to address it.
    </p>
    """
  end

  @impl true
  def render(%{live_action: :faq} = assigns) do
    ~H"""
    <h1>Frequently Asked Questions</h1>

    <h3 id="what-is-dun-genesis">What is Dun-Gensis?</h3>
    <p class="indented">
      Dun-Genesis is a suite of tools for worldbuilders, game-masters, storytellers and anyone else who is interested in fantasy worlds. Designed to be powerful but approachable, it can create an entire universe (Called 'Worlds) at the touch of a button, with each element able to be edited or replaced until it's something you find suitable.
    </p>

    <h3 id="what-is-a-world">What is a World?</h3>
    <p class="indented">
      In the Dun-Genesis system, a 'world' is a distinct continutity and container
      of story. The contents of a world, from its people to its cultures, will be
      unique to it. While other worlds can generate similar content, this world is
      particular in its customization and totality.
    </p>

    <h3 id="world-contents">What is in a World?</h3>
    <p class="indented">As of right now, Dun-Genesis can generate the following:</p>
    <ul>
      <li>The World.</li>
      <li>Unique Cultures.</li>
      <li>Custom Religions.</li>
      <li>Nations and Organizations.</li>
      <li>Fully outlined Adventures.</li>
      <li>Interesting and detailed NPCs.</li>
      <li>Random Encounters.</li>
      <li>Traps.</li>
      <li>Dungeon Rooms.</li>
      <li>Dungeon Histories.</li>
    </ul>

    <h3 id="what-is-culture">What is a Culture?</h3>
    <p class="indented">
      Dun-Genesis defines a culture as a block of people who share language, history
      and values. We don't define 'elven' culture or 'dwarven' culture, but rather,
      cultures have their own ethnic mixtures based on the territories and locations
      they control.
    </p>

    <p>Here's an example culture.</p>
    <aside class="block--thick">
      <p><strong>The Eweniaan people</strong></p>
      <p class="indented">
        The Eweniaan are a flourishing spiritual civilization, who's primary
        pantheon is the Organized Trunk. Their patron diety is Jirostýn, the God of
        zeal and metals. They live a mostly urban lifestyle, with wealth highly
        centralized in their ruling class.
      </p>
      <p class="indented">
        The Eweniaan people mostly speak Southern Saxotilach-Uriaalpan, Central
        Eweniaan and Classic Eweniaan. They are known for their cultural
        appreciation of the performing arts, with a special love for acrobatics, and
        for their fine cuisine. Eweniaan styles, be it clothing or jewelery, are
        seen as status symbols in most of the civilized world.
      </p>
      <p class="indented">
        Staunch traditionalists, the Eweniaan people look to their ancestors with
        pride for founding the first Republic. Eweniaan miners and metalworkers are
        very skilled, while their military is known for their scouts, especially in
        the mountains.
      </p>
    </aside>
    <h3 id="what-is-encounter">What is an Encounter?</h3>
    <p class="indented">
      An encounter in Dun-Genesis' system, is a environment, such as a room or glade
      or cavern, coupled with an obstacle to overcome - such as a group of monsters,
      a trap, a roleplaying scenario or... all of the above... or none of the above.
      We provide many elements to choose from - but in the end, the Storyteller has
      control.
    </p>

    <h3 id="how-register">How do I get an account?</h3>
    <p class="indented">
      Glad you asked! Just follow this link to register your account!
      <.link href={~p"/accounts/register"} class="nav-link p-0">Registration</.link>
    </p>

    <h3 id="what-cost">What does it cost?</h3>
    <p class="indented">
      Check out our subscription plans:
      <.link href={~p"/pricing"} class="nav-link p-0 text-muted">Pricing</.link>.
    </p>

    <h3 id="who-is-is-making-it">Who's making this thing?</h3>
    <p class="indented">
      You can find information about the pair behind Dun-Genesis here:
      <.link href={~p"/about_us"} class="nav-link p-0 text-muted">About Us</.link>
    </p>
    """
  end
end
