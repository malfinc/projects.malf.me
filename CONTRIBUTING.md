# Contributing

The MALF Project is a combination of various technologies. At a high level the project uses:

  - [fly](https://fly.io/) as a application hosting platform
  - [supabase](https://supabase.com/) as a database hosting platform
  - [AWS S3](https://aws.amazon.com/s3/) as a object storage service
  - [AWS Cloudfront](https://aws.amazon.com/cloudfront/) as a global CDN service

However in order to contribute as an individual you'll be interfacing with these:

  - [postgresql](https://www.postgresql.org/) as a general database
  - [elixir](https://elixir-lang.org/) as the core programming language of the application
  - [javascript](https://developer.mozilla.org/en-US/docs/Web/JavaScript) as the core programming language of the browser
  - [bootstrap](https://getbootstrap.com/) as the core set of styled components
  - [phoenix](https://www.phoenixframework.org/) as the web framework of the backend
  - [htmx](https://www.fantasyworldgenerator.com/admin) as the browser interactive interface
  - [liveview](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) as the rendering layer of phoenix


Ultimately what this means is that in order to build a feature you'll need to know at least Elixir, Phoenix, Javascript, and CSS. However you don't need to know a *lot* about these things. Elixir is a very small language to learn, Javascript via htmx and liveview is very minimal by nature, for styling you will likely be leaning on bootstrap and fall back to tailwind for things that need changing or don't exist.

When you're storing things in the database we've created a rather comprehensive interface so you don't need to know any SQL or anything in particular about postgres.

**The specific tools you need to have installed**:

  1. elixir
  2. a browser
  3. postgres

It is highly recommended you use a Github Codespaces instance as we've setup quite a lot of configuration for that and it's a one-button-and-done scenario.

## Working on the project

Once you've installed all the tooling detailed above branch off of the `main` branch and make some changes to the source. It's heavily recommended that you create a draft pull request as soon as possible so you can get feedback.


## Core concepts

Every MALF Project has a set of shared core concepts:

  - A user, backed by a twitch account
  - A coin transaction, which is a deposit or withdraw of fictional coins
  - An organization which separates what projects a user is a part of
  - A permission set which determines what the user can do in that organization
