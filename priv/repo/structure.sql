--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2
-- Dumped by pg_dump version 14.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: cube; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;


--
-- Name: EXTENSION cube; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION cube IS 'data type for multidimensional cubes';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: isn; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS isn WITH SCHEMA public;


--
-- Name: EXTENSION isn; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION isn IS 'data types for international product numbering standards';


--
-- Name: lo; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS lo WITH SCHEMA public;


--
-- Name: EXTENSION lo; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION lo IS 'Large Object maintenance';


--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


--
-- Name: pg_buffercache; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_buffercache WITH SCHEMA public;


--
-- Name: EXTENSION pg_buffercache; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_buffercache IS 'examine the shared buffer cache';


--
-- Name: pg_prewarm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_prewarm WITH SCHEMA public;


--
-- Name: EXTENSION pg_prewarm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_prewarm IS 'prewarm relation data';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgrowlocks; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgrowlocks WITH SCHEMA public;


--
-- Name: EXTENSION pgrowlocks; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgrowlocks IS 'show row-level locking information';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


--
-- Name: oban_job_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oban_job_state AS ENUM (
    'available',
    'scheduled',
    'executing',
    'retryable',
    'completed',
    'discarded',
    'cancelled'
);


--
-- Name: oban_jobs_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.oban_jobs_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  channel text;
  notice json;
BEGIN
  IF NEW.state = 'available' THEN
    channel = 'public.oban_insert';
    notice = json_build_object('queue', NEW.queue);

    PERFORM pg_notify(channel, notice::text);
  END IF;

  RETURN NULL;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id uuid NOT NULL,
    email_address public.citext NOT NULL,
    confirmed_at timestamp(0) without time zone,
    username public.citext,
    onboarding_state public.citext NOT NULL,
    hashed_password character varying(255) NOT NULL,
    profile jsonb DEFAULT '{}'::jsonb NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    provider text NOT NULL,
    provider_access_token text NOT NULL,
    provider_refresh_token text NOT NULL,
    provider_token_expiration integer NOT NULL,
    provider_id text NOT NULL,
    avatar_uri text NOT NULL,
    provider_scopes text[] DEFAULT ARRAY[]::text[] NOT NULL
);


--
-- Name: accounts_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts_tokens (
    id uuid NOT NULL,
    account_id uuid NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cards (
    id uuid NOT NULL,
    rarity_id uuid NOT NULL,
    champion_id uuid NOT NULL,
    season_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    account_id uuid,
    full_art boolean DEFAULT false NOT NULL,
    holographic boolean DEFAULT false NOT NULL
);


--
-- Name: champions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.champions (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    plant_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    image_uri public.citext
);


--
-- Name: coin_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coin_transactions (
    id uuid NOT NULL,
    value double precision NOT NULL,
    account_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    reason text DEFAULT 'unknown'::text NOT NULL
);


--
-- Name: conferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conferences (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: divisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.divisions (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    conference_id uuid NOT NULL
);


--
-- Name: matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matches (
    id uuid NOT NULL,
    left_champion_id uuid,
    right_champion_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    season_id uuid NOT NULL,
    division_id uuid NOT NULL,
    weekly_id uuid NOT NULL
);


--
-- Name: oban_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oban_jobs (
    id bigint NOT NULL,
    state public.oban_job_state DEFAULT 'available'::public.oban_job_state NOT NULL,
    queue text DEFAULT 'default'::text NOT NULL,
    worker text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    errors jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 20 NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    scheduled_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    attempted_at timestamp without time zone,
    completed_at timestamp without time zone,
    attempted_by text[],
    discarded_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    tags character varying(255)[] DEFAULT ARRAY[]::character varying[],
    meta jsonb DEFAULT '{}'::jsonb,
    cancelled_at timestamp without time zone,
    CONSTRAINT attempt_range CHECK (((attempt >= 0) AND (attempt <= max_attempts))),
    CONSTRAINT positive_max_attempts CHECK ((max_attempts > 0)),
    CONSTRAINT priority_range CHECK (((priority >= 0) AND (priority <= 3))),
    CONSTRAINT queue_length CHECK (((char_length(queue) > 0) AND (char_length(queue) < 128))),
    CONSTRAINT worker_length CHECK (((char_length(worker) > 0) AND (char_length(worker) < 128)))
);


--
-- Name: TABLE oban_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.oban_jobs IS '11';


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oban_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oban_jobs_id_seq OWNED BY public.oban_jobs.id;


--
-- Name: oban_peers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.oban_peers (
    name text NOT NULL,
    node text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: organization_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_memberships (
    id uuid NOT NULL,
    account_id uuid NOT NULL,
    organization_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: organization_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_permissions (
    id uuid NOT NULL,
    permission_id uuid NOT NULL,
    organization_membership_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: pack_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pack_slots (
    id uuid NOT NULL,
    pack_id uuid NOT NULL,
    card_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: packs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.packs (
    id uuid NOT NULL,
    opened boolean DEFAULT false NOT NULL,
    season_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    account_id uuid
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: plants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plants (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    starting_attributes jsonb NOT NULL,
    rarity_symbol text NOT NULL,
    image_uri text NOT NULL,
    species text NOT NULL
);


--
-- Name: rarities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rarities (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    color text NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    season_pick_rate integer DEFAULT 0 NOT NULL,
    pack_slot_caps integer[] DEFAULT ARRAY[]::integer[] NOT NULL,
    holographic_rate double precision DEFAULT 0.0 NOT NULL,
    full_art_rate double precision DEFAULT 0.0 NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: season_plants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.season_plants (
    plant_id uuid NOT NULL,
    season_id uuid NOT NULL
);


--
-- Name: seasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seasons (
    id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    active boolean DEFAULT false NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: upgrades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upgrades (
    id uuid NOT NULL,
    stage integer NOT NULL,
    strength integer DEFAULT 0 NOT NULL,
    speed integer DEFAULT 0 NOT NULL,
    intelligence integer DEFAULT 0 NOT NULL,
    endurance integer DEFAULT 0 NOT NULL,
    luck integer DEFAULT 0 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    champion_id uuid NOT NULL,
    patron_account_id uuid NOT NULL
);


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    event public.citext NOT NULL,
    item_type text NOT NULL,
    item_id uuid NOT NULL,
    item_changes jsonb NOT NULL,
    originator_id uuid,
    origin text,
    meta jsonb,
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks (
    id uuid NOT NULL,
    provider public.citext NOT NULL,
    headers jsonb NOT NULL,
    payload jsonb NOT NULL
);


--
-- Name: weeklies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weeklies (
    id uuid NOT NULL,
    season_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: oban_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs ALTER COLUMN id SET DEFAULT nextval('public.oban_jobs_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: accounts_tokens accounts_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_tokens
    ADD CONSTRAINT accounts_tokens_pkey PRIMARY KEY (id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: champions champions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.champions
    ADD CONSTRAINT champions_pkey PRIMARY KEY (id);


--
-- Name: coin_transactions coin_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coin_transactions
    ADD CONSTRAINT coin_transactions_pkey PRIMARY KEY (id);


--
-- Name: conferences conferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conferences
    ADD CONSTRAINT conferences_pkey PRIMARY KEY (id);


--
-- Name: divisions divisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.divisions
    ADD CONSTRAINT divisions_pkey PRIMARY KEY (id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: oban_jobs oban_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs
    ADD CONSTRAINT oban_jobs_pkey PRIMARY KEY (id);


--
-- Name: oban_peers oban_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_peers
    ADD CONSTRAINT oban_peers_pkey PRIMARY KEY (name);


--
-- Name: organization_memberships organization_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT organization_memberships_pkey PRIMARY KEY (id);


--
-- Name: organization_permissions organization_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_permissions
    ADD CONSTRAINT organization_permissions_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: pack_slots pack_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pack_slots
    ADD CONSTRAINT pack_slots_pkey PRIMARY KEY (id);


--
-- Name: packs packs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packs
    ADD CONSTRAINT packs_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: plants plants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plants
    ADD CONSTRAINT plants_pkey PRIMARY KEY (id);


--
-- Name: rarities rarities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rarities
    ADD CONSTRAINT rarities_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seasons seasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT seasons_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: upgrades upgrades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upgrades
    ADD CONSTRAINT upgrades_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: weeklies weeklies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeklies
    ADD CONSTRAINT weeklies_pkey PRIMARY KEY (id);


--
-- Name: accounts_email_address_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX accounts_email_address_index ON public.accounts USING btree (email_address);


--
-- Name: accounts_onboarding_state_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_onboarding_state_index ON public.accounts USING btree (onboarding_state);


--
-- Name: accounts_tokens_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_tokens_account_id_index ON public.accounts_tokens USING btree (account_id);


--
-- Name: accounts_tokens_context_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX accounts_tokens_context_token_index ON public.accounts_tokens USING btree (context, token);


--
-- Name: cards_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cards_account_id_index ON public.cards USING btree (account_id);


--
-- Name: cards_champion_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cards_champion_id_index ON public.cards USING btree (champion_id);


--
-- Name: cards_rarity_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cards_rarity_id_index ON public.cards USING btree (rarity_id);


--
-- Name: cards_season_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cards_season_id_index ON public.cards USING btree (season_id);


--
-- Name: champions_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX champions_name_index ON public.champions USING btree (name);


--
-- Name: champions_plant_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX champions_plant_id_index ON public.champions USING btree (plant_id);


--
-- Name: champions_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX champions_slug_index ON public.champions USING btree (slug);


--
-- Name: coin_transactions_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX coin_transactions_account_id_index ON public.coin_transactions USING btree (account_id);


--
-- Name: conferences_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX conferences_name_index ON public.conferences USING btree (name);


--
-- Name: conferences_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX conferences_slug_index ON public.conferences USING btree (slug);


--
-- Name: divisions_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX divisions_name_index ON public.divisions USING btree (name);


--
-- Name: divisions_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX divisions_slug_index ON public.divisions USING btree (slug);


--
-- Name: matches_division_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX matches_division_id_index ON public.matches USING btree (division_id);


--
-- Name: matches_left_champion_id_right_champion_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX matches_left_champion_id_right_champion_id_index ON public.matches USING btree (left_champion_id, right_champion_id);


--
-- Name: matches_right_champion_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX matches_right_champion_id_index ON public.matches USING btree (right_champion_id);


--
-- Name: matches_season_id_division_id_weekly_id_left_champion_id_right_; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX matches_season_id_division_id_weekly_id_left_champion_id_right_ ON public.matches USING btree (season_id, division_id, weekly_id, left_champion_id, right_champion_id);


--
-- Name: matches_season_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX matches_season_id_index ON public.matches USING btree (season_id);


--
-- Name: matches_weekly_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX matches_weekly_id_index ON public.matches USING btree (weekly_id);


--
-- Name: oban_jobs_args_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_args_index ON public.oban_jobs USING gin (args);


--
-- Name: oban_jobs_meta_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_meta_index ON public.oban_jobs USING gin (meta);


--
-- Name: oban_jobs_state_queue_priority_scheduled_at_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_queue_priority_scheduled_at_id_index ON public.oban_jobs USING btree (state, queue, priority, scheduled_at, id);


--
-- Name: organization_memberships_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_memberships_account_id_index ON public.organization_memberships USING btree (account_id);


--
-- Name: organization_memberships_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_memberships_organization_id_index ON public.organization_memberships USING btree (organization_id);


--
-- Name: organization_permissions_organization_membership_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_permissions_organization_membership_id_index ON public.organization_permissions USING btree (organization_membership_id);


--
-- Name: organization_permissions_permission_id_organization_membership_; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX organization_permissions_permission_id_organization_membership_ ON public.organization_permissions USING btree (permission_id, organization_membership_id);


--
-- Name: organizations_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX organizations_slug_index ON public.organizations USING btree (slug);


--
-- Name: pack_slots_card_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pack_slots_card_id_index ON public.pack_slots USING btree (card_id);


--
-- Name: pack_slots_pack_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pack_slots_pack_id_index ON public.pack_slots USING btree (pack_id);


--
-- Name: packs_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX packs_account_id_index ON public.packs USING btree (account_id);


--
-- Name: packs_season_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX packs_season_id_index ON public.packs USING btree (season_id);


--
-- Name: permissions_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX permissions_slug_index ON public.permissions USING btree (slug);


--
-- Name: plants_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX plants_name_index ON public.plants USING btree (name);


--
-- Name: plants_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX plants_slug_index ON public.plants USING btree (slug);


--
-- Name: rarities_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rarities_name_index ON public.rarities USING btree (name);


--
-- Name: rarities_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rarities_slug_index ON public.rarities USING btree (slug);


--
-- Name: season_plants_plant_id_season_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX season_plants_plant_id_season_id_index ON public.season_plants USING btree (plant_id, season_id);


--
-- Name: season_plants_season_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX season_plants_season_id_index ON public.season_plants USING btree (season_id);


--
-- Name: seasons_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX seasons_active_index ON public.seasons USING btree (active);


--
-- Name: tags_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tags_name_index ON public.tags USING btree (name);


--
-- Name: tags_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tags_slug_index ON public.tags USING btree (slug);


--
-- Name: upgrades_champion_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX upgrades_champion_id_index ON public.upgrades USING btree (champion_id);


--
-- Name: upgrades_endurance_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX upgrades_endurance_index ON public.upgrades USING btree (endurance);


--
-- Name: upgrades_intelligence_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX upgrades_intelligence_index ON public.upgrades USING btree (intelligence);


--
-- Name: upgrades_luck_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX upgrades_luck_index ON public.upgrades USING btree (luck);


--
-- Name: upgrades_patron_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX upgrades_patron_account_id_index ON public.upgrades USING btree (patron_account_id);


--
-- Name: upgrades_speed_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX upgrades_speed_index ON public.upgrades USING btree (speed);


--
-- Name: upgrades_stage_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX upgrades_stage_index ON public.upgrades USING btree (stage);


--
-- Name: upgrades_strength_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX upgrades_strength_index ON public.upgrades USING btree (strength);


--
-- Name: versions_event_item_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_event_item_type_index ON public.versions USING btree (event, item_type);


--
-- Name: versions_item_id_item_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_item_id_item_type_index ON public.versions USING btree (item_id, item_type);


--
-- Name: versions_item_type_inserted_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_item_type_inserted_at_index ON public.versions USING btree (item_type, inserted_at);


--
-- Name: versions_originator_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_originator_id_index ON public.versions USING btree (originator_id);


--
-- Name: webhooks_provider_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX webhooks_provider_index ON public.webhooks USING btree (provider);


--
-- Name: weeklies_season_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX weeklies_season_id_index ON public.weeklies USING btree (season_id);


--
-- Name: oban_jobs oban_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER oban_notify AFTER INSERT ON public.oban_jobs FOR EACH ROW EXECUTE FUNCTION public.oban_jobs_notify();


--
-- Name: accounts_tokens accounts_tokens_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_tokens
    ADD CONSTRAINT accounts_tokens_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: cards cards_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: cards cards_champion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_champion_id_fkey FOREIGN KEY (champion_id) REFERENCES public.champions(id) ON DELETE CASCADE;


--
-- Name: cards cards_rarity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_rarity_id_fkey FOREIGN KEY (rarity_id) REFERENCES public.rarities(id) ON DELETE CASCADE;


--
-- Name: cards cards_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id) ON DELETE CASCADE;


--
-- Name: champions champions_plant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.champions
    ADD CONSTRAINT champions_plant_id_fkey FOREIGN KEY (plant_id) REFERENCES public.plants(id) ON DELETE CASCADE;


--
-- Name: coin_transactions coin_transactions_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coin_transactions
    ADD CONSTRAINT coin_transactions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: divisions divisions_conference_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.divisions
    ADD CONSTRAINT divisions_conference_id_fkey FOREIGN KEY (conference_id) REFERENCES public.conferences(id) ON DELETE CASCADE;


--
-- Name: matches matches_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- Name: matches matches_left_champion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_left_champion_id_fkey FOREIGN KEY (left_champion_id) REFERENCES public.champions(id) ON DELETE CASCADE;


--
-- Name: matches matches_right_champion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_right_champion_id_fkey FOREIGN KEY (right_champion_id) REFERENCES public.champions(id) ON DELETE CASCADE;


--
-- Name: matches matches_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id) ON DELETE CASCADE;


--
-- Name: matches matches_weekly_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_weekly_id_fkey FOREIGN KEY (weekly_id) REFERENCES public.weeklies(id) ON DELETE CASCADE;


--
-- Name: organization_memberships organization_memberships_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT organization_memberships_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: organization_memberships organization_memberships_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT organization_memberships_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: organization_permissions organization_permissions_organization_membership_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_permissions
    ADD CONSTRAINT organization_permissions_organization_membership_id_fkey FOREIGN KEY (organization_membership_id) REFERENCES public.organization_memberships(id);


--
-- Name: organization_permissions organization_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_permissions
    ADD CONSTRAINT organization_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


--
-- Name: pack_slots pack_slots_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pack_slots
    ADD CONSTRAINT pack_slots_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.cards(id) ON DELETE CASCADE;


--
-- Name: pack_slots pack_slots_pack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pack_slots
    ADD CONSTRAINT pack_slots_pack_id_fkey FOREIGN KEY (pack_id) REFERENCES public.packs(id) ON DELETE CASCADE;


--
-- Name: packs packs_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packs
    ADD CONSTRAINT packs_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: packs packs_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packs
    ADD CONSTRAINT packs_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id) ON DELETE CASCADE;


--
-- Name: season_plants season_plants_plant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.season_plants
    ADD CONSTRAINT season_plants_plant_id_fkey FOREIGN KEY (plant_id) REFERENCES public.plants(id) ON DELETE CASCADE;


--
-- Name: season_plants season_plants_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.season_plants
    ADD CONSTRAINT season_plants_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id) ON DELETE CASCADE;


--
-- Name: upgrades upgrades_champion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upgrades
    ADD CONSTRAINT upgrades_champion_id_fkey FOREIGN KEY (champion_id) REFERENCES public.champions(id) ON DELETE CASCADE;


--
-- Name: upgrades upgrades_patron_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upgrades
    ADD CONSTRAINT upgrades_patron_account_id_fkey FOREIGN KEY (patron_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: versions versions_originator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_originator_id_fkey FOREIGN KEY (originator_id) REFERENCES public.accounts(id);


--
-- Name: weeklies weeklies_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeklies
    ADD CONSTRAINT weeklies_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20191225213553);
INSERT INTO public."schema_migrations" (version) VALUES (20191225213554);
INSERT INTO public."schema_migrations" (version) VALUES (20200127021834);
INSERT INTO public."schema_migrations" (version) VALUES (20200127021837);
INSERT INTO public."schema_migrations" (version) VALUES (20200127021838);
INSERT INTO public."schema_migrations" (version) VALUES (20200127021839);
INSERT INTO public."schema_migrations" (version) VALUES (20201215210357);
INSERT INTO public."schema_migrations" (version) VALUES (20220209090825);
INSERT INTO public."schema_migrations" (version) VALUES (20220628175515);
INSERT INTO public."schema_migrations" (version) VALUES (20220927032208);
INSERT INTO public."schema_migrations" (version) VALUES (20221113002915);
INSERT INTO public."schema_migrations" (version) VALUES (20221113003640);
INSERT INTO public."schema_migrations" (version) VALUES (20221113003649);
INSERT INTO public."schema_migrations" (version) VALUES (20221113003650);
INSERT INTO public."schema_migrations" (version) VALUES (20221113003651);
INSERT INTO public."schema_migrations" (version) VALUES (20221230230314);
INSERT INTO public."schema_migrations" (version) VALUES (20230101024919);
INSERT INTO public."schema_migrations" (version) VALUES (20230101201304);
INSERT INTO public."schema_migrations" (version) VALUES (20230101201716);
INSERT INTO public."schema_migrations" (version) VALUES (20230101203007);
INSERT INTO public."schema_migrations" (version) VALUES (20230101203129);
INSERT INTO public."schema_migrations" (version) VALUES (20230101204131);
INSERT INTO public."schema_migrations" (version) VALUES (20230101204132);
INSERT INTO public."schema_migrations" (version) VALUES (20230101223120);
INSERT INTO public."schema_migrations" (version) VALUES (20230102002000);
INSERT INTO public."schema_migrations" (version) VALUES (20230102002130);
INSERT INTO public."schema_migrations" (version) VALUES (20230102003023);
INSERT INTO public."schema_migrations" (version) VALUES (20230102003228);
INSERT INTO public."schema_migrations" (version) VALUES (20230102005514);
INSERT INTO public."schema_migrations" (version) VALUES (20230102005527);
INSERT INTO public."schema_migrations" (version) VALUES (20230102013808);
INSERT INTO public."schema_migrations" (version) VALUES (20230102013833);
INSERT INTO public."schema_migrations" (version) VALUES (20230102014048);
INSERT INTO public."schema_migrations" (version) VALUES (20230102014849);
INSERT INTO public."schema_migrations" (version) VALUES (20230103033245);
INSERT INTO public."schema_migrations" (version) VALUES (20230103120615);
INSERT INTO public."schema_migrations" (version) VALUES (20230104221314);
INSERT INTO public."schema_migrations" (version) VALUES (20230104221333);
INSERT INTO public."schema_migrations" (version) VALUES (20230104234152);
INSERT INTO public."schema_migrations" (version) VALUES (20230107210325);
INSERT INTO public."schema_migrations" (version) VALUES (20230224040723);
INSERT INTO public."schema_migrations" (version) VALUES (20230224044447);
INSERT INTO public."schema_migrations" (version) VALUES (20230224044538);
INSERT INTO public."schema_migrations" (version) VALUES (20230224051217);
INSERT INTO public."schema_migrations" (version) VALUES (20230228042615);
INSERT INTO public."schema_migrations" (version) VALUES (20230228042631);
INSERT INTO public."schema_migrations" (version) VALUES (20230302080008);
INSERT INTO public."schema_migrations" (version) VALUES (20230302092317);
INSERT INTO public."schema_migrations" (version) VALUES (20230302092335);
INSERT INTO public."schema_migrations" (version) VALUES (20230302092937);
INSERT INTO public."schema_migrations" (version) VALUES (20230303113328);
INSERT INTO public."schema_migrations" (version) VALUES (20230303113901);
INSERT INTO public."schema_migrations" (version) VALUES (20230303113911);
INSERT INTO public."schema_migrations" (version) VALUES (20230303113922);
INSERT INTO public."schema_migrations" (version) VALUES (20230304190159);
INSERT INTO public."schema_migrations" (version) VALUES (20230304190218);
INSERT INTO public."schema_migrations" (version) VALUES (20230304190224);
INSERT INTO public."schema_migrations" (version) VALUES (20230304191908);
INSERT INTO public."schema_migrations" (version) VALUES (20230304194037);
